#!/usr/bin/env bash
#
# monocloud subscription usage display for waybar.
#
# Contract with waybar's custom module (return-type: json):
#   * always exit 0
#   * always print one JSON object on stdout: {text, class, tooltip, percentage}
#   * class is one of "online", "warning", "critical", "offline" so CSS can
#     style each state (#custom-monocloud.offline { color: gray; })
#   * tooltip carries Pango markup (progress bar, colors), so the waybar module
#     MUST NOT set "escape": true -- waybar would escape the tooltip text and
#     the markup tags would show up literally.
#
# Waybar hides a custom module whenever stdout is empty or the exit code is
# non-zero, and it runs `exec` synchronously in the interval worker thread,
# so a hanging curl also freezes the hourly timer. Hence: bounded curl
# timeouts, no `set -e` aborts, and a cached last-known reading as offline
# fallback (tooltip then shows the last good values, marked as stale).

set -u
export LC_NUMERIC=C

# Subscription URL (contains a credential).  Override with MONOCLOUD_URL to
# keep the secret out of the repository, e.g. in your shell profile.
URL="${MONOCLOUD_URL:-http://172.18.8.5:8365/sub/ZGVtb0BleGFtcGxlLmNvbTpzZWNyZXQxMjM}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/monocloud_usage"
BAR_WIDTH=18
now=$(date +%s)

# --- helpers ---------------------------------------------------------------

json_escape() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\t'/\\t}
    printf '%s' "$s"
}

# Print one JSON line: text, class, tooltip, percentage
emit() {
    printf '{"text":"%s","class":"%s","tooltip":"%s","percentage":%d}\n' \
        "$(json_escape "$1")" "$2" "$(json_escape "$3")" "${4:-0}"
}

is_num() {
    [[ $1 =~ ^[0-9]+$ ]]
}

human_ago() {
    local s=$1
    if ((s < 60)); then
        printf '%ds' "$s"
    elif ((s < 3600)); then
        printf '%dm' "$((s / 60))"
    elif ((s < 86400)); then
        printf '%dh' "$((s / 3600))"
    else
        printf '%dd' "$((s / 86400))"
    fi
}

# Split "upload=1; download=2; total=3; expire=4" into key=value lines
parse_header() {
    printf '%s\n' "$1" | sed -e 's/^[^:]*:[[:space:]]*//' | tr ';' '\n' |
        sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' |
        while IFS='=' read -r k v; do
            [[ -n $k ]] && printf '%s=%s\n' "$k" "$v"
        done
}

# --- fetch -----------------------------------------------------------------

upload=''
download=''
total=''
expire=''
cached_at=''

header=$(curl -s --connect-timeout 3 --max-time 8 -I "$URL" 2>/dev/null |
    grep -i '^Subscription-Userinfo:' | head -n1 | tr -d '\r')

if [[ -n $header ]]; then
    while IFS='=' read -r k v; do
        case $k in
            upload | download | total | expire)
                if is_num "$v"; then printf -v "$k" '%s' "$v"; fi
                ;;
        esac
    done < <(parse_header "$header")
fi

# A header that parsed into nothing usable counts as offline
fetched=0
if [[ -n $header && (-n $upload || -n $download || -n $total) ]]; then
    fetched=1
    upload=${upload:-0}
    download=${download:-0}
    total=${total:-0}
    expire=${expire:-0}
    printf 'upload=%s\ndownload=%s\ntotal=%s\nexpire=%s\ncached_at=%s\n' \
        "$upload" "$download" "$total" "$expire" "$now" >"$CACHE.tmp.$$" 2>/dev/null &&
        mv -f "$CACHE.tmp.$$" "$CACHE" 2>/dev/null
fi

stale=0
if ((fetched == 0)); then
    if [[ -r $CACHE ]]; then
        while IFS='=' read -r k v; do
            case $k in
                upload | download | total | expire | cached_at)
                    if is_num "$v"; then printf -v "$k" '%s' "$v"; fi
                    ;;
            esac
        done <"$CACHE"
        stale=1
    fi
fi

# No live values and no cache: nothing to show beyond a placeholder
if ((fetched == 0)) && [[ -z $cached_at && -z $upload && -z $download && -z $total ]]; then
    emit "offline" "offline" "No subscription data available (offline, no cached reading)" 0
    exit 0
fi

upload=${upload:-0}
download=${download:-0}
total=${total:-0}
expire=${expire:-0}
cached_at=${cached_at:-0}

# --- compute ---------------------------------------------------------------

read -r used_gb total_gb remain_gb pct days color bar_full bar_empty < <(
    awk -v u="$upload" -v d="$download" -v t="$total" -v e="$expire" \
        -v now="$now" -v w="$BAR_WIDTH" '
        BEGIN {
            gb = 1024 * 1024 * 1024
            used = u + d
            used_gb = used / gb
            total_gb = t / gb
            pct = (t > 0) ? used * 100 / t : 0
            remain_gb = (t > used) ? (t - used) / gb : 0
            days = (e > 0) ? int((e - now) / 86400) : -1
            filled = (t > 0) ? int(pct * w / 100 + 0.5) : 0
            if (filled > w) filled = w
            full = ""; empty = ""
            for (i = 0; i < filled; i++) full = full "█"
            for (i = filled; i < w; i++) empty = empty "░"
            color = (pct >= 95) ? "#f38ba8" : (pct >= 80 ? "#f9e2af" : "#a6e3a1")
            printf "%.2f %.2f %.2f %.1f %d %s %s %s\n", used_gb, total_gb, remain_gb, pct, days, color, full, empty
        }'
)

used_s=$(printf '%.2f' "$used_gb")
total_s=$(printf '%.2f' "$total_gb")
remain_s=$(printf '%.2f' "$remain_gb")
up_s=$(awk -v v="$upload" 'BEGIN { printf "%.2f", v / 1024 / 1024 / 1024 }')
down_s=$(awk -v v="$download" 'BEGIN { printf "%.2f", v / 1024 / 1024 / 1024 }')
pct_s=$(printf '%.1f' "$pct")
pct_i=${pct%%.*}
((pct_i > 100)) && pct_i=100
((pct_i < 0)) && pct_i=0

# --- text (single line) ----------------------------------------------------

if ((days >= 0)); then
    text=$(printf '%sG·%dd' "$used_s" "$days")
elif ((expire > 0)); then
    text=$(printf '%sG·exp' "$used_s")
else
    text=$(printf '%sG' "$used_s")
fi

# --- class -----------------------------------------------------------------

if ((stale)); then
    cls='offline'
elif ((expire > 0 && days < 0)); then
    # subscription already expired -- always surface it
    cls='critical'
elif ((pct_i >= 95)); then
    cls='critical'
elif ((pct_i >= 80)); then
    cls='warning'
else
    cls='online'
fi

# --- tooltip (Pango markup) ------------------------------------------------
#
# Only the title is bold.  style.css sets `* { font-weight: 600 }` and waybar
# registers that stylesheet for the whole screen, so GTK tooltip windows pick
# it up too and every tooltip line would render semibold.  Pango markup beats
# CSS, hence the explicit weight='normal' wrapper around the detail block.

tt="<b>Monocloud subscription</b>"
if ((stale)); then
    tt+=" <span color='#f38ba8'>(offline)</span>"
fi
tt+=$'\n'"<span weight='normal'>"

if ((stale && cached_at > 0)); then
    tt+="<span color='#6c7086'>last update $(human_ago $((now - cached_at))) ago</span>"$'\n'
fi

tt+="Used: ${used_s} GiB"
((total > 0)) && tt+=" / ${total_s} GiB"
tt+=$'\n'

if ((total > 0)); then
    # Adwaita Sans has no block elements (U+2588..) -- only the gauge falls
    # back to Adwaita Mono, everything else stays in the default font.
    tt+="<span color='${color}' font_family='Adwaita Mono'>[${bar_full}${bar_empty}]</span> ${pct_s}%"$'\n'
    tt+="Remaining: ${remain_s} GiB"$'\n'
fi

tt+="Up: ${up_s} GiB · Down: ${down_s} GiB"

if ((total <= 0)); then
    tt+=$'\n'"Total: not reported"
fi

if ((expire > 0)); then
    exp_date=$(date -d "@${expire}" +%Y-%m-%d 2>/dev/null || printf 'unknown')
    if ((days >= 0)); then
        if ((days == 0)); then
            tt+=$'\n'"Expires: ${exp_date} (under 1 day left)"
        else
            tt+=$'\n'"Expires: ${exp_date} (${days} day$([[ $days == 1 ]] || printf s) left)"
        fi
    else
        tt+=$'\n'"<span color='#f38ba8'>Expired: ${exp_date}</span>"
    fi
else
    tt+=$'\n'"Expires: never"
fi

tt+="</span>"

emit "$text" "$cls" "$tt" "$pct_i"
exit 0

#!/usr/bin/env bash
#
# Build the small wayland helper used by the niri idle-lock waybar module.
#
#   ./build-niri-idle-watch.sh [output-dir]
#
# The helper is placed in ~/.local/bin by default.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
out_dir="${1:-$HOME/.local/bin}"
proto_dir="$(pkg-config --variable=pkgdatadir wayland-protocols 2>/dev/null || true)"
proto_dir="${proto_dir:-/usr/share/wayland-protocols}"
proto_xml="$proto_dir/staging/ext-idle-notify/ext-idle-notify-v1.xml"

if [[ ! -f "$proto_xml" ]]; then
    echo "missing $proto_xml (install wayland-protocols)" >&2
    exit 1
fi

tmp_dir="$(mktemp -d)"
tmp_bin="$out_dir/.niri-idle-watch.$$"
trap 'rm -rf "$tmp_dir"; rm -f "$tmp_bin"' EXIT

wayland-scanner client-header \
    "$proto_xml" "$tmp_dir/ext-idle-notify-v1-client-protocol.h"
wayland-scanner private-code \
    "$proto_xml" "$tmp_dir/ext-idle-notify-v1-protocol.c"

mkdir -p "$out_dir"

# shellcheck disable=SC2046
cc -O2 -Wall -Wextra -I"$tmp_dir" \
    -o "$tmp_bin" \
    "$script_dir/niri-idle-watch.c" \
    "$tmp_dir/ext-idle-notify-v1-protocol.c" \
    $(pkg-config --cflags --libs wayland-client)

mv -f "$tmp_bin" "$out_dir/niri-idle-watch"

printf 'built %s/niri-idle-watch\n' "$out_dir"

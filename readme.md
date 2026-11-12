Rice
---

This repository contains configurations for ricing.

# Common
## waybar
Waybar configurations.

### monocloud subscription usage
`custom/monocloud` shows the current subscription usage and days left.  Hovering
it opens a tooltip with a usage gauge, remaining quota, up/down traffic and the
expiry date (`scripts/monocloud-usage.sh`).  The module turns yellow at 80% and
red at 95% usage or once the subscription has expired; when the endpoint is
unreachable the last known reading is shown greyed out as `offline`.

The script reads the URL (which contains a credential) from `MONOCLOUD_URL`,
falling back to the built-in default.  Export it from a file that is not
versioned if the credential should stay out of git.

### niri idle-lock countdown
`custom/idle-lock` shows the countdown until the niri session locks while idle
and toggles automatic idle locking when clicked.  It reads the timeout from the
hypridle lock listener and uses a small wayland helper (`ext-idle-notify-v1`).
Build the helper once:

```sh
~/.config/rice.d/scripts/build-niri-idle-watch.sh
```

The hypridle `on-timeout` hooks are `scripts/niri-idle-lock` (500s lock) and
`scripts/niri-idle-dpms` (550s monitor power-off); both are skipped when the
toggle is off.  The 300s backlight dim is intentionally independent.  Manual
locking still works.

## dunst
Dunst notification tool.

## rofi
rofi configuration and theme.

# Hyprland
Hyprland configurations, components
- hyprlockg
- hyprpaper
- hypridle
- hyprshot

# scripts
some shell scripts requires to `chmod +x` and place in `$PATH` to work.


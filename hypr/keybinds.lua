local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "rofi -show drun -show-icons"
local mainMod     = "SUPER"

-- KEYBINDINGS
hl.bind(mainMod .. " + Q",                    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + K",                    hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + DELETE",       hl.dsp.exit())
hl.bind(mainMod .. " + E",                    hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F",                    hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + C",                    hl.dsp.exec_cmd("/usr/bin/rofi -modi clipboard:~/.local/bin/cliphist-rofi-img -show clipboard -show-icons"))
hl.bind(mainMod .. " + V",                    hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",                    hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",                    hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T",                    hl.dsp.exec_cmd("kitten quick-access-terminal"))
hl.bind(mainMod .. " + bracketright",         hl.dsp.window.resize({ x = 240, y = 0, relative = true }))
hl.bind(mainMod .. " + bracketleft",          hl.dsp.window.resize({ x = -240, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.resize({ x = 120, y = 0, relative = true}))
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.window.resize({ x = -120, y = 0, relative = true}))
hl.bind(mainMod .. " + SHIFT + F",            hl.dsp.window.fullscreen({ fullscreen = 1 }))
hl.bind(mainMod .. " + SHIFT + T",            hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + P",            hl.dsp.group.prev())
hl.bind(mainMod .. " + SHIFT + N",            hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + L",            hl.dsp.group.lock())
hl.bind(mainMod .. " + SHIFT + R",            hl.dsp.layout("promote"))
hl.bind(mainMod .. " + prior",                hl.dsp.exec_cmd("hypr-zoom -interp=Linear -duration=100 -steps=30 -target=+0.5"))
hl.bind(mainMod .. " + next",                 hl.dsp.exec_cmd("hypr-zoom -interp=Linear -duration=100 -steps=30 -target=-0.5"))
hl.bind(mainMod .. " + left",                 hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",                hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",                   hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + down",                 hl.dsp.layout("swapcol r"))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + S",             hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down",    hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",      hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + PRINT",         hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("PRINT",                       hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SHIFT + PRINT",               hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd("rofi -show drun -show-icons"))
hl.bind(mainMod .. " + Tab",           hl.dsp.exec_cmd("rofi -show window -show-icons"))
hl.bind(mainMod .. " + O",             hl.dsp.exec_cmd("rofi -modi clipboard:~/.local/bin/cliphist-rofi-img -show clipboard -show-icons"))
hl.bind(mainMod .. " + L",             hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                   { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set +32"),     { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 32-"),     { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                  { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                             { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                             { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                               { locked = true })

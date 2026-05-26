-- WINDOW RULES
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        --xwayland   = true,
        --float      = true,
        --fullscreen = false,
        --pin        = false,
    },
    no_focus = true,
    opacity = "0.3"
})

hl.window_rule({
    name  = "emacs-opacity",
    match = { class = "emacs" },
    opacity = "0.8",
})

hl.window_rule({
    name  = "nautilus-opacity",
    match = { class = "org.gnome.Nautilus", },
    opacity = "0.9",
})

hl.window_rule({
    name  = "zed-opacity",
    match = { class = "dev.zed.Zed" },
    opacity = "0.9",
})

hl.window_rule({
    name  = "google-chrome-visual",
    match = { class = "^google-chrome$" },
    no_blur = true,
    opaque  = true,
})

hl.window_rule({
    name  = "firefox-dev-visual",
    match = { class = "^firefox-dev$" },
    no_blur = true,
    opaque  = true,
})

hl.window_rule({
    name  = "bing-wall-visual",
    match = { class = "^bing-wall$" },
    no_blur = true,
    opaque  = true,
    float   = true,
})

hl.window_rule({
    name  = "steam-visual",
    match = { class = "^steam$" },
    no_blur = true,
    opaque  = true,
})

hl.window_rule({
    name  = "firefox-about-opts",
    match = { title = "About Firefox Developer Edition" },
    float = true,
})

hl.window_rule({
    name  = "nm-connection-editor",
    match = { class = "^nm-connection-editor$" },
    no_blur = true,
    opaque  = true,
    float   = true,
})

hl.window_rule({
    name  = "gimp-visual",
    match = { class = "^gimp$" },
    no_blur = true,
    opaque  = true,
})

--hl.window_rule({
--    name = "wireshark",
--    match = { class = "^org.wireshark.Wireshark$" },
--    no_blur = true,
--    opaque = true,
--})

hl.window_rule({
    name  = "et-float",
    match = { title = "^et$" },
    float = true,
})

hl.window_rule({
    name  = "nextcloud-float",
    match = { class = "com.nextcloud.desktopclient.nextcloud" },
    float = true,
    move  = "1536 24",
})

hl.window_rule({
    name  = "dingtalk",
    match = { class = "com.alibabainc.dingtalk", title = "钉钉" },
    max_size       = "1536 970",
    float          = true,
    size           = "1536 972",
    no_follow_mouse = true,
    no_blur        = true,
    opaque         = true,
    move           = "192 54",
})

hl.window_rule({
    name  = "wechat-opts",
    match = { class = "^wechat$", initial_title = "wechat" },
    no_blur        = true,
    opaque         = true,
    no_follow_mouse = true,
})

hl.window_rule({
    name  = "wechat-float",
    match = { class = "^wechat$", initial_title = "微信" },
    max_size       = "1536 972",
    float          = true,
    size           = "1536 972",
    no_follow_mouse = true,
    no_blur        = true,
    opaque         = true,
    move           = "192 54",
})

hl.window_rule({
    name  = "qq",
    match = { class = "^QQ$", title = "QQ" },
    max_size       = "1536 972",
    float          = true,
    size           = "1536 972",
    no_follow_mouse = true,
    no_blur        = true,
    opaque         = true,
    move           = "192 54",
})

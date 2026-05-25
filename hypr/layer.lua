-- LAYER RULES
hl.layer_rule({
    name  = "kitty-quick-access",
    match        = { namespace = "kitty-quick-access" },
    blur         = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name  = "waybar",
    match        = { namespace = "waybar" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name  = "rofi",
    match        = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name  = "notifications",
    match        = { namespace = "notifications" },
    blur         = true,
    ignore_alpha = 0.1,
})

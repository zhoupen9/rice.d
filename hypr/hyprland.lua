-- MY PROGRAMS
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "rofi -show drun -show-icons"
local mainMod     = "SUPER"

-- MONITORS
hl.monitor({
    output   = "DP-1",
    mode     = "3840x2160@60",
    position = "0x0",
    scale    = "2",
})
hl.monitor({
    output   = "DP-2",
    mode     = "3840x2160@60",
    position = "1920x0",
    scale    = "2",
})

-- AUTOSTART
hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("xrdb -merge ~/.Xresources")
end)

-- ENVIRONMENT VARIABLES
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- LOOK AND FEEL
hl.config({
    general = {
        gaps_in  = 1,
        gaps_out = 2, --"2, 0, 0, 0",

        border_size = 1,

        col = {
            active_border   = "rgba(333333ff)",
            inactive_border = "rgba(080808f0)",
        },

        resize_on_border       = true,
        extend_border_grab_area = 2,
        allow_tearing          = false,

        layout = "scrolling",
    },

    group = {
        col = {
	     border_active          = "rgba(356ab84f)",
             border_inactive        = "rgba(3322334e)",
             border_locked_active   = "rgba(aa22444e)",
             border_locked_inactive = "rgba(5511224e)",
	},

        groupbar = {
            col = {
	         active                = "rgba(1f1f1f8f)",
                 inactive              = "rgba(1f1f1fdf)",
                 locked_active         = "rgba(b81144af)",
                 locked_inactive       = "rgba(661122af)",
	    },
            text_color                = "0xfffdfeff",
            text_color_inactive       = "0xffddd0d8",
            text_color_locked_inactive = "0xffaabbcc",
            rounding                  = 0,
            font_size                 = 11,
            height                    = 24,
            gradients                 = true,
            gradient_rounding         = 0,
            round_only_edges          = false,
            indicator_gap             = 0,
            indicator_height          = 0,
            blur                      = true,
            gaps_in                   = 1,
            gaps_out                  = -1,
            keep_upper_gap            = true,
        },
    },

    decoration = {
        rounding       = 4,
        rounding_power = 4,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "rgba(1d1d1dee)",
        },

        blur = {
            enabled                = true,
            size                   = 12,
            passes                 = 4,
            noise                  = 0.01,
            brightness             = 1,
            contrast               = 0.6,
            new_optimizations      = true,
            vibrancy               = 0.02,
            popups                 = true,
            --popups_ignorealpha     = 0.05,
            special                = false,
            input_methods          = true,
            input_methods_ignorealpha = 0,
        },
    },

    animations = {
        enabled = true,
    },
})

-- WORKSPACES
for i = 0, 9 do
    hl.config({
        workspace = {
            tostring(i) .. ", layout:scrolling",
        },
    })
end

-- LAYOUTS
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        column_width       = 0.75,
        follow_focus       = true,
        follow_min_visible = 0.9,
    },
})

-- MISC
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
    },
})

-- INPUT
hl.config({
    input = {
        kb_layout     = "us",
        follow_mouse  = 1,
        sensitivity   = 0,
        repeat_delay  = 300,
        repeat_rate   = 45,
        natural_scroll = true,

        touchpad = {
            natural_scroll    = true,
            tap_to_click      = true,
            clickfinger_behavior = 1,
            scroll_factor     = 0.2,
        },
    },
})

hl.device({
    name            = "steelseries-sensei-raw-gaming-mouse",
    sensitivity     = -0.5,
    natural_scroll  = true,
})

-- XWAYLAND
hl.config({
    xwayland = {
        force_zero_scaling  = true,
        use_nearest_neighbor = false,
    },
})

require("animation")
require("gesture")
require("keybinds")
require("window")
require("layer")

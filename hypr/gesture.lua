hl.gesture({ fingers = 3, direction = "up",    action = "fullscreen", param = "1" })
hl.gesture({ fingers = 3, direction = "down",  action = "float" })
hl.gesture({ fingers = 3, direction = "left",  action = function() hl.dsp.focus({ direction = "left" }) end })
hl.gesture({ fingers = 3, direction = "right",  action = function() hl.dsp.focus({ direction = "right" }) end })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })


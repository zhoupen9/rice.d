hl.gesture({ fingers = 2, direction = "pinch", action = "cursorZoom", zoom_level = 1.2, mode = "live" })
hl.gesture({ fingers = 3, direction = "up",    action = "fullscreen", param = "1" })
hl.gesture({ fingers = 3, direction = "down",  action = "float" })
hl.gesture({ fingers = 3, direction = "left",  action = function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end })
hl.gesture({ fingers = 3, direction = "right",  action = function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })


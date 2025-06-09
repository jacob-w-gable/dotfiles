local vicious = require("vicious")
local wibox = require("wibox")

-- Create a text widget for CPU temperature
local cputempwidget = wibox.widget.textbox()
-- Add margin around the CPU temperature widget
local cputempwidget_with_margin = wibox.container.margin(cputempwidget, 5, 5, 0, 0) -- Left, Right, Top, Bottom margins
-- Register the CPU temperature widget with vicious
vicious.register(cputempwidget, vicious.widgets.thermal, function(widget, args)
	return string.format('<span font="Hack Nerd Font 8">%d°C</span>', args[1])
end, 61, "thermal_zone0")

return cputempwidget_with_margin

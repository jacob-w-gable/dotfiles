local vicious = require("vicious")
local wibox = require("wibox")
local theme = require("theme.theme")

-- Create a text widget for CPU temperature
local cputempwidget = wibox.widget.textbox()
-- Add margin around the CPU temperature widget
local cputempwidget_with_margin = wibox.container.margin(cputempwidget, 20, 10, 0, 0) -- Left, Right, Top, Bottom margins
-- Register the CPU temperature widget with vicious
vicious.register(cputempwidget, vicious.widgets.thermal, function(widget, args)
	return string.format('<span font="%s">%d°C</span>', theme.font, args[1])
end, 7, "thermal_zone0")

return cputempwidget_with_margin

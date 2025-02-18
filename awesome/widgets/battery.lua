local vicious = require("vicious")
local wibox = require("wibox")
local theme = require("theme.theme")

-- Create a text widget for the battery
local batwidget = wibox.widget.textbox()
-- Add margin around the battery widget
local batwidget_with_margin = wibox.container.margin(batwidget, 5, 5, 0, 0) -- Left, Right, Top, Bottom margins
-- Register the battery widget with vicious
vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
	return string.format('<span font="%s">Bat: %d%%</span>', theme.font, args[2])
end, 61, "BAT0")

return batwidget_with_margin

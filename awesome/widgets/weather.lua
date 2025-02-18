local wibox = require("wibox")
local vicious = require("vicious")
local theme = require("theme.theme")

-- Create a weather widget
local weather_widget = wibox.widget.textbox()
local weather_widget_with_margin = wibox.container.margin(weather_widget, 5, 5, 0, 0)

vicious.register(weather_widget, vicious.widgets.weather, function(widget, args)
	return string.format('<span font="%s">%s°F (HSV)</span>', theme.font, args["{tempf}"])
end, 600, "KHSV")

return weather_widget_with_margin

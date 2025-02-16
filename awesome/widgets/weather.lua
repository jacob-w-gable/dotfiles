local wibox = require("wibox")
local vicious = require("vicious")

-- Create a weather widget
local weather_widget = wibox.widget.textbox()
local weather_widget_with_margin = wibox.container.margin(weather_widget, 5, 5, 0, 0)

vicious.register(weather_widget, vicious.widgets.weather, "${tempf}°F (HSV)", 600, "KHSV")

return weather_widget_with_margin

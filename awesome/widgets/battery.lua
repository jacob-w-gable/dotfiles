local vicious = require("vicious")
local wibox = require("wibox")

-- Create a text widget for the battery
local batwidget = wibox.widget.textbox()
-- Add margin around the battery widget
local batwidget_with_margin = wibox.container.margin(batwidget, 5, 5, 0, 0) -- Left, Right, Top, Bottom margins
-- Register the battery widget with vicious
vicious.register(batwidget, vicious.widgets.bat, "Bat: $2%", 61, "BAT0") -- $2 for battery percentage, %% to display %

return batwidget_with_margin

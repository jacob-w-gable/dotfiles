local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local caffeine_widget = wibox.widget({
	{
		text = "󰾪 ",
		widget = wibox.widget.textbox,
	},
	widget = wibox.container.margin,
	left = 5,
	right = 1,
})

local caffeine_enabled = false

caffeine_widget:buttons(gears.table.join(awful.button({}, 1, function() -- Left click to toggle mute
	if caffeine_enabled then
		awful.spawn("xset s on +dpms", false)
		caffeine_widget.widget.text = "󰾪 "
		naughty.notify({ title = "Caffeine", text = "Disabled (Sleep Allowed)", timeout = 2 })
	else
		awful.spawn("xset s off -dpms", false)
		caffeine_widget.widget.text = "󰅶 "
		naughty.notify({ title = "Caffeine", text = "Enabled (No Sleep)", timeout = 2 })
	end
	caffeine_enabled = not caffeine_enabled
end)))

return caffeine_widget

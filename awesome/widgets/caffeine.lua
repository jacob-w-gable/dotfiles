local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local theme = require("theme.theme")

local caffeine_widget = wibox.widget({
	{
		markup = string.format('<span font="%s">󰾪 </span>', theme.font),
		widget = wibox.widget.textbox,
		id = "caffeine_text",
	},
	widget = wibox.container.margin,
	left = 5,
	right = 1,
})

local caffeine_enabled = false

caffeine_widget:buttons(gears.table.join(awful.button({}, 1, function() -- Left click to toggle mute
	local text_widget = caffeine_widget:get_children_by_id("caffeine_text")[1]
	if caffeine_enabled then
		awful.spawn("xset s on +dpms", false)
		caffeine_widget.widget.text = "󰾪 "
		text_widget.markup = string.format('<span font="%s">󰾪 </span>', theme.font)
		naughty.notify({ title = "Caffeine", text = "Disabled (Sleep Allowed)", timeout = 2 })
	else
		awful.spawn("xset s off -dpms", false)
		text_widget.markup = string.format('<span font="%s">󰅶 </span>', theme.font)
		naughty.notify({ title = "Caffeine", text = "Enabled (No Sleep)", timeout = 2 })
	end
	caffeine_enabled = not caffeine_enabled
end)))

return caffeine_widget

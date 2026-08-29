local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local views = require("widgets.views")

local AWAKE = "󰅶 "
local SLEEPY = "󰾪 "

local set = views.new()
local enabled = false

local function markup(glyph)
	return string.format('<span font="%s">%s</span>', beautiful.font, glyph)
end

--- Toggle sleep inhibition. Exported so a keybinding can drive it too; every
--- screen's glyph updates.
local function toggle()
	enabled = not enabled

	if enabled then
		awful.spawn("xset s off -dpms", false)
		set.set(markup(AWAKE))
		naughty.notify({ title = "Caffeine", text = "Enabled (No Sleep)", timeout = 2 })
	else
		awful.spawn("xset s on +dpms", false)
		set.set(markup(SLEEPY))
		naughty.notify({ title = "Caffeine", text = "Disabled (Sleep Allowed)", timeout = 2 })
	end
end

local M = { toggle = toggle }

function M.new()
	local textbox = set.add(wibox.widget.textbox(markup(enabled and AWAKE or SLEEPY)))

	local widget = wibox.widget({
		textbox,
		widget = wibox.container.margin,
		left = 5,
		right = 1,
	})

	widget:buttons(gears.table.join(awful.button({}, 1, toggle)))

	return widget
end

return M

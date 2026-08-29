local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local views = require("widgets.views")

local NO_VOLUME = "Vol: --"

local set = views.new()

local function markup(text)
	return string.format('<span font="%s">%s</span>', beautiful.font, text)
end

local function update()
	awful.spawn.easy_async({ "pactl", "get-sink-volume", "@DEFAULT_SINK@" }, function(stdout, _, _, exit_code)
		if exit_code ~= 0 then
			return set.set(markup(NO_VOLUME))
		end

		local volume = stdout:match("(%d+)%%")
		set.set(markup(volume and string.format("Vol: %s%%", volume) or NO_VOLUME))
	end)
end

local function adjust(args)
	awful.spawn.easy_async(args, function()
		awesome.emit_signal("volume::update")
	end)
end

local M = {}

function M.new()
	local textbox = set.add(wibox.widget.textbox(markup(NO_VOLUME)))

	local widget = wibox.widget({
		widget = wibox.container.background,
		{
			widget = wibox.container.margin,
			margins = 4,
			textbox,
		},
	})

	widget:buttons(gears.table.join(
		awful.button({}, 4, function()
			adjust({ "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%" })
		end),
		awful.button({}, 5, function()
			adjust({ "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%" })
		end),
		awful.button({}, 1, function()
			adjust({ "pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle" })
		end)
	))

	set.start_once(function()
		awesome.connect_signal("volume::update", update)

		-- Catch changes made outside awesome: pavucontrol, another session's
		-- media keys, a device switch.
		gears.timer({
			timeout = 5,
			autostart = true,
			call_now = false,
			callback = function()
				awesome.emit_signal("volume::update")
			end,
		})

		update()
	end)

	return widget
end

return M

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local theme = require("theme.theme")

local volume_widget = wibox.widget({
	widget = wibox.container.background,
	{
		widget = wibox.container.margin,
		margins = 4,
		{
			widget = wibox.widget.textbox,
			id = "volume_text",
			markup = string.format('<span font="%s">Vol: --</span>', theme.font),
		},
	},
})

local function set_volume_text(widget, text)
	widget:get_children_by_id("volume_text")[1].markup = string.format('<span font="%s">%s</span>', theme.font, text)
end

local function update_volume(widget)
	awful.spawn.easy_async({ "pactl", "get-sink-volume", "@DEFAULT_SINK@" }, function(stdout, stderr, reason, exit_code)
		if exit_code ~= 0 then
			set_volume_text(widget, "Vol: --")
			return
		end

		local volume = stdout:match("(%d+)%%")

		if not volume then
			set_volume_text(widget, "Vol: --")
			return
		end

		set_volume_text(widget, string.format("Vol: %s%%", volume))
	end)
end

-- Initial update
update_volume(volume_widget)

awesome.connect_signal("volume::update", function()
	update_volume(volume_widget)
end)

volume_widget:buttons(gears.table.join(
	awful.button({}, 4, function()
		awful.spawn.easy_async({ "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%" }, function()
			awesome.emit_signal("volume::update")
		end)
	end),

	awful.button({}, 5, function()
		awful.spawn.easy_async({ "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%" }, function()
			awesome.emit_signal("volume::update")
		end)
	end),

	awful.button({}, 1, function()
		awful.spawn.easy_async({ "pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle" }, function()
			awesome.emit_signal("volume::update")
		end)
	end)
))

-- Keep in sync with external changes (e.g. keyboard media keys,
-- pavucontrol, etc.)
gears.timer({
	timeout = 5,
	autostart = true,
	call_now = false,
	callback = function()
		awesome.emit_signal("volume::update")
	end,
})

return volume_widget

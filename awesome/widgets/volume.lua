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
			markup = string.format('<span font="%s">Vol: 0%%</span>', theme.font),
		},
	},
})

-- Function to update volume
local function update_volume(widget)
	awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
		local volume = stdout:match("(%d+)%%")
		widget:get_children_by_id("volume_text")[1].markup =
			string.format('<span font="%s">Vol: %s%%</span>', theme.font, volume or "0")
	end)
end

-- Update volume on creation and when the volume changes
update_volume(volume_widget)
awesome.connect_signal("volume::update", function()
	update_volume(volume_widget)
end)

-- Bind keys or buttons to control volume
volume_widget:buttons(gears.table.join(
	awful.button({}, 4, function() -- Scroll up
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
		awesome.emit_signal("volume::update")
	end),
	awful.button({}, 5, function() -- Scroll down
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
		awesome.emit_signal("volume::update")
	end),
	awful.button({}, 1, function() -- Left click to toggle mute
		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
		awesome.emit_signal("volume::update")
	end)
))

-- Automatically update the widget periodically
gears.timer({
	timeout = 1,
	autostart = true,
	callback = function()
		awesome.emit_signal("volume::update")
	end,
})

return volume_widget

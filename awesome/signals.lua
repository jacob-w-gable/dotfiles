-- Client signals: placement of new windows, border width and colour, and
-- focus-follows-mouse.
--
-- Awesome dispatches every handler connected to a signal, so these sit
-- alongside the handlers in solo.lua and ui/titlebar.lua. They are separate
-- concerns that share a signal name.

local awful = require("awful")
local beautiful = require("beautiful")
local apps = require("config.apps")

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	if c.class == apps.image_viewer_class or c.name == apps.centered_dialog_name then
		local screen_geometry = c.screen.workarea
		local width = screen_geometry.width / 2
		local height = screen_geometry.height / 2

		c.floating = true
		c.width = width
		c.height = height
		c.x = screen_geometry.x + (screen_geometry.width - width) / 2
		c.y = screen_geometry.y + (screen_geometry.height - height) / 2
		c:raise()

		awful.titlebar.hide(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- Remove borders on maximized / fullscreen clients
client.connect_signal("property::maximized", function(c)
	if c.maximized or c.maximized_horizontal or c.maximized_vertical then
		c.border_width = 0
	else
		c.border_width = beautiful.border_width
	end
end)

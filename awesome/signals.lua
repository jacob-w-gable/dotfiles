-- Client signals: placement of new windows, border width and colour, and
-- focus-follows-mouse.
--
-- Awesome dispatches every handler connected to a signal, so these sit
-- alongside the handlers in solo.lua and ui/titlebar.lua. They are separate
-- concerns that share a signal name.

local awful = require("awful")
local beautiful = require("beautiful")
local apps = require("config.apps")
local settings = require("config")

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

-- Onboard positions itself from its own saved docking geometry, which ends up
-- hanging off the bottom of the display - the lower part of the keyboard is
-- drawn past the screen edge, so raising its height just pushes more of it out
-- of view. Pin it to a strip along the bottom edge instead.
local function pin_onscreen_keyboard(c)
	local geo = c.screen.geometry
	local height = settings.osk_height
	c:geometry({
		x = geo.x,
		y = geo.y + geo.height - height,
		width = geo.width,
		height = height,
	})
end

client.connect_signal("manage", function(c)
	if c.class == apps.osk_class then
		pin_onscreen_keyboard(c)
	end
end)

-- Onboard re-applies its own geometry after mapping and on rotation, so keep
-- correcting it. The comparison makes this a no-op once pinned, which stops it
-- recursing on the geometry change it makes itself.
client.connect_signal("property::geometry", function(c)
	if c.class ~= apps.osk_class then
		return
	end
	local geo = c.screen.geometry
	local height = settings.osk_height
	if c.width ~= geo.width or c.height ~= height or c.y ~= geo.y + geo.height - height then
		pin_onscreen_keyboard(c)
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

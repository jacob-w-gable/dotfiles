-- Per-client key bindings. Mirrors awesome/bindings/client.lua.
--
-- In awesome these are attached to each client through the rules; Hyprland binds are
-- global and act on the focused window, so there is no attaching to do.

local settings = require("config")
local solo = require("solo")

local mod = settings.modkey

--- Toggle a window state, then let solo mode react to it.
--
-- Hyprland raises no Lua event when a window enters or leaves fullscreen, so solo mode
-- cannot watch for it the way awesome/solo.lua watches property::fullscreen. Driving it
-- from the binding covers every case the user causes, which is all of them bar an app
-- that fullscreens itself - a video player, say. Those are not picked up.
local function toggle_then_enforce(mode)
	return function()
		hl.dispatch(hl.dsp.window.fullscreen({ mode = mode, action = "toggle" }))
		solo.enforce()
	end
end

return function()
	hl.bind(mod .. " + F", toggle_then_enforce("fullscreen"))
	hl.bind(mod .. " + M", toggle_then_enforce("maximized"))
	hl.bind(mod .. " + SHIFT + C", hl.dsp.window.close())
	hl.bind(mod .. " + CONTROL + space", hl.dsp.window.float({ action = "toggle" }))
	hl.bind(mod .. " + CONTROL + Return", hl.dsp.layout("swapwithmaster"))
	hl.bind(mod .. " + O", hl.dsp.window.move({ monitor = "+1", follow = true }))

	-- ontop. Hyprland only pins floating windows, which is the case where awesome's
	-- ontop is meaningful anyway.
	hl.bind(mod .. " + T", hl.dsp.window.pin({ action = "toggle" }))
	hl.bind(mod .. " + SHIFT + T", hl.dsp.window.alter_zorder({ mode = "bottom" }))

	-- Mod+Ctrl+m and Mod+Shift+m maximise vertically and horizontally. Hyprland
	-- maximises in both axes only, so there is nothing to bind them to.
end

-- On-screen keyboard control (Onboard).
--
-- Onboard provides its own system tray icon while running, so this module is a
-- plain controller with no bar widget of its own. It is driven by tablet mode
-- and by the modkey+Control+o binding.
--
-- See the "Onboard" rule in rules.lua and the geometry pinning in signals.lua:
-- the keyboard floats on top and is deliberately not focusable, so keystrokes
-- reach the window underneath.

local awful = require("awful")
local naughty = require("naughty")

local enabled = false

--- Show or hide the keyboard.
--
-- @tparam boolean want Whether the keyboard should be running.
-- @tparam[opt=true] boolean notify Whether to raise a notification.
local function set(want, notify)
	if want == enabled then
		return
	end

	if want then
		-- Guarded on onboard being installed, like the autostart entries: a
		-- machine without it should get one clear message rather than a
		-- silently dead binding.
		--
		-- Docking is set first because Onboard otherwise restores its own saved
		-- window geometry, which ends up fullscreen once the max layout has
		-- tiled it. Docking makes it size and position itself against the
		-- bottom edge instead of using that stale geometry.
		awful.spawn.with_shell(table.concat({
			"command -v onboard >/dev/null || {",
			'notify-send -u critical "onboard not found" "Install onboard for the on-screen keyboard."; exit 0; }',
			"gsettings set org.onboard.window docking-enabled true;",
			"gsettings set org.onboard.window force-to-top true;",
			"onboard",
		}, " "))
	else
		awful.spawn("pkill onboard", false)
	end

	enabled = want
	if notify ~= false then
		naughty.notify({ title = "On-screen Keyboard", text = want and "Shown" or "Hidden", timeout = 2 })
	end
end

local M = {}

function M.show(notify)
	set(true, notify)
end

function M.hide(notify)
	set(false, notify)
end

function M.toggle()
	set(not enabled)
end

return M

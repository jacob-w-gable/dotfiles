-- Global key bindings, including the per-workspace number keys.
--
-- Mirrors awesome/bindings/global.lua. Where a binding has no Wayland equivalent it is
-- noted rather than silently dropped.

local settings = require("config")
local apps = require("config.apps")
local solo = require("solo")
local layouts = require("layouts")
local scratchpad = require("scratchpad")

local mod = settings.modkey

return function()
	-- Module state, so it resets on reload while a running hyprsunset survives. The
	-- same caveat applies to awesome's redshift toggle.
	local nightlight = false

	------------------------------------------------------------------ launchers
	hl.bind(mod .. " + Return", hl.dsp.exec_cmd(apps.terminal))
	hl.bind(mod .. " + P", hl.dsp.exec_cmd(apps.launcher))
	hl.bind(mod .. " + A", hl.dsp.exec_cmd(apps.launcher))
	hl.bind(mod .. " + CONTROL + R", hl.dsp.exec_cmd(apps.runner))
	hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(apps.screenshot_region))
	hl.bind(mod .. " + apostrophe", hl.dsp.exec_cmd(apps.lock))

	------------------------------------------------------------------- session
	-- awesome.restart has no direct equivalent: hyprctl reload re-reads the config
	-- without dropping the session, which is what the binding was for.
	hl.bind(mod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
	hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

	------------------------------------------------------------------ hotkeys
	hl.bind(mod .. " + W", hl.dsp.exec_cmd(apps.wallpaper))
	hl.bind(mod .. " + C", hl.dsp.exec_cmd(apps.caffeine))

	hl.bind(mod .. " + D", function()
		if settings.display_fix_command then
			hl.exec_cmd(settings.display_fix_command)
		end
	end)

	-- hyprsunset in place of redshift, which is X11-only.
	hl.bind(mod .. " + E", function()
		nightlight = not nightlight
		if nightlight then
			hl.exec_cmd("hyprctl hyprsunset temperature 3500")
		else
			hl.exec_cmd("hyprctl hyprsunset identity")
		end
	end)

	-- The pomodoro lives in the bar, so the toggle is a signal to waybar rather than a
	-- dispatcher. See waybar/scripts/pomodoro.
	hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd("pkill -RTMIN+9 waybar"))

	-------------------------------------------------------------------- focus
	-- Routed through solo mode, which cycles the workspace's window list when only one
	-- window is visible and falls back to directional focus otherwise.
	hl.bind(mod .. " + J", function()
		solo.focus_next(1)
	end)
	hl.bind(mod .. " + K", function()
		solo.focus_next(-1)
	end)

	hl.bind(mod .. " + Tab", hl.dsp.focus({ last = true }))
	hl.bind(mod .. " + U", hl.dsp.focus({ urgent_or_last = true }))

	-- Screens. awesome uses Mod+Alt+j/k; ALT is Hyprland's name for Mod1.
	hl.bind(mod .. " + ALT + J", hl.dsp.focus({ monitor = "+1" }))
	hl.bind(mod .. " + ALT + K", hl.dsp.focus({ monitor = "-1" }))

	------------------------------------------------------------------- layout
	hl.bind(mod .. " + SHIFT + J", hl.dsp.window.swap({ next = true }))
	hl.bind(mod .. " + SHIFT + K", hl.dsp.window.swap({ prev = true }))

	-- awesome's incmwfact. dwindle has no master factor, so this resizes along the
	-- same axis, which is what the binding feels like in use.
	hl.bind(mod .. " + L", hl.dsp.window.resize({ x = 40, y = 0 }))
	hl.bind(mod .. " + H", hl.dsp.window.resize({ x = -40, y = 0 }))

	-- incnmaster. Only the master layout has a concept of master count; in dwindle
	-- these are no-ops, as incnmaster effectively is in awesome's floating layout.
	hl.bind(mod .. " + SHIFT + L", hl.dsp.layout("addmaster"))
	hl.bind(mod .. " + SHIFT + H", hl.dsp.layout("removemaster"))

	-- incncol has no equivalent: neither dwindle nor master lays out in columns.
	-- Reused for the master orientation, which is the nearest thing to the effect.
	hl.bind(mod .. " + CONTROL + L", hl.dsp.layout("orientationnext"))
	hl.bind(mod .. " + CONTROL + H", hl.dsp.layout("orientationprev"))

	hl.bind(mod .. " + space", function()
		layouts.cycle(1)
	end)
	hl.bind(mod .. " + SHIFT + space", function()
		layouts.cycle(-1)
	end)

	--------------------------------------------------------------- workspaces
	hl.bind(mod .. " + Left", hl.dsp.focus({ workspace = "e-1" }))
	hl.bind(mod .. " + Right", hl.dsp.focus({ workspace = "e+1" }))
	hl.bind(mod .. " + Escape", hl.dsp.focus({ workspace = "previous" }))

	-- awesome creates four tags per screen, named 1-4, in ui/bar.lua. Keys 5-9 are
	-- bound there too and no-op on a missing tag; Hyprland creates the workspace
	-- instead, which is the more useful behaviour and costs nothing.
	for i = 1, 9 do
		hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
		hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
	end

	-- Mod+Ctrl+N toggles a tag's visibility and Mod+Ctrl+Shift+N toggles a client onto
	-- a tag. Neither has an equivalent: Hyprland workspaces are exclusive, so a window
	-- is on exactly one and a workspace is either shown or not.

	--------------------------------------------------------------- scratchpad
	-- Wayland has no minimise. The special workspace is the idiomatic stand-in, and
	-- scratchpad.lua keeps the restore order so Mod+Shift+N behaves like unminimising.
	hl.bind(mod .. " + N", function()
		scratchpad.push()
	end)
	hl.bind(mod .. " + SHIFT + N", function()
		scratchpad.pop()
	end)

	-------------------------------------------------------------------- media
	local media = {
		{ "XF86AudioRaiseVolume", apps.volume_up },
		{ "XF86AudioLowerVolume", apps.volume_down },
		{ "XF86AudioMute", apps.volume_mute },
		{ "XF86AudioPlay", apps.media_play },
		{ "XF86AudioNext", apps.media_next },
		{ "XF86AudioPrev", apps.media_prev },
		{ "XF86MonBrightnessUp", apps.brightness_up },
		{ "XF86MonBrightnessDown", apps.brightness_down },
	}

	-- locked so they still work on the lock screen, which is what i3lock's
	-- --custom-key-commands bought awesome; repeating so holding a key ramps.
	for _, entry in ipairs(media) do
		hl.bind(entry[1], hl.dsp.exec_cmd(entry[2]), { locked = true, repeating = true })
	end
end

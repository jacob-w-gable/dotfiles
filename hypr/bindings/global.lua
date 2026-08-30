-- Global key bindings, including the per-workspace number keys.
--
-- Mirrors awesome/bindings/global.lua, group names and all. Where a binding has no
-- Wayland equivalent it is noted rather than silently dropped.

local settings = require("config")
local apps = require("config.apps")
local solo = require("solo")
local layouts = require("layouts")
local scratchpad = require("scratchpad")
local bind = require("bindings").bind

local mod = settings.modkey

return function()
	-- Module state, so it resets on reload while a running hyprsunset survives. The
	-- same caveat applies to awesome's redshift toggle.
	local nightlight = false

	------------------------------------------------------------------ launchers
	bind(mod .. " + Return", hl.dsp.exec_cmd(apps.terminal), "launcher", "open a terminal")
	bind(mod .. " + P", hl.dsp.exec_cmd(apps.launcher), "launcher", "application launcher")
	bind(mod .. " + A", hl.dsp.exec_cmd(apps.launcher), "launcher", "show main menu")
	bind(mod .. " + CONTROL + R", hl.dsp.exec_cmd(apps.runner), "launcher", "run prompt")
	bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(apps.screenshot_region), "launcher", "take screenshot")

	--------------------------------------------------------------------- session
	bind(mod .. " + apostrophe", hl.dsp.exec_cmd(apps.lock), "hotkeys", "lock screen")
	bind(mod .. " + S", hl.dsp.exec_cmd(apps.hotkeys), "awesome", "show help")

	-- awesome.restart has no direct equivalent: hyprctl reload re-reads the config
	-- without dropping the session, which is what the binding was for.
	bind(mod .. " + R", hl.dsp.exec_cmd("hyprctl reload"), "awesome", "reload the config")
	bind(mod .. " + SHIFT + Q", hl.dsp.exit(), "awesome", "quit")

	--------------------------------------------------------------------- hotkeys
	bind(mod .. " + W", hl.dsp.exec_cmd(apps.wallpaper), "hotkeys", "change wallpaper")
	bind(mod .. " + C", hl.dsp.exec_cmd(apps.caffeine), "hotkeys", "toggle caffeine")

	bind(mod .. " + D", function()
		if settings.display_fix_command then
			hl.exec_cmd(settings.display_fix_command)
		end
	end, "hotkeys", "refresh displays")

	-- hyprsunset in place of redshift, which is X11-only.
	bind(mod .. " + E", function()
		nightlight = not nightlight
		if nightlight then
			hl.exec_cmd("hyprctl hyprsunset temperature 3500")
		else
			hl.exec_cmd("hyprctl hyprsunset identity")
		end
	end, "hotkeys", "toggle eye saver mode")

	-- The pomodoro lives in the bar, so the toggle is a signal to waybar rather than a
	-- dispatcher. See waybar/scripts/pomodoro.
	bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd("pkill -RTMIN+9 waybar"), "hotkeys", "toggle pomodoro widget")

	----------------------------------------------------------------------- focus
	-- Routed through solo mode, which cycles the workspace's window list when only one
	-- window is visible and falls back to directional focus otherwise.
	bind(mod .. " + J", function()
		solo.focus_next(1)
	end, "client", "focus next by index")
	bind(mod .. " + K", function()
		solo.focus_next(-1)
	end, "client", "focus previous by index")

	bind(mod .. " + Tab", hl.dsp.focus({ last = true }), "client", "go back")
	bind(mod .. " + U", hl.dsp.focus({ urgent_or_last = true }), "client", "jump to urgent client")

	-- Screens. awesome uses Mod+Alt+j/k; ALT is Hyprland's name for Mod1.
	bind(mod .. " + ALT + J", hl.dsp.focus({ monitor = "+1" }), "screen", "focus the next screen")
	bind(mod .. " + ALT + K", hl.dsp.focus({ monitor = "-1" }), "screen", "focus the previous screen")

	---------------------------------------------------------------------- layout
	bind(mod .. " + SHIFT + J", hl.dsp.window.swap({ next = true }), "client", "swap with next client")
	bind(mod .. " + SHIFT + K", hl.dsp.window.swap({ prev = true }), "client", "swap with previous client")

	-- awesome's incmwfact. dwindle has no master factor, so this resizes along the
	-- same axis, which is what the binding feels like in use.
	bind(mod .. " + L", hl.dsp.window.resize({ x = 40, y = 0 }), "layout", "increase master width")
	bind(mod .. " + H", hl.dsp.window.resize({ x = -40, y = 0 }), "layout", "decrease master width")

	-- incnmaster. Only the master layout has a concept of master count; in dwindle
	-- these are no-ops, as incnmaster effectively is in awesome's floating layout.
	bind(mod .. " + SHIFT + L", hl.dsp.layout("addmaster"), "layout", "more master clients")
	bind(mod .. " + SHIFT + H", hl.dsp.layout("removemaster"), "layout", "fewer master clients")

	-- incncol has no equivalent: neither dwindle nor master lays out in columns.
	-- Reused for the master orientation, which is the nearest thing to the effect.
	bind(mod .. " + CONTROL + L", hl.dsp.layout("orientationnext"), "layout", "next master orientation")
	bind(mod .. " + CONTROL + H", hl.dsp.layout("orientationprev"), "layout", "previous master orientation")

	bind(mod .. " + space", function()
		layouts.cycle(1)
	end, "layout", "select next layout")
	bind(mod .. " + SHIFT + space", function()
		layouts.cycle(-1)
	end, "layout", "select previous layout")

	------------------------------------------------------------------ workspaces
	bind(mod .. " + Left", hl.dsp.focus({ workspace = "e-1" }), "tag", "view previous")
	bind(mod .. " + Right", hl.dsp.focus({ workspace = "e+1" }), "tag", "view next")
	bind(mod .. " + Escape", hl.dsp.focus({ workspace = "previous" }), "tag", "go back")

	-- awesome creates four tags per screen, named 1-4, in ui/bar.lua. Keys 5-9 are
	-- bound there too and no-op on a missing tag; Hyprland creates the workspace
	-- instead, which is the more useful behaviour and costs nothing.
	for i = 1, 9 do
		bind(mod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }), "tag", "view tag #" .. i)
		bind(
			mod .. " + SHIFT + " .. i,
			hl.dsp.window.move({ workspace = tostring(i) }),
			"tag",
			"move focused client to tag #" .. i
		)
	end

	-- Mod+Ctrl+N toggles a tag's visibility and Mod+Ctrl+Shift+N toggles a client onto
	-- a tag. Neither has an equivalent: Hyprland workspaces are exclusive, so a window
	-- is on exactly one and a workspace is either shown or not.

	------------------------------------------------------------------ scratchpad
	-- Wayland has no minimise. The special workspace is the idiomatic stand-in, and
	-- scratchpad.lua keeps the restore order so Mod+Shift+N behaves like unminimising.
	bind(mod .. " + N", function()
		scratchpad.push()
	end, "client", "minimize")
	bind(mod .. " + SHIFT + N", function()
		scratchpad.pop()
	end, "client", "restore minimized")

	----------------------------------------------------------------------- media
	local media = {
		{ "XF86AudioRaiseVolume", apps.volume_up, "increase volume" },
		{ "XF86AudioLowerVolume", apps.volume_down, "decrease volume" },
		{ "XF86AudioMute", apps.volume_mute, "mute volume" },
		{ "XF86AudioPlay", apps.media_play, "play/pause media" },
		{ "XF86AudioNext", apps.media_next, "next track" },
		{ "XF86AudioPrev", apps.media_prev, "previous track" },
		{ "XF86MonBrightnessUp", apps.brightness_up, "increase brightness" },
		{ "XF86MonBrightnessDown", apps.brightness_down, "decrease brightness" },
	}

	-- locked so they still work on the lock screen, which is what i3lock's
	-- --custom-key-commands bought awesome; repeating so holding a key ramps.
	for _, entry in ipairs(media) do
		bind(entry[1], hl.dsp.exec_cmd(entry[2]), "media", entry[3], { locked = true, repeating = true })
	end
end

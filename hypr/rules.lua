-- Rules applied to new windows. Mirrors awesome/rules.lua.
--
-- Hyprland matches on class and title only. awesome also matches X11 `instance` and
-- `role`, which have no Wayland counterpart, so those entries are matched on class
-- where the class is distinct enough and dropped where it is not - noted below.

local apps = require("config.apps")

return function()
	-- Float by class. The X11 names are kept because these apps keep them under
	-- XWayland, which is where several of them still run.
	local floating = {
		"^(Arandr)$",
		"^(Blueman-manager)$",
		"^(Gpick)$",
		"^(Kruler)$",
		"^(MessageWin)$", -- kalarm
		"^(Sxiv)$",
		"^(Tor Browser)$", -- fixed size, to avoid fingerprinting by screen dimensions
		"^(Wpa_gui)$",
		"^(veromix)$",
		"^(xtightvncviewer)$",
		"^(pinentry-.*)$",
		"^(copyq)$",
		"^(nm-connection-editor)$",
		"^(pavucontrol)$",
	}

	for _, class in ipairs(floating) do
		hl.window_rule({
			name = "float-" .. class:gsub("%W", ""),
			match = { class = class },
			float = true,
		})
	end

	-- awesome floats "Event Tester" (xev) by name, and DTA, ConfigManager and pop-up by
	-- X11 instance/role. Only the title-matched one carries over.
	hl.window_rule({
		name = "float-event-tester",
		match = { title = "^(Event Tester)$" },
		float = true,
	})

	-- The image viewer opens centred at half the workspace, from awesome/signals.lua.
	hl.window_rule({
		name = "centre-image-viewer",
		match = { class = "^(" .. apps.image_viewer_class .. ")$" },
		float = true,
		size = "50% 50%",
		move = "25% 25%",
	})

	hl.window_rule({
		name = "centre-open-files",
		match = { title = "^(Open Files)$" },
		float = true,
		size = "50% 50%",
		move = "25% 25%",
	})

	-- Ignore maximise requests from apps, so solo mode is driven by the keybinding
	-- rather than by whatever an application decides on startup.
	hl.window_rule({
		name = "suppress-maximize",
		match = { class = ".*" },
		suppress_event = "maximize",
	})

	-- XWayland windows with no class or title yet mis-handle drags; from the upstream
	-- example config.
	hl.window_rule({
		name = "fix-xwayland-drags",
		match = { class = "^$", title = "^$", xwayland = true, float = true },
		no_focus = true,
	})
end

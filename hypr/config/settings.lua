-- Tracked defaults. Anything true of one machine and not the others belongs in
-- config/machine.lua, which is gitignored - see config/machine.example.lua.
--
-- The AwesomeWM counterpart is awesome/config/settings.lua, and the names are kept the
-- same where the concept survives the move to Wayland.

return {
	opacity = true,
	vim_keys = false,

	-- The modifier every binding hangs off. "Mod4" in awesome's X11 naming.
	modkey = "SUPER",

	-- awesome pins dpi = 144 because the X server derives DPI from EDID at startup and
	-- the whole UI resizes between reboots. Wayland has no such race: the compositor
	-- owns scale per output, so this is a plain scale factor rather than a fixed DPI.
	scale = 1,

	font = "Hack Nerd Font",
	font_size = 11,

	-- theme/init.lua converts these to pixels. awesome uses useless_gap = dpi(5) and
	-- border_width = dpi(1) at 144 DPI, which is 7.5px and 1.5px.
	gaps_in = 4,
	gaps_out = 8,
	border_size = 2,
	rounding = 8,

	-- Blur and shadows are the expensive part of the compositor. Off under a VM, where
	-- they are the difference between usable and unusable; see config/machine.lua.
	effects = true,
	animations = true,

	-- Solo mode: on a workspace showing one window at a time, hide the rest. See
	-- solo.lua, and awesome/solo.lua for the behaviour it reproduces.
	solo = true,

	terminal = "kitty --single-instance",
	launcher = "rofi -show drun",
	runner = "rofi -show run",
}

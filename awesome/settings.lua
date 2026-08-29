return {
	vm_mode = false,
	opacity = true,
	compositor = true,
	vim_keys = false,

	-- The modifier every binding hangs off. Lives here rather than in rc.lua
	-- because widgets build their own click bindings at require time, before
	-- rc.lua has run far enough to have defined it.
	modkey = "Mod4",

	-- Base DPI for the UI. Pinned because the X server computes DPI from EDID
	-- at server startup, before the external monitor's real mode is applied:
	-- the laptop panel yields 144, an external monitor winning the race at boot
	-- yields 80, and the whole UI silently resizes between reboots.
	dpi = 144,
	dpi_scale = 1,
	font = "Hack Nerd Font 8",

	theme = "squircle",

	lock_screen_wallpaper = os.getenv("HOME") .. "/.config/awesome/theme/lockscreen.png",
}

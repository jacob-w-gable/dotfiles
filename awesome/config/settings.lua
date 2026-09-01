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

	-- Height in pixels of the on-screen keyboard, which signals.lua pins to the
	-- bottom edge of the screen. Onboard's own docking geometry hangs off the
	-- bottom of the display, so this is what actually decides its size.
	osk_height = 260,

	theme = "squircle",

	-- Built from the active wallpaper by theme/lockscreen, which runs on every
	-- wallpaper change and at login. It lives in the cache rather than beside the
	-- config because it is generated, and the path is fixed because xss-lock is
	-- handed the i3lock command once, at login.
	lock_screen_wallpaper = os.getenv("HOME") .. "/.cache/awesome/lockscreen.png",
}

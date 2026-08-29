return {
	vm_mode = false,
	opacity = true,
	compositor = true,
	vim_keys = false,
	debian_base = false,

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

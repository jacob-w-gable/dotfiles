-- Per-machine overrides for the awesome config.
--
-- Copy to machine.lua (which is gitignored) and set only the keys that differ
-- on this computer. Anything not listed here falls back to config/settings.lua.
--
-- This exists because ~/.config/awesome is a symlink to the repo, so a
-- machine-specific tweak edited into a tracked file shows up as a permanently
-- dirty working tree and follows you onto every other machine.

return {
	-- The X server's idea of DPI depends on which display wins the race at
	-- boot, so this is pinned - and the right value differs per machine.
	-- dpi = 144,

	-- Extra programs to autostart. A plain string is run as-is. The table form
	-- is skipped when `bin` is not installed, like the built-in entries.
	-- extra_autostart = {
	-- 	{ bin = "nextcloud", command = "pkill nextcloud; nextcloud" },
	-- 	"some-command --that-always-runs",
	-- },

	-- Run at login, e.g. to fix up an external display's mode. Nil means the
	-- binding and the startup call are simply not created.
	-- display_fix_command = os.getenv("HOME") .. "/display_fix.sh",

	-- Per-device input tweaks, applied with xinput at login. The device name
	-- is what `xinput list` prints, and is specific to one machine's hardware.
	-- touchpad = {
	-- 	device = "UNIW0001:00 093A:0255 Touchpad",
	-- 	tapping = true,
	-- 	natural_scrolling = true,
	-- },
}

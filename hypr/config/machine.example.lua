-- Copy to config/machine.lua, which is gitignored, and keep anything machine-specific
-- here: it is merged over config/settings.lua at startup.
--
-- The awesome config uses the same pattern; see awesome/config/machine.example.lua.

return {
	-- Turn the compositor's effects off where there is no GPU to spare - a VM, say.
	-- effects = false,
	-- animations = false,

	-- Run when the display layout changes underneath you. Bound to Mod+d.
	-- display_fix_command = os.getenv("HOME") .. "/display_fix.sh",

	-- Per-output layout. Names come from `hyprctl monitors`.
	-- monitors = {
	--   { output = "eDP-1",  mode = "1920x1080@60", position = "0x0",    scale = 1 },
	--   { output = "DP-1",   mode = "preferred",    position = "1920x0", scale = 1 },
	-- },

	-- Per-device input. Names come from `hyprctl devices`.
	-- touchpad = { tapping = true, natural_scrolling = true },

	-- Extra programs to start with the session.
	-- autostart = { "nextcloud" },
}

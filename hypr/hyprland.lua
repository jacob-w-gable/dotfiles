-- Hyprland configuration - feasibility spike.
--
-- A deliberately small subset of the AwesomeWM config next door, enough to check that
-- the bindings and the look carry over to Wayland. The bar, the custom widgets and solo
-- mode are not here; see the plan for what a full port would involve.
--
-- Lua rather than hyprland.conf: 0.55 deprecated hyprlang and it is slated for removal.
-- The AwesomeWM config is Lua too, so the two read alike.

--------------------
---- MONITORS -----
--------------------

-- "preferred" rather than a fixed mode, so this works both on the VM's virtio output and
-- on real hardware. Under QEMU with no display attached, Hyprland falls back to a
-- HEADLESS-0 output at 1920x1080, which an empty `output` also matches.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

--------------------
---- PROGRAMS -----
--------------------

-- Mirrors awesome/config/apps.lua.
local terminal = "kitty --single-instance"
local launcher = "rofi -show drun"

-- awesome/config/settings.lua pins modkey = "Mod4".
local mod = "SUPER"

--------------------------
---- LOOK AND FEEL -----
--------------------------

-- Gaps and borders come from awesome/theme/theme.lua, which sets useless_gap = dpi(5)
-- and border_width = dpi(1) at a pinned DPI of 144. dpi(5) at 144 is 7.5px, so 8 and 2
-- are the rounded equivalents at the scale Hyprland works in.
--
-- Blur, shadows and animations are off. The VM has no GPU and renders through llvmpipe,
-- where they are the difference between sluggish and unusable. Turn them back on when
-- this config is tried on real hardware.
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 8,
		border_size = 2,

		-- Placeholders matching theme/colors.lua's fallbacks, for now. Wiring these to
		-- ~/.cache/wal/colors.json the way the Awesome theme does is a follow-on.
		col = {
			active_border = "rgba(1a5598ff)",
			inactive_border = "rgba(091a34ff)",
		},

		layout = "dwindle",
	},

	decoration = {
		rounding = 8,
		blur = { enabled = false },
		shadow = { enabled = false },
	},

	animations = {
		enabled = false,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},

	dwindle = {
		preserve_split = true,
	},
})

--------------
---- INPUT ---
--------------

hl.config({
	input = {
		kb_layout = "us",

		-- awesome/signals.lua connects mouse::enter to request::activate, i.e. sloppy
		-- focus. This is the same behaviour.
		follow_mouse = 1,

		-- autostart.lua sets these with `xset r rate 250 60`, which has no Wayland
		-- equivalent - the compositor owns key repeat instead.
		repeat_delay = 250,
		repeat_rate = 60,
	},
})

-------------------
---- KEYBINDS ----
-------------------

-- Launchers, from bindings/global.lua.
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + P", hl.dsp.exec_cmd(launcher))

-- Client control, from bindings/client.lua.
hl.bind(mod .. " + SHIFT + C", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + CONTROL + space", hl.dsp.window.float({ action = "toggle" }))

-- Focus. Awesome routes Mod+j/k through solo.focus_next, which walks the tag's client
-- list; without solo mode there is nothing to walk, so these are directional for now.
-- Note Awesome's j/k are inverted relative to their descriptions - j is focus_next(-1).
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))

-- Awesome's Mod+h/l change the master width factor. Hyprland has no master factor in
-- dwindle, so these resize the focused window along the same axis.
hl.bind(mod .. " + H", hl.dsp.window.resize({ x = -40, y = 0 }))
hl.bind(mod .. " + L", hl.dsp.window.resize({ x = 40, y = 0 }))

-- Four tags, named 1-4, created per screen in awesome/ui/bar.lua.
for i = 1, 4 do
	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Mouse, from bindings/mouse.lua: Mod+left drags, Mod+right resizes.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

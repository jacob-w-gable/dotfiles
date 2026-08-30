-- Hyprland configuration.
--
-- Laid out to mirror awesome/ next door, so the two can be read side by side: config/
-- holds settings and the programs to launch, theme/ the palette, bindings/ the keys.
-- Where a behaviour has no Wayland equivalent the module that would have carried it
-- says so rather than leaving it unexplained.
--
-- Lua rather than hyprland.conf because 0.55 deprecated hyprlang and it is slated for
-- removal - which happens to suit a repo whose window manager config is already Lua.

local settings = require("config")
local theme = require("theme")
local apps = require("config.apps")
local layouts = require("layouts")
local solo = require("solo")

--------------------------------------------------------------------- monitors

-- "preferred" everywhere by default, so this works on an unknown display without being
-- told about it. Real layouts belong in config/machine.lua.
if settings.monitors then
	for _, monitor in ipairs(settings.monitors) do
		hl.monitor(monitor)
	end
else
	hl.monitor({ output = "", mode = "preferred", position = "auto", scale = settings.scale })
end

--------------------------------------------------------------- look and feel

hl.config({
	general = {
		gaps_in = settings.gaps_in,
		gaps_out = settings.gaps_out,
		border_size = settings.border_size,

		col = {
			active_border = theme.border_active,
			inactive_border = theme.border_inactive,
		},

		-- awesome resizes from the border only with a modifier held; the gap is not a
		-- grab target there either.
		resize_on_border = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = settings.rounding,

		-- picom.conf dims unfocused windows by 0.04 and blurs with dual_kawase at
		-- strength 6; these are the compositor's equivalents.
		dim_inactive = settings.effects,
		dim_strength = 0.04,

		blur = {
			enabled = settings.effects,
			size = 6,
			passes = 2,
		},

		shadow = {
			enabled = settings.effects,
			range = 4,
			render_power = 3,
		},
	},

	animations = {
		enabled = settings.animations,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		-- The bar and the wallpaper are not windows to focus.
		focus_on_activate = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},
})

------------------------------------------------------------------------ input

hl.config({
	input = {
		kb_layout = "us",

		-- Sloppy focus, from the mouse::enter handler in awesome/signals.lua.
		follow_mouse = 1,

		-- awesome sets these with `xset r rate 250 60` at autostart. On Wayland the
		-- compositor owns key repeat, so they belong here.
		repeat_delay = 250,
		repeat_rate = 60,

		touchpad = {
			natural_scroll = settings.touchpad and settings.touchpad.natural_scrolling or false,
			tap_to_click = settings.touchpad and settings.touchpad.tapping or true,
		},
	},
})

------------------------------------------------------------------ environment

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Ask toolkits for their Wayland backends. Without these, GTK and Qt apps run through
-- XWayland and miss out on fractional scaling and the clipboard.
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- Screenshots need explicit permission when ecosystem.enforce_permissions is on.
hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")

----------------------------------------------------------------------- pieces

require("rules")()
require("bindings.global")()
require("bindings.client")()
require("bindings.mouse")()

layouts.init()
solo.connect()

-- Forget windows as they close, so neither module tries to restore one that is gone.
hl.on("window.close", function(event)
	local address = event and event.window and event.window.address
	if address then
		solo.forget(address)
		require("scratchpad").forget(address)
	end
end)

-- Deferred, not called here.
--
-- Hyprland exports WAYLAND_DISPLAY to the programs it spawns only once the compositor
-- is up. The config is evaluated before that, and config.reloaded fires before it too,
-- so anything started from either has nothing to connect to and exits immediately. A
-- short timer is the only hook that lands after the socket exists - hyprland.start,
-- which would be the obvious one, never fires in 0.56.
hl.timer(require("autostart"), { type = "oneshot", timeout = 2000 })

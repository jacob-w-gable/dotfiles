-- Programs and input settings applied once at login.
--
-- Skipped entirely when AWESOME_NO_AUTOSTART is set. Several entries pkill a
-- program before restarting it, and pkill is not scoped to a display -- run
-- from a nested X server (Xephyr) they would reach out and kill the copy
-- belonging to the real session. Testing this config in Xephyr is only safe
-- with the variable set.

local awful = require("awful")
local settings = require("config")
local apps = require("config.apps")

if os.getenv("AWESOME_NO_AUTOSTART") then
	return
end

-- Tray applets.
awful.spawn.with_shell("pkill nm-tray; nm-tray") -- network manager
awful.spawn.with_shell("pkill pasystray; pasystray") -- pulse audio
awful.spawn.with_shell("blueman-applet") -- bluetooth

-- Automatic locking. Timeout is configured with `xset s <timeout>`.
awful.spawn.with_shell("pkill xss-lock; xss-lock -l -- " .. apps.lock_command())

-- Screenshot daemon.
awful.spawn.with_shell("pkill flameshot; flameshot")

-- Per-device input tweaks. The device name comes from `xinput list` and is
-- specific to one machine's hardware, so it lives in config/machine.lua.
local touchpad = settings.touchpad
if touchpad and touchpad.device then
	local function set_prop(prop, value)
		awful.spawn.with_shell(string.format('xinput set-prop "%s" "%s" %d', touchpad.device, prop, value))
	end
	set_prop("libinput Tapping Enabled", touchpad.tapping and 1 or 0)
	set_prop("libinput Natural Scrolling Enabled", touchpad.natural_scrolling and 1 or 0)
end

-- Keyboard repeat delay and rate, in milliseconds.
awful.spawn.with_shell("xset r rate 250 60")

-- Anything this particular machine wants started.
for _, command in ipairs(settings.extra_autostart or {}) do
	awful.spawn.with_shell(command)
end

if settings.compositor then
	awful.spawn.with_shell("/usr/local/bin/picom --config ~/.config/picom/picom.conf --animations &")
end

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

local commands = {}

--- Queue a command, guarded on its binary being installed.
--
-- The guard is free: these run inside a shell we are spawning anyway, so
-- `command -v` costs no extra process and means a machine without, say,
-- pasystray simply skips it rather than spawning a failure.
--
-- Backgrounded, because they all share one shell now: the tray applets do not
-- exit, so run in the foreground the first of them would block every command
-- after it.
local function run(bin, command)
	commands[#commands + 1] = string.format("command -v %s >/dev/null && { %s; } &", bin, command or bin)
end

--- Restart a program: kill any existing copy first, then start it.
local function restart(bin, command)
	run(bin, string.format("pkill %s; %s", bin, command or bin))
end

-- Tray applets.
restart("nm-tray") -- network manager
restart("pasystray") -- pulse audio
run("blueman-applet") -- bluetooth

-- Automatic locking. Timeout is configured with `xset s <timeout>`.
restart("xss-lock", "xss-lock -l -- " .. apps.lock_command())

-- Screenshot daemon.
restart("flameshot")

-- Per-device input tweaks. The device name comes from `xinput list` and is
-- specific to one machine's hardware, so it lives in config/machine.lua.
local touchpad = settings.touchpad
if touchpad and touchpad.device then
	local function set_prop(prop, value)
		run("xinput", string.format('xinput set-prop "%s" "%s" %d', touchpad.device, prop, value))
	end
	set_prop("libinput Tapping Enabled", touchpad.tapping and 1 or 0)
	set_prop("libinput Natural Scrolling Enabled", touchpad.natural_scrolling and 1 or 0)
end

-- Keyboard repeat delay and rate, in milliseconds.
run("xset", "xset r rate 250 60")

-- Anything this particular machine wants started. An entry is either a plain
-- command string, run as-is, or { bin = ..., command = ... } to get the same
-- command -v guard as everything above.
for _, entry in ipairs(settings.extra_autostart or {}) do
	if type(entry) == "table" then
		run(entry.bin, entry.command)
	else
		commands[#commands + 1] = string.format("{ %s; } &", entry)
	end
end

if settings.compositor then
	-- By name rather than by path: the installer builds picom from source into
	-- /usr/local/bin, but a distro-packaged one lives in /usr/bin and PATH
	-- covers both.
	run("picom", "picom --config ~/.config/picom/picom.conf --animations")
end

-- One shell for the lot, rather than one per line as before.
awful.spawn.with_shell(table.concat(commands, "\n"))

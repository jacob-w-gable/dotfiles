-- Programs and input settings applied once at login.
--
-- Skipped entirely when AWESOME_NO_AUTOSTART is set. Several entries pkill a
-- program before restarting it, and pkill is not scoped to a display - run
-- from a nested X server (Xephyr) they would reach out and kill the copy
-- belonging to the real session. Testing this config in Xephyr is only safe
-- with the variable set.

local awful = require("awful")
local settings = require("config")
local apps = require("config.apps")

if os.getenv("AWESOME_NO_AUTOSTART") then
	return
end

-- The session PATH comes from the display manager by way of PAM, not a login
-- shell, so it can be missing directories an interactive shell has. On this
-- machine /etc/environment appends with "$PATH:...", which PAM does not expand,
-- so the session loses /usr/local/bin entirely. Anything guarded on
-- `command -v` would then be skipped even though it is installed.
local commands = {
	'PATH="$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin"',
}

--- Queue a command, guarded on its binary being installed.
--
-- The guard adds no process: these already run through a shell, so
-- `command -v` is a builtin, and a machine without pasystray skips it.
--
-- Each command is backgrounded because they share one shell. The tray applets
-- do not exit, so in the foreground the first would block every command after
-- it.
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
--
-- The lock screen image is rebuilt first, so a wallpaper or a monitor layout
-- that changed while Awesome was not running is picked up. It is a no-op when
-- the cached image already matches, and it is guarded on convert because that
-- is the binary the script needs.
run("convert", "$HOME/.config/awesome/theme/lockscreen")
restart("xss-lock", "xss-lock -l -- " .. apps.lock_command())

-- Screenshot daemon.
restart("flameshot")

-- Touch gestures. touchegg.service runs the daemon as root, but the actions it
-- is configured with are executed by a client inside the X session, so both
-- halves have to be running. The pkill is scoped to this user so it cannot
-- reach the root daemon.
run("touchegg", 'pkill -u "$(id -u)" touchegg; touchegg')

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
	-- By name, not by path: the installer builds picom into /usr/local/bin, and
	-- a distro package puts it in /usr/bin.
	run("picom", "picom --config ~/.config/picom/picom.conf --animations")

	-- Say so when it is missing. The guard skips a program silently, which is
	-- right for a tray applet and wrong for the compositor: settings.compositor
	-- is an explicit request, and its absence is visible on every window.
	commands[#commands + 1] = table.concat({
		"command -v picom >/dev/null ||",
		'notify-send -u critical "picom not found"',
		'"settings.compositor is on, but no picom is on PATH."',
	}, " ")
end

-- One shell for the lot.
awful.spawn.with_shell(table.concat(commands, "\n"))

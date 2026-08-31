-- Programs started with the session. Mirrors awesome/autostart.lua.
--
-- Much of what that file does has no counterpart here. picom is the compositor's own
-- job; xset r rate and xinput set-prop are input settings Hyprland owns, so they live
-- in hyprland.lua; and xss-lock is replaced by hypridle. What is left is the tray
-- applets and the bar.
--
-- Run once per compositor run, guarded by a marker in XDG_RUNTIME_DIR.
--
-- The guard is the point. Hyprland raises no usable "session started" event -
-- hyprland.start never fires - so the config itself is the only reliable hook, and it
-- is re-evaluated on every `hyprctl reload`. Without the marker, Mod+R would start a
-- second waybar each time.
--
-- The marker is named for the instance signature rather than being a fixed filename.
-- XDG_RUNTIME_DIR outlives a restart of the compositor whenever any other session for
-- the user is open - an SSH login is enough - so a fixed name would make Hyprland come
-- back with no bar. The signature changes on every compositor run and stays the same
-- across a reload, which is exactly the distinction wanted. This is the same intent as
-- the pkill in awesome/autostart.lua, without reaching outside the session to do it.

local settings = require("config")

--- Start a program, guarded on the binary existing.
--
-- The guard costs nothing - these already go through a shell, where command -v is a
-- builtin - and it keeps a machine without blueman from logging a failure per login.
--
-- Two differences from the awesome version worth noting, both learned the hard way:
--
-- hl.dispatch rather than hl.exec_cmd, because the latter works at config-evaluation
-- time but silently does nothing inside an event callback, which is where this runs.
--
-- No trailing `&`. awesome backgrounds each command because it runs the whole list
-- through one shell, where the first long-lived program would block the rest. Here each
-- command is spawned separately and Hyprland does not wait for it, so the `&` only
-- backgrounds the job inside a shell that then exits - taking the program with it.
--
-- The braces matter: `&&` binds tighter than `;`, so without them a command containing
-- a semicolon is split, and only its first half is guarded.
local function run(bin, command)
	hl.exec_cmd(string.format("command -v %s >/dev/null && { %s; }", bin, command or bin))
end

return function()
	local signature = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or "unknown"
	local marker = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-autostart-" .. signature

	local existing = io.open(marker, "r")
	if existing then
		existing:close()
		return
	end

	local created = io.open(marker, "w")
	if created then
		created:close()
	end

	-- waybar's stylesheet imports pywal's generated colours, and GTK treats a missing
	-- @import as fatal rather than skipping it, so the file has to exist before the bar
	-- starts - on a machine where pywal has never run, it will not. Chained rather than
	-- queued separately because these are spawned, not awaited: as two commands waybar
	-- races the script that writes the file it needs.
	local config_dir = os.getenv("HOME") .. "/.config"
	run("waybar", config_dir .. "/hypr/scripts/ensure-colors; waybar")
	run("hypridle")
	run("dunst")

	-- Wallpaper daemon. hyprpaper rather than swww, which is AUR-only: it takes
	-- preload/wallpaper over hyprctl, so scripts/wallpaper can change the image at
	-- runtime without rewriting a config file.
	run("hyprpaper")

	-- And the image itself. awesome draws the wallpaper from ui/wallpaper.lua as each
	-- screen appears; hyprpaper needs telling once it is listening, which is what the
	-- script waits for.
	local theme = require("theme")
	run("hyprpaper", string.format("%s/.config/hypr/scripts/set-wallpaper %q",
		os.getenv("HOME"), theme.wallpaper))

	-- Tray applets. nm-applet in place of awesome's nm-tray, which is Qt XEmbed and
	-- has no Wayland tray to embed into.
	run("nm-applet", "nm-applet --indicator")
	run("blueman-applet")

	-- Authentication agent, for anything that asks for a password through polkit.
	run("/usr/lib/polkit-kde-authentication-agent-1")

	for _, entry in ipairs(settings.autostart or {}) do
		hl.exec_cmd(entry)
	end
end

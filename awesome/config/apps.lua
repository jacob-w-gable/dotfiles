-- The external programs the config launches, and the window names it matches
-- on, in one place.

local settings = require("config")

local M = {}

M.terminal = "kitty --single-instance"
M.editor = os.getenv("EDITOR") or "nvim"
M.editor_cmd = M.terminal .. " -e " .. M.editor

M.launcher = "rofi -show drun"
M.screenshot = "flameshot gui"

-- brightnessctl where it exists, xbacklight otherwise. xbacklight is
-- deprecated and needs an X Backlight property that current Intel and AMD
-- drivers often do not expose. brightnessctl goes through sysfs and works
-- there. Neither is installed by every distro script, so the choice is made
-- at run time, by the shell that runs the command, so it adds no process.
-- These are shell snippets: run them with spawn.with_shell.
M.brightness_up = "command -v brightnessctl >/dev/null && brightnessctl set 10%+ || xbacklight -inc 10"
M.brightness_down = "command -v brightnessctl >/dev/null && brightnessctl set 10%- || xbacklight -dec 10"

M.volume_up = "pactl set-sink-volume @DEFAULT_SINK@ +2%"
M.volume_down = "pactl set-sink-volume @DEFAULT_SINK@ -2%"
M.volume_mute = "pactl set-sink-mute @DEFAULT_SINK@ toggle"

M.media_play = "playerctl play-pause"
M.media_next = "playerctl next"
M.media_prev = "playerctl previous"

-- Window names and classes matched by rules and by solo mode. Kept here so the
-- same string is not spelled out in three places.
M.wallpaper_popout_name = "Wallpaper Pop-out"
M.image_viewer_class = "Nsxiv"
M.centered_dialog_name = "Open Files"

-- The on-screen keyboard, matched by rules.lua and pinned by signals.lua.
M.osk_class = "Onboard"

--- Build the i3lock invocation.
--
-- A function rather than a constant because it reads theme colours, so it can
-- only be built after beautiful.init has run.
function M.lock_command()
	local beautiful = require("beautiful")

	-- i3lock wants bare hex, no leading '#'.
	local fg = beautiful.fg_focus:sub(2)
	local hl = beautiful.bg_focus:sub(2)
	local bg = beautiful.bg_normal:sub(2)

	return "i3lock -i "
		.. settings.lock_screen_wallpaper
		.. " -F -f --indicator --clock"
		.. " --ring-color="
		.. bg
		.. " --ringver-color="
		.. fg
		.. " --insidever-color="
		.. bg
		.. " --insidewrong-color="
		.. bg
		.. " --verif-color="
		.. fg
		.. " --wrong-color="
		.. fg
		.. " --time-color="
		.. fg
		.. " --date-color="
		.. hl
		.. " --greeter-color="
		.. hl
		.. " --layout-color="
		.. hl
		.. " --keyhl-color="
		.. fg
		.. ' --time-str="%H:%M" --date-str="%A, %Y-%m-%d" --wrong-text="Incorrect" --noinput-text="No input"'
		.. ' --verif-text="Verifying..."'
		.. " --custom-key-commands"
		.. ' --cmd-media-play "'
		.. M.media_play
		.. '"'
		.. ' --cmd-media-next "'
		.. M.media_next
		.. '"'
		.. ' --cmd-media-prev "'
		.. M.media_prev
		.. '"'
		.. ' --cmd-volume-up "'
		.. M.volume_up
		.. '"'
		.. ' --cmd-volume-down "'
		.. M.volume_down
		.. '"'
		.. ' --cmd-audio-mute "'
		.. M.volume_mute
		.. '"'
		.. ' --cmd-brightness-up "'
		.. M.brightness_up
		.. '"'
		.. ' --cmd-brightness-down "'
		.. M.brightness_down
		.. '"'
end

return M

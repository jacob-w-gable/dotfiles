-- The external programs the config launches, in one place.
--
-- The AwesomeWM counterpart is awesome/config/apps.lua. Several entries change binary
-- on Wayland even though the job is the same: flameshot cannot grab a Wayland screen,
-- and xset/xinput have no equivalent because the compositor owns those settings.

local settings = require("config")

local M = {}

M.terminal = settings.terminal
M.launcher = settings.launcher
M.runner = settings.runner

-- grim captures, slurp picks the region. Together they are what flameshot did.
M.screenshot_region = "grim -g \"$(slurp)\" - | wl-copy"
M.screenshot_screen = 'grim - | wl-copy'

-- brightnessctl only. awesome keeps an xbacklight fallback, which is X11-only and
-- deprecated besides, so there is nothing to fall back to here.
M.brightness_up = "brightnessctl set 10%+"
M.brightness_down = "brightnessctl set 10%-"

M.volume_up = "pactl set-sink-volume @DEFAULT_SINK@ +2%"
M.volume_down = "pactl set-sink-volume @DEFAULT_SINK@ -2%"
M.volume_mute = "pactl set-sink-mute @DEFAULT_SINK@ toggle"

M.media_play = "playerctl play-pause"
M.media_next = "playerctl next"
M.media_prev = "playerctl previous"

M.lock = "loginctl lock-session"

-- Scripts kept beside their configs rather than on PATH, so they follow the
-- ~/.config symlinks instead of assuming the repo is at ~/dotfiles.
M.wallpaper = os.getenv("HOME") .. "/.config/hypr/scripts/wallpaper"

-- Caffeine lives with the bar because it is a bar widget with a click action; Mod+C
-- drives the same script so the glyph and the inhibitor cannot disagree.
M.caffeine = os.getenv("HOME") .. "/.config/waybar/scripts/caffeine toggle"

-- Window classes matched by rules.lua. Kept here so the same string is not spelled out
-- in two places.
M.image_viewer_class = "imv"

return M

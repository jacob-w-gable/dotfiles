#!/usr/bin/env bash
#
# Run a variant in a nested X server and screenshot it, twice: once on an empty
# tag so the bar and the wallpaper are both readable, once with windows open.
#
# Autostart is skipped, because several of its entries pkill a program by name
# and pkill is not scoped to a display: from in here they would kill the copy
# belonging to the real session.
#
# For a session you can type into, use xephyr-run.sh.
#
# Usage: xephyr-test.sh [dwmblocks|polybar] [output.png]

set -euo pipefail

readonly here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$here/session-lib.sh"

readonly variant=${1:-dwmblocks}
readonly out=${2:-$dotfiles/screenshots/dwm-$variant.png}
readonly geometry=1920x1080
readonly dpi=144

trap stop_session EXIT

pick_display
start_xephyr "$geometry" "$dpi"
setup_display "$dpi"
start_wm
start_bar "$variant"
start_compositor

shoot() {
    maim -u "$1" 2>/dev/null || import -window root "$1"
    printf 'wrote %s\n' "$1"
}

# Give the status scripts a poll or two to fill in before the first shot.
sleep 8

# An empty tag first, so the bar and the wallpaper are both readable. Tiling
# fills the screen as soon as there is a window, and the bar is the thing being
# compared here.
shoot "${out%.png}-bare.png"

# Plain kitty, never --single-instance: that socket is per user, not per
# display, so it would open the window on the real session instead.
spawn_term() {
    kitty --title "$1" --override confirm_os_window_close=0 \
        --override "font_size=$2" sh -c "$3" >/dev/null 2>&1 &
    session_pids+=($!)
    sleep 2
}

spawn_term editor 11 "ls --color=always -la $dotfiles/bin; exec sh"
spawn_term monitor 8 'btop 2>/dev/null || top'

sleep 3
shoot "$out"

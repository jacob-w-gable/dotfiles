#!/usr/bin/env bash
#
# Run this dwm config in a nested X server and screenshot it.
#
# Autostart is skipped, because several of its entries pkill a program by name
# and pkill is not scoped to a display: from in here they would kill the copy
# belonging to the real session.
#
# Usage: xephyr-test.sh [dwmblocks|polybar] [output.png]

set -euo pipefail

readonly variant=${1:-dwmblocks}
readonly out=${2:-$PWD/dwm-$variant.png}
readonly display=:7
readonly geometry=1920x1080
readonly dpi=144

readonly dotfiles=${DOTFILES:-$HOME/dotfiles}
export PATH="$HOME/.local/bin:$dotfiles/bin:${POLYBAR_BIN:-}:$PATH"

pids=()
cleanup() {
    local pid
    for pid in "${pids[@]:-}"; do
        [[ -n $pid ]] && kill "$pid" 2>/dev/null || true
    done
    wait 2>/dev/null || true
}
trap cleanup EXIT

Xephyr -br -ac -noreset -screen "$geometry" -dpi "$dpi" "$display" >/dev/null 2>&1 &
pids+=($!)

# Xephyr takes a moment to accept connections, and every command below fails if
# it is not listening yet.
for _ in {1..50}; do
    DISPLAY=$display xdpyinfo >/dev/null 2>&1 && break
    sleep 0.1
done

export DISPLAY=$display

xrdb -merge <(printf 'Xft.dpi: %s\n' "$dpi")
[[ -r $HOME/.cache/wal/colors.Xresources ]] &&
    xrdb -merge "$HOME/.cache/wal/colors.Xresources"

if [[ -r $HOME/.cache/wal/colors.sh ]]; then
    wallpaper=$(sed -n "s/^wallpaper=['\"]\\(.*\\)['\"]$/\\1/p" "$HOME/.cache/wal/colors.sh")
    [[ -r ${wallpaper:-} ]] && feh --bg-fill "$wallpaper"
fi

dwm >/dev/null 2>&1 &
pids+=($!)
sleep 1

if [[ $variant == polybar ]]; then
    xsetroot -name " "
    DWM_BAR=polybar polybar --config="$dotfiles/polybar/config.ini" main >/dev/null 2>&1 &
    pids+=($!)
else
    dwmblocks >/dev/null 2>&1 &
    pids+=($!)
fi

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
    pids+=($!)
    sleep 2
}

spawn_term editor 11 "ls --color=always -la $dotfiles/bin; exec sh"
spawn_term monitor 8 'btop 2>/dev/null || top'

sleep 3
shoot "$out"

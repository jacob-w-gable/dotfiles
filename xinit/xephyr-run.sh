#!/usr/bin/env bash
#
# Open the dwm prototype in a nested X server and hand it the keyboard.
#
# Safe to run from inside the awesome session. Autostart is skipped: several of
# its entries pkill a program by name, and pkill is not scoped to a display, so
# from in here they would kill the copy belonging to the real session. That
# means no tray applets, no xss-lock and no picom in this window.
#
# Super+Shift+s is the other binding to leave alone while nested: it asks the
# flameshot daemon for a capture, and that daemon belongs to the real session.
#
# The session ends when dwm exits, which Mod+Shift+q does, or when the Xephyr
# window is closed.
#
# Usage: xephyr-run.sh [dwmblocks|polybar] [WIDTHxHEIGHT]

set -euo pipefail

readonly here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$here/session-lib.sh"

readonly variant=${1:-dwmblocks}
readonly geometry=${2:-1600x900}
readonly dpi=${DWM_DPI:-144}

case $variant in
    dwmblocks|polybar) ;;
    *) echo "usage: ${0##*/} [dwmblocks|polybar] [WIDTHxHEIGHT]" >&2; exit 2 ;;
esac

if [[ $variant == polybar ]] && ! command -v polybar >/dev/null; then
    echo "polybar is not installed. Install it, or point POLYBAR_BIN at a" >&2
    echo "directory containing the binary." >&2
    exit 1
fi

trap stop_session EXIT

pick_display

cat <<EOF

  dwm prototype, $variant, on $session_display

  Ctrl+Shift        Grab the keyboard and mouse, with the pointer over the
                    window. Do this first: without it awesome answers Super
                    itself and dwm never sees it. Ctrl+Shift again releases.
                    Xephyr reports the current state in its title bar.

  Super+Return      terminal              Super+j / k       focus down / up
  Super+p           rofi drun             Super+Shift+j / k move in the stack
  Super+Ctrl+r      rofi run              Super+h / l       master width
  Super+1..4        tag                   Super+Shift+h / l master count
  Super+Shift+1..4  move window to tag    Super+space       next layout
  Super+Left/Right  previous / next tag   Super+Shift+space previous layout
  Super+Shift+c     close window          Super+m           monocle
  Super+f           fullscreen            Super+Ctrl+space  float
  Super+b           toggle dwm's bar      Super+Ctrl+Return move to master
  Super+Shift+p     hide the pomodoro     Super+u           jump to urgent

  Status blocks are clickable: the clock pops a calendar, the pomodoro
  starts and pauses, the volume block mutes and scrolls.

  Super+Shift+q     quit, which ends this session

EOF

# No -title: Xephyr's own title says which display this is and whether it
# currently holds the grab, and setting one replaces that.
start_xephyr "$geometry" "$dpi" -resizeable
setup_display "$dpi"
start_wm
start_bar "$variant"

# One terminal to start with, so the session is usable straight away. Plain
# kitty, never --single-instance: that socket is per user, not per display, so
# it would open the window on the real session instead.
kitty --override confirm_os_window_close=0 >/dev/null 2>&1 &
session_pids+=($!)

# Hold until dwm exits. Mod+Shift+q gets there, and so does closing the window,
# which takes the server down and dwm with it.
wait "$dwm_pid" 2>/dev/null || true
echo "session ended"

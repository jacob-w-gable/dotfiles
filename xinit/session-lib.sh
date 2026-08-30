#!/usr/bin/env bash
#
# Shared setup for the nested sessions. Source this, do not run it.
#
# xephyr-run.sh and xephyr-test.sh both need a nested X server with the theme
# loaded, dwm running and a bar attached. The only difference is what they do
# once it is up, so the setup lives here and the two entry points stay short.

# Xephyr draws its window on the real display, so it has to be started with
# DISPLAY pointing there. Everything after it talks to the nested server.
readonly host_display=${DISPLAY:-:0}
readonly dotfiles=${DOTFILES:-$HOME/dotfiles}

export PATH="$HOME/.local/bin:$dotfiles/bin:${POLYBAR_BIN:-}:$PATH"

session_pids=()
session_display=

# Pick a display number nothing is using. Killing an Xephyr leaves its
# /tmp/.X<n>-lock behind, and a new server on that number refuses to start
# while it is there, so a fixed number breaks on the second run.
pick_display() {
    local n
    for n in $(seq 7 32); do
        [[ -e /tmp/.X$n-lock ]] && continue
        [[ -e /tmp/.X11-unix/X$n ]] && continue
        session_display=:$n
        return 0
    done
    echo "no free display number between :7 and :32" >&2
    return 1
}

# Start the nested server and wait for it to accept connections. Every command
# after this fails if it is not listening yet.
start_xephyr() {
    # Prefixed names throughout, because a caller declares geometry, dpi and
    # variant readonly at global scope and a plain `local` on those fails.
    local _geometry=$1 _dpi=$2
    shift 2

    DISPLAY=$host_display \
        Xephyr -br -ac -noreset -screen "$_geometry" -dpi "$_dpi" \
            "$@" "$session_display" >/dev/null 2>&1 &
    session_pids+=($!)

    local i
    for i in {1..80}; do
        DISPLAY=$session_display xdpyinfo >/dev/null 2>&1 && return 0
        sleep 0.1
    done
    echo "Xephyr did not come up on $session_display" >&2
    return 1
}

# Load the theme the same way xinitrc.dwm does: pinned DPI, then the pywal
# palette for polybar to read, then the wallpaper.
setup_display() {
    local _dpi=$1 wallpaper

    export DISPLAY=$session_display
    xrdb -merge <(printf 'Xft.dpi: %s\n' "$_dpi")
    [[ -r $HOME/.cache/wal/colors.Xresources ]] &&
        xrdb -merge "$HOME/.cache/wal/colors.Xresources"

    if [[ -r $HOME/.cache/wal/colors.sh ]]; then
        wallpaper=$(sed -n "s/^wallpaper=['\"]\\(.*\\)['\"]$/\\1/p" \
            "$HOME/.cache/wal/colors.sh")
        [[ -r ${wallpaper:-} ]] && feh --bg-fill "$wallpaper"
    fi
    return 0
}

# Start dwm and record its pid in dwm_pid, so a caller can wait on it.
dwm_pid=
start_wm() {
    dwm >/dev/null 2>&1 &
    dwm_pid=$!
    session_pids+=("$dwm_pid")
    sleep 1
}

start_bar() {
    local _variant=$1

    if [[ $_variant == polybar ]]; then
        # dwm's own bar keeps the tags, the layout symbol and the systray, and
        # shows no status text. A single space rather than an empty string:
        # dwm falls back to printing its version when WM_NAME has no items.
        xsetroot -name " "
        DWM_BAR=polybar \
            polybar --config="$dotfiles/polybar/config.ini" main >/dev/null 2>&1 &
    else
        dwmblocks >/dev/null 2>&1 &
    fi
    session_pids+=($!)
}

stop_session() {
    local pid
    for pid in "${session_pids[@]:-}"; do
        [[ -n $pid ]] && kill "$pid" 2>/dev/null
    done
    # Xephyr can outlive a TERM to the job that started it, and a survivor
    # holds the display number against the next run.
    [[ -n $session_display ]] &&
        pkill -f "Xephyr .* $session_display\$" 2>/dev/null
    return 0
}

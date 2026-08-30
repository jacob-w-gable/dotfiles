#!/usr/bin/env bash
#
# Measure what each bar costs, in a nested X server.
#
# CPU is read from a cgroup rather than from /proc. dwmblocks reaps its script
# children through a signalfd, so their CPU never lands in its own cutime and
# reading /proc/<pid>/stat undercounts it by more than an order of magnitude.
# Running each bar in its own systemd scope counts every descendant, which is
# the only fair comparison: most of what a dwmblocks bar does happens in short
# lived shells, and most of what polybar does happens in polybar.
#
# Resident memory still comes from /proc/<pid>/status, plus the script children
# polybar keeps alive.
#
# Usage: bench.sh [seconds]

set -euo pipefail

readonly seconds=${1:-90}
next_display=9

# Xephyr opens its window on the real display, so it has to be started with
# DISPLAY pointing there. Everything after it runs against the nested server,
# and measure() exports DISPLAY as it goes.
readonly host_display=${DISPLAY:-:0}
readonly dotfiles=${DOTFILES:-$HOME/dotfiles}
export PATH="$HOME/.local/bin:$dotfiles/bin:${POLYBAR_BIN:-}:$PATH"

rss_kb() { awk '/^VmRSS:/ {print $2}' "/proc/$1/status" 2>/dev/null || echo 0; }

# Total CPU microseconds for every process in the scope, descendants included.
cgroup_usec() {
    local dir=$1
    [[ -r $dir/cpu.stat ]] || { echo 0; return; }
    awk '/^usage_usec/ {print $2}' "$dir/cpu.stat"
}

# systemd places a user scope under app.slice, but the exact path has changed
# between releases, so this searches rather than assuming one.
find_cgroup() {
    find "/sys/fs/cgroup/user.slice/user-$(id -u).slice" \
        -maxdepth 4 -name "$1.scope" -type d 2>/dev/null | head -1
}

# Kill anything left on the test display by an earlier run. Without this a
# surviving Xephyr keeps its dwm, the next run's dwm exits with "another window
# manager is already running", and the measurement silently reports the old
# session. Matching on the display argument keeps this away from the real one.
reset_display() {
    pkill -f "Xephyr .* $display\$" 2>/dev/null || true
    sleep 1
}

measure() {
    local variant=$1
    local dwm_pid xephyr_pid bar_pid unit cg
    local start_usec end_usec dwm_rss bar_rss tree_rss=0 child

    # A fresh display number per variant. Killing an Xephyr leaves its
    # /tmp/.X<n>-lock behind, and the next server on that number refuses to
    # start while it is there.
    display=:$next_display
    next_display=$((next_display + 1))

    reset_display

    DISPLAY=$host_display \
        Xephyr -br -ac -noreset -screen 1920x1080 -dpi 144 "$display" >/dev/null 2>&1 &
    xephyr_pid=$!
    for _ in {1..50}; do
        DISPLAY=$display xdpyinfo >/dev/null 2>&1 && break
        sleep 0.1
    done

    export DISPLAY=$display
    xrdb -merge <(printf 'Xft.dpi: 144\n')
    [[ -r $HOME/.cache/wal/colors.Xresources ]] &&
        xrdb -merge "$HOME/.cache/wal/colors.Xresources"

    dwm >/dev/null 2>&1 &
    dwm_pid=$!
    sleep 1

    unit=dwmbench-$variant-$$
    if [[ $variant == polybar ]]; then
        xsetroot -name " "
        systemd-run --user --scope --quiet --unit="$unit" --collect \
            polybar --config="$dotfiles/polybar/config.ini" main >/dev/null 2>&1 &
    else
        systemd-run --user --scope --quiet --unit="$unit" --collect \
            dwmblocks >/dev/null 2>&1 &
    fi
    sleep 3

    cg=$(find_cgroup "$unit")
    [[ -n $cg ]] || { echo "$variant: no cgroup found, skipping"; return; }

    # Let both settle before sampling, so start-up work is excluded.
    sleep 2
    start_usec=$(cgroup_usec "$cg")
    sleep "$seconds"
    end_usec=$(cgroup_usec "$cg")

    bar_pid=$(pgrep -x "$([[ $variant == polybar ]] && echo polybar || echo dwmblocks)" | head -1)
    dwm_rss=$(rss_kb "$dwm_pid")
    bar_rss=$(rss_kb "${bar_pid:-0}")
    for child in $(pgrep -P "${bar_pid:-0}" 2>/dev/null || true); do
        tree_rss=$((tree_rss + $(rss_kb "$child")))
    done

    awk -v v="$variant" -v d="$dwm_rss" -v b="$bar_rss" -v c="$tree_rss" \
        -v u="$((end_usec - start_usec))" -v s="$seconds" 'BEGIN {
        printf "%-10s  dwm %6.1f MB   bar %6.1f MB (+%.1f MB children)   CPU %6.2f s = %5.2f%% of a core\n",
            v, d/1024, b/1024, c/1024, u/1e6, (u/1e6)/s*100
    }'

    systemctl --user stop "$unit.scope" >/dev/null 2>&1 || true
    kill "$dwm_pid" 2>/dev/null || true
    kill "$xephyr_pid" 2>/dev/null || true
    sleep 1
    reset_display
}

printf 'sampling %s seconds per variant\n\n' "$seconds"
measure dwmblocks
measure polybar

# The running awesome session, for reference. Its widgets run in process, so
# there are no children to account for.
if awesome_pid=$(pgrep -x awesome | head -1); then
    awk -v r="$(rss_kb "$awesome_pid")" 'BEGIN {
        printf "\n%-10s  rss %6.1f MB (running session: window manager, bar and widgets in one process)\n",
            "awesome", r/1024
    }'
fi

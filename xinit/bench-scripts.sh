#!/usr/bin/env bash
#
# Measure what one invocation of each status script consumes.
#
# Both bars run the same scripts, so this is the part of the cost neither bar
# engine can avoid. Multiply a script's cost by how often its block polls to
# see what it contributes: the block that runs every second dominates
# everything else put together.
#
# Usage: bench-scripts.sh [runs]

set -euo pipefail

readonly runs=${1:-40}
readonly dotfiles=${DOTFILES:-$HOME/dotfiles}
export PATH="$dotfiles/bin:$PATH"

# Interval in seconds each block polls at, from dwmblocks/config.h. 0 means the
# block only redraws when signalled, so it contributes nothing while idle.
declare -A interval=(
    [dwm-cpu]=2 [dwm-mem]=5 [dwm-temp]=7 [dwm-pomodoro]=1
    [dwm-caffeine]=0 [dwm-mpris]=3 [dwm-volume]=10
    [dwm-battery]=61 [dwm-weather]=900 [dwm-clock]=30
)

printf '%-14s %9s %11s %14s\n' script 'ms/run' 'poll (s)' 'ms/min of bar'
printf '%-14s %9s %11s %14s\n' -------------- --------- ----------- --------------

total_per_min=0
for script in dwm-cpu dwm-mem dwm-temp dwm-pomodoro dwm-caffeine dwm-mpris \
              dwm-volume dwm-battery dwm-weather dwm-clock; do
    # TIMEFORMAT makes bash's own `time` print just the child user and system
    # seconds, on stderr. Dividing by the run count gives the per-run cost
    # including fork, exec and interpreter start-up.
    TIMEFORMAT='%U %S'
    read -r user sys <<< "$(
        { time (
            for ((i = 0; i < runs; i++)); do
                "$script" >/dev/null 2>&1 || true
            done
        ); } 2>&1 1>/dev/null
    )"

    poll=${interval[$script]}
    read -r per_run per_min <<< "$(awk -v u="$user" -v s="$sys" -v n="$runs" -v p="$poll" \
        'BEGIN { r = (u + s) * 1000 / n; printf "%.2f %.1f", r, (p > 0 ? r * 60 / p : 0) }')"

    printf '%-14s %9s %11s %14s\n' "$script" "$per_run" "$poll" "$per_min"
    total_per_min=$(awk -v a="$total_per_min" -v b="$per_min" 'BEGIN {print a + b}')
done

printf '\n%-14s %35s ms of CPU per minute, scripts only\n' total "$total_per_min"

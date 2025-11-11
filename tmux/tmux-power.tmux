#!/usr/bin/env bash

tmux_get() {
  local v
  v="$(tmux show -gqv "$1")"
  [ -n "$v" ] && echo "$v" || echo "$2"
}
tmux_set() { tmux set-option -gq "$1" "$2"; }

# ---- Options you can change from tmux.conf ----
RARROW="$(tmux_get '@tmux_power_right_arrow_icon' '')"
LARROW="$(tmux_get '@tmux_power_left_arrow_icon' '')"
THEME="$(tmux_get '@tmux_power_theme' 'colour14')" # accepts 'colour14', 'color14', or '#rrggbb'
TIME_FMT="$(tmux_get '@tmux_power_time_format' '%T')"
DATE_FMT="$(tmux_get '@tmux_power_date_format' '%F')"

# map common values
case "$THEME" in
color*) THEME="${THEME/color/colour}" ;;
gold) THEME='#ffb86c' ;;
redwine) THEME='#b34a47' ;;
moon) THEME='#00abab' ;;
forest) THEME='#228b22' ;;
violet) THEME='#9370db' ;;
snow) THEME='#fffafa' ;;
coral) THEME='#ff7f50' ;;
sky) THEME='#87ceeb' ;;
everforest) THEME='#a7c080' ;;
esac

# ---- Palette (fixed greys; tweak if you like) ----
G0="#262626" # bar bg
G1="#303030" # session pill bg
G2="#3a3a3a" # inactive tab bg
G3="#444444" # IP slice bg
G4="#626262" # light grey fg
TAB_FG="#e6e6e6"

# ---- Bar / layout ----
tmux_set status on
tmux_set status-interval 1
tmux_set status-bg "$G0"
tmux_set status-fg "$G4"
tmux_set status-attr none
tmux_set status-justify "centre"
tmux_set window-status-separator " "

# ---- LEFT: user@host (primary) → IP slice (attached) → session pill ----
USER_ICON=""
SESSION_ICON=""
IP_CMD='#(ip route get 8.8.8.8 | awk "/src/ {for (i=1;i<=NF;i++) if (\$i==\"src\") print \$(i+1)}")'

LS="" # primary pill
LS+="#[fg=$G0,bg=$THEME,bold] $USER_ICON $(whoami)@#h "
LS+="#[fg=$THEME,bg=$G3]$RARROW"   # attach into IP slice
LS+="#[fg=$THEME,bg=$G3] $IP_CMD " # IP text on G3, in THEME color
LS+="#[fg=$G3,bg=$G1]$RARROW"      # IP slice -> session pill
LS+="#[fg=$THEME,bg=$G1] $SESSION_ICON #S "
LS+="#[fg=$G1,bg=$G0]$RARROW" # back to bar

tmux_set status-left-length 120
tmux_set status-left "$LS"

# ---- RIGHT: CPU | RAM | time | date via tmux-cpu scripts ----
CPU_ICON=" "
MEM_ICON=" "
TIME_ICON=""
DATE_ICON=""

# Paths
TPM_DIR="$HOME/.tmux/plugins"
TMUX_CPU_DIR="$TPM_DIR/tmux-cpu"

# Use the plugin's scripts directly, and escape % -> %%
CPU_CMD='#('"$TMUX_CPU_DIR"'/scripts/cpu_percentage.sh | sed "s/%/%%/g")'
MEM_CMD='#('"$TMUX_CPU_DIR"'/scripts/ram_percentage.sh | sed "s/%/%%/g")'
CPU_FG_COLOR='#('"$TMUX_CPU_DIR"'/scripts/cpu_fg_color.sh)'
RAM_FG_COLOR='#('"$TMUX_CPU_DIR"'/scripts/ram_fg_color.sh)'

RS=""
RS+="#[fg=$G1]$LARROW#[fg=$THEME,bg=$G1]$CPU_FG_COLOR $CPU_ICON $CPU_CMD "
RS+="#[fg=$THEME,bg=$G1]$RAM_FG_COLOR $MEM_ICON $MEM_CMD "
RS+="#[fg=$G3]$LARROW#[fg=$THEME,bg=$G3] $TIME_ICON $TIME_FMT "
RS+="#[fg=$THEME,bg=$G2]$LARROW#[fg=$G0,bg=$THEME] $DATE_ICON $DATE_FMT "

tmux_set status-right-length 160
tmux_set status-right "$RS"
tmux refresh-client -S

# ---- WINDOWS (center pills): active = primary, inactive = grey ----
tmux_set window-status-style "fg=$THEME,bg=$G0,none"
tmux_set window-status-activity-style "fg=$THEME,bg=$G0,bold"
tmux_set window-status-last-style "fg=$THEME,bg=$G0,bold"

# inactive
tmux_set window-status-format \
  "#[nobold,noitalics,nounderscore]#[fg=$G2,bg=$G0]$LARROW#[fg=$TAB_FG,bg=$G2]  #I:#W#F  #[fg=$G2,bg=$G0]$RARROW"

# active
tmux_set window-status-current-format \
  "#[bold]#[fg=$THEME,bg=$G0]$LARROW#[fg=$G0,bg=$THEME]  #I:#W#F  #[fg=$THEME,bg=$G0]$RARROW"

# ---- Borders/messages (kept simple) ----
tmux_set pane-border-style "fg=$G3,bg=default"
tmux_set pane-active-border-style "fg=$THEME,bg=default"
tmux_set message-style "fg=$THEME,bg=$G0"
tmux_set message-command-style "fg=$THEME,bg=$G0"
tmux_set clock-mode-colour "$THEME"
tmux_set clock-mode-style 24

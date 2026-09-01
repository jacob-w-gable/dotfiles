#!/usr/bin/env bash
# Install the pywal-generated Onboard color scheme and select it.
#
# wal renders wal/templates/Pywal.colors to ~/.cache/wal/Pywal.colors on every
# wallpaper change; Onboard only reads themes from its own data directory, so
# copy both halves of the theme there and point Onboard at them.
set -euo pipefail

# Resolved physically, so this works both from the repo and through the
# ~/.config/awesome symlink - a logical `cd ..` from the symlinked path would
# climb out of ~/.config instead of the repo.
dotfiles_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
cache_colors="$HOME/.cache/wal/Pywal.colors"
theme_dir="$HOME/.local/share/onboard/themes"

if [ ! -f "$cache_colors" ]; then
  echo "No generated colors at $cache_colors (run wal first); skipping." >&2
  exit 0
fi

mkdir -p "$theme_dir"
cp "$cache_colors" "$theme_dir/Pywal.colors"
cp "$dotfiles_dir/onboard/Pywal.theme" "$theme_dir/Pywal.theme"

gsettings set org.onboard theme "$theme_dir/Pywal.theme"

# Onboard reads the color scheme at startup, so restart it if it is running.
if pgrep -x onboard >/dev/null 2>&1; then
  pkill -x onboard
  setsid onboard >/dev/null 2>&1 &
fi

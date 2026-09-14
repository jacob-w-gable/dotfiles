#!/usr/bin/env bash
# Link the tracked configuration into $HOME.
#
# Nothing here needs root: every target is inside the invoking user's home.
# Existing config is moved aside rather than deleted, so a run on a machine that
# already had a setup is recoverable.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

mkdir -p "$HOME/.config" "$HOME/.tmux"

# "<path in the repository>:<target in $HOME>"
LINKS=(
  "nvim:$HOME/.config/nvim"
  "ranger:$HOME/.config/ranger"
  "btop:$HOME/.config/btop"
  "zsh/.zshrc-core:$HOME/.zshrc-core"
  "zsh/.p10k.zsh:$HOME/.p10k.zsh"
  "zsh/.p10k-tty.zsh:$HOME/.p10k-tty.zsh"
  "tmux/.tmux.conf:$HOME/.tmux.conf"
  "tmux/tmux-power.tmux:$HOME/.tmux/tmux-power.tmux"
)

for link in "${LINKS[@]}"; do
  source_path="$REPO_ROOT/${link%%:*}"
  target_path="${link#*:}"

  if [[ ! -e "$source_path" ]]; then
    echo "Missing in repository: $source_path" >&2
    exit 1
  fi

  backup_path "$target_path"
  ln -s "$source_path" "$target_path"
  echo "  linked $target_path"
done

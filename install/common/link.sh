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
  "tmux/claude:$HOME/.tmux/claude"
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

# Register the Claude Code SessionStart hook that tags each tmux pane with its
# session id, so tmux-resurrect can resume the right conversation (see
# tmux/claude). Merged into the existing settings rather than linked, because
# Claude Code writes to this file itself. Adding it again is a no-op.
python3 - "$HOME/.claude/settings.json" <<'PY'
import json, os, sys

path = sys.argv[1]
command = "~/.tmux/claude/tag-session"

settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)

groups = settings.setdefault("hooks", {}).setdefault("SessionStart", [])
if any(h.get("command") == command for g in groups for h in g.get("hooks", [])):
    sys.exit(0)

groups.append({"hooks": [{"type": "command", "command": command}]})
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path + ".tmp", "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
os.replace(path + ".tmp", path)
print(f"  registered Claude tag-session hook in {path}")
PY

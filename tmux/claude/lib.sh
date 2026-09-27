# Shared by the Claude Code tmux-resurrect scripts in this directory. Sourced,
# not run.

# Print the save file tmux-resurrect's `last` link points to, the save a restore
# reads. Mirrors resurrect's own lookup: @resurrect-dir, then ~/.tmux/resurrect
# when it exists, then the XDG data directory.
resurrect_last_save() {
  local dir
  dir="$(tmux show-option -gqv @resurrect-dir)"
  if [[ -z "$dir" ]]; then
    if [[ -d "$HOME/.tmux/resurrect" ]]; then
      dir="$HOME/.tmux/resurrect"
    else
      dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
    fi
  fi
  dir="${dir//\$HOME/$HOME}"
  dir="${dir/#\~/$HOME}"
  readlink -f "$dir/last"
}

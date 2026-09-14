#!/usr/bin/env bash
# Shared helpers for the install scripts.
#
# This file is sourced, never executed. It provides the repository root, the
# architecture names used by upstream release assets, and the backup helper that
# every config-replacing step goes through.

# Resolve the repository root from this file's own location, so the scripts
# behave the same no matter which directory they are invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Each upstream project spells the architecture differently, so every naming
# scheme is resolved once here rather than hardcoded at each download site.
# A wrong name fails silently. GitHub returns a release asset for any
# architecture to any client, and tar unpacks it.
case "$(uname -m)" in
x86_64)
  ARCH_RUST="x86_64"    # eza:     eza_<arch>-unknown-linux-gnu.tar.gz
  ARCH_NVIM="x86_64"    # neovim:  nvim-linux-<arch>.tar.gz
  ARCH_LAZYGIT="x86_64" # lazygit: lazygit_<version>_linux_<arch>.tar.gz
  ;;
aarch64 | arm64)
  ARCH_RUST="aarch64"
  ARCH_NVIM="arm64"
  ARCH_LAZYGIT="arm64"
  ;;
*)
  echo "Unsupported architecture: $(uname -m)" >&2
  exit 1
  ;;
esac

# Move an existing path aside instead of deleting it. Whatever sits at the
# target belongs to whoever put it there, which on a shared machine may not be
# us. A symlink already pointing into this repository is ours by definition, so
# it is replaced outright and repeated runs do not pile up identical backups.
backup_path() {
  local target="$1"

  [[ -e "$target" || -L "$target" ]] || return 0

  if [[ -L "$target" && "$(readlink -f "$target")" == "$REPO_ROOT"/* ]]; then
    rm -f "$target"
    return 0
  fi

  local backup
  backup="$target.bak.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  echo "  backed up $target -> $backup"
}

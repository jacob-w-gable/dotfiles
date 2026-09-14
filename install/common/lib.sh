#!/usr/bin/env bash
# Shared helpers for the install scripts.
#
# This file is sourced, never executed. It provides the architecture names used
# by upstream release assets.

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

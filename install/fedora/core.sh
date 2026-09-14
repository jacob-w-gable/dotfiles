#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

source "$(dirname "${BASH_SOURCE[0]}")/../common/lib.sh"

sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y \
  neovim \
  unzip \
  zsh \
  python3 \
  ranger \
  luarocks \
  gnome-keyring \
  libsecret \
  btop \
  curl \
  wget \
  git \
  bat \
  pipx \
  fd-find \
  ncurses-term \
  vim-enhanced \
  tmux

# Install eza. The tarball contains a bare `eza` binary, so it is unpacked to a
# temporary directory and installed from there rather than untarred straight
# into a package-manager-owned directory.
EZA_VERSION="0.23.4"
EZA_DIR="$(mktemp -d)"
trap 'rm -rf "$EZA_DIR"' EXIT
curl -fsSL -o "$EZA_DIR/eza.tar.gz" \
  "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/eza_$ARCH_RUST-unknown-linux-gnu.tar.gz"
tar -C "$EZA_DIR" -xzf "$EZA_DIR/eza.tar.gz"
sudo install -m 755 "$EZA_DIR/eza" /usr/local/bin/eza

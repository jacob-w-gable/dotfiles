#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

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

# Install eza
wget https://github.com/eza-community/eza/releases/download/v0.23.4/eza_x86_64-unknown-linux-gnu.tar.gz
sudo tar -xzf eza_x86_64-unknown-linux-gnu.tar.gz -C /usr/bin
rm -f eza_x86_64-unknown-linux-gnu.tar.gz

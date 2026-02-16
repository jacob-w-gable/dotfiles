#!/usr/bin/env bash

set -eu

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

# Core system dependencies
sudo pacman -S \
  sudo \
  wget \
  base-devel \
  openssh \
  man-db \
  networkmanager \
  wpa_supplicant \
  --noconfirm
# ...

sudo pacman -S \
  neovim \
  unzip \
  zsh \
  python \
  python-pip \
  ranger \
  luarocks \
  btop \
  gnome-keyring \
  eza \
  bat \
  python-pipx \
  lua53-filesystem \
  tmux \
  --noconfirm

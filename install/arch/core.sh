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
  luarocks \
  lua53 \
  lua51 \
  --noconfirm
# ...

# fd and git are assumed by .zshrc-core and by the AUR clones in gui.sh respectively.
#
# lua53-filesystem is here but luarocks and the interpreters are in the batch above,
# deliberately: this package's install script shells out to luarocks-admin, and pacman
# picks its own order within one transaction, so the tool has to be installed by an
# earlier call rather than merely listed earlier.
sudo pacman -S \
  neovim \
  unzip \
  zsh \
  python \
  python-pip \
  ranger \
  btop \
  gnome-keyring \
  eza \
  bat \
  python-pipx \
  lua53-filesystem \
  fd \
  git \
  tmux \
  --noconfirm

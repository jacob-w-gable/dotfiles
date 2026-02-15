#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

sudo apt install \
  unzip \
  zsh \
  python3 \
  ranger \
  luarocks \
  gnome-keyring \
  libsecret-tools \
  btop \
  eza \
  curl \
  wget \
  git \
  bat \
  pipx \
  fd-find \
  vim \
  tmux \
  -y

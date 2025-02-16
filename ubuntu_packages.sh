#!/usr/bin/env bash

sudo apt install xorg sddm awesome \
  nm-tray pasystray blueman xss-lock flameshot dunst \
  kitty \
  breeze \
  breeze-gtk-theme \
  neovim \
  unzip \
  qt5ct \
  zsh \
  python3 ranger python3-pillow \
  pulseaudio-utils \
  zathura \
  firefox \
  eom \
  luarocks \
  gnome-keyring \
  libsecret-tools \
  qtquickcontrols2-5-dev qml-module-qtgraphicaleffects libqt5svg5-dev \
  qml-module-qtquick-controls2 \
  -y

# For building i3loc-color:
sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev -y

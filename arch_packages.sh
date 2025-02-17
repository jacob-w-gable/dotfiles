#!/usr/bin/env bash

# Core system dependencies
sudo pacman -S \
  sudo \
  wget \
  base-devel \
  openssh \
  man-db \
  networkmanager \
  wpa_supplicant
# ...

sudo pacman -S \
  xorg \
  sddm \
  awesome \
  pasystray \
  blueman \
  xss-lock \
  flameshot \
  dunst \
  kitty \
  breeze \
  neovim \
  unzip \
  qt5ct \
  zsh \
  python \
  python-pillow \
  python-pip \
  ranger \
  zathura \
  firefox \
  eom \
  luarocks \
  btop \
  gnome-keyring \
  qt5-graphicaleffects \
  qt5-quickcontrols \
  qt5-quickcontrols2

yay -S \
  nm-tray \
  breeze-gtk

# For building i3loc-color:
sudo pacman -S \
  autoconf \
  cairo \
  fontconfig \
  gcc \
  libev \
  libjpeg-turbo \
  libxinerama \
  libxkbcommon-x11 \
  libxrandr \
  pam \
  pkgconf \
  xcb-util-image \
  xcb-util-xrm

# Need to manually install vicious library
git clone https://github.com/vicious-widgets/vicious.git
mv vicious ~/.config/awesome

# This doesn't seem to automatically happen in Arch
mkdir -p ~/.config/lazygit
touch ~/.config/lazygit/config.yml

# For building picom
sudo pacman -S --needed libx11 libxcb xorgproto xcb-util xcb-util-image xcb-util-renderutil \
  xcb-util-wm xcb-util-keysyms xcb-util-cursor xcb-util-errors xcb-util-xrm \
  libxdamage libxfixes libxrender libxrandr libxcursor libxcomposite \
  pixman libconfig dbus-glib \
  libglvnd libegl libepoxy pcre2 libev \
  meson cmake uthash

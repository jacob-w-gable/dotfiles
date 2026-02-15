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
  xorg \
  sddm \
  awesome \
  pasystray \
  paprefs \
  pavucontrol \
  alsa-utils \
  alsa-ucm-conf \
  blueman \
  xss-lock \
  flameshot \
  dunst \
  kitty \
  breeze \
  qt5ct \
  python-pillow \
  zathura \
  firefox \
  eom \
  feh \
  qt5-graphicaleffects \
  qt5-quickcontrols \
  qt5-quickcontrols2 \
  rofi \
  imagemagick \
  lua-dkjson \
  nsxiv \
  ueberzug \
  --noconfirm

git clone https://aur.archlinux.org/yay.git
(cd yay && makepkg -si --noconfirm)
rm -rf yay

yay -S \
  nm-tray \
  breeze-gtk \
  vicious \
  --noconfirm

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
  xcb-util-xrm \
  --noconfirm

# Need to manually install vicious library
rm -rf awesome/vicious
git clone https://github.com/vicious-widgets/vicious.git awesome/vicious

# This doesn't seem to automatically happen in Arch
mkdir -p ~/.config/lazygit
touch ~/.config/lazygit/config.yml

# For building picom
sudo pacman -S --needed \
  libx11 \
  libxcb \
  xorgproto \
  xcb-util \
  xcb-util-image \
  xcb-util-renderutil \
  xcb-util-wm \
  xcb-util-keysyms \
  xcb-util-cursor \
  xcb-util-errors \
  xcb-util-xrm \
  libxdamage \
  libxfixes \
  libxrender \
  libxrandr \
  libxcursor \
  libxcomposite \
  pixman \
  libconfig \
  dbus-glib \
  libglvnd \
  libegl \
  libepoxy \
  pcre2 \
  libev \
  meson \
  cmake \
  uthash \
  --noconfirm

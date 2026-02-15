#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

sudo apt install \
  xorg \
  sddm \
  awesome \
  nm-tray \
  pasystray \
  blueman \
  xss-lock \
  flameshot \
  dunst \
  kitty \
  breeze \
  breeze-gtk-theme \
  unzip \
  qt5ct \
  zsh \
  python3 \
  ranger \
  python3-pillow \
  pulseaudio-utils \
  zathura \
  firefox \
  eom \
  luarocks \
  gnome-keyring \
  libsecret-tools \
  btop \
  qtquickcontrols2-5-dev \
  qml-module-qtquick-layouts \
  qml-module-qtgraphicaleffects \
  libqt5svg5-dev \
  qml-module-qtquick-controls2 \
  eza \
  curl \
  wget \
  git \
  rofi \
  bat \
  pipx \
  lua-dkjson \
  nsxiv \
  fd-find \
  kitty-terminfo \
  ncurses-term \
  vim \
  tmux \
  imagemagick \
  -y

# For building i3loc-color:
sudo apt install \
  autoconf \
  gcc \
  make \
  pkg-config \
  libpam0g-dev \
  libcairo2-dev \
  libfontconfig1-dev \
  libxcb-composite0-dev \
  libev-dev \
  libx11-xcb-dev \
  libxcb-xkb-dev \
  libxcb-xinerama0-dev \
  libxcb-randr0-dev \
  libxcb-image0-dev \
  libxcb-util-dev \
  libxcb-xrm-dev \
  libxkbcommon-dev \
  libxkbcommon-x11-dev \
  libjpeg-dev \
  libgif-dev \
  -y

# For building picom
sudo apt install \
  libconfig-dev \
  libdbus-1-dev \
  libegl-dev \
  libev-dev \
  libgl-dev \
  libepoxy-dev \
  libpcre2-dev \
  libpixman-1-dev \
  libx11-xcb-dev \
  libxcb1-dev \
  libxcb-composite0-dev \
  libxcb-damage0-dev \
  libxcb-glx0-dev \
  libxcb-image0-dev \
  libxcb-present-dev \
  libxcb-randr0-dev \
  libxcb-render0-dev \
  libxcb-render-util0-dev \
  libxcb-shape0-dev \
  libxcb-util-dev \
  libxcb-xfixes0-dev \
  meson \
  cmake \
  ninja-build \
  uthash-dev \
  -y

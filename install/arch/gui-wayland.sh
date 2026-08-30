#!/usr/bin/env bash

# Wayland GUI packages: the Hyprland counterpart to gui.sh.
#
# Deliberately smaller than the X11 script. Hyprland composites, locks and takes
# screenshots itself or through its own ecosystem, so picom, xss-lock, i3lock-color and
# flameshot have no place here - and none of them work on Wayland anyway.

set -eu

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

# The compositor and the pieces that replace the X11 session's parts:
#   hyprland     awesome + picom, in one process
#   grim/slurp   flameshot
#   rofi-wayland rofi; the .rasi config carries over unchanged
#   dunst        naughty
#   xorg-xwayland  for anything not yet ported, nsxiv included
sudo pacman -S \
  hyprland \
  hyprlock \
  hypridle \
  hyprsunset \
  waybar \
  kitty \
  grim \
  slurp \
  wl-clipboard \
  rofi-wayland \
  dunst \
  imv \
  hyprpaper \
  xorg-xwayland \
  polkit \
  polkit-kde-agent \
  mesa \
  brightnessctl \
  playerctl \
  pavucontrol \
  network-manager-applet \
  blueman \
  alsa-utils \
  imagemagick \
  jq \
  --noconfirm --needed

# Nerd fonts. Without these every glyph in the config renders as a tofu box.
if [[ ! -d ~/.fonts/HackNerdFont ]]; then
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
  mkdir -p ~/.fonts
  unzip -qo Hack.zip -d ~/.fonts
  rm Hack.zip
fi

if [[ ! -d ~/.fonts/FiraCodeNerdFont ]]; then
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
  unzip -qo FiraCode.zip -d ~/.fonts
  rm FiraCode.zip
fi

fc-cache -f

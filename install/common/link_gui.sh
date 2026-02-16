#!/usr/bin/env bash

set -eu

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

mkdir -p $HOME/.config

rm -rf $HOME/.config/awesome
ln -s $(pwd)/awesome $HOME/.config/awesome

rm -rf $HOME/.config/gtk-3.0
ln -s $(pwd)/gtk-3.0 $HOME/.config/gtk-3.0

rm -rf $HOME/.config/gtk-4.0
ln -s $(pwd)/gtk-4.0 $HOME/.config/gtk-4.0

rm -rf $HOME/.config/kitty
ln -s $(pwd)/kitty $HOME/.config/kitty

rm -rf $HOME/.config/qt5ct
ln -s $(pwd)/qt5ct $HOME/.config/qt5ct

rm -rf $HOME/.config/picom
ln -s $(pwd)/picom $HOME/.config/picom

rm -rf $HOME/.config/rofi
ln -s $(pwd)/rofi $HOME/.config/rofi

rm -rf $HOME/.config/wal
ln -s $(pwd)/wal $HOME/.config/wal

rm -rf $HOME/Scripts/wallpaper
mkdir -p $HOME/Scripts
ln -s $(pwd)/awesome/theme/wallpaper $HOME/Scripts/wallpaper

sudo rm -f /etc/sddm.conf
sudo ln -s $(pwd)/sddm/sddm.conf /etc/sddm.conf

sudo rm -f /usr/share/sddm/themes/simple-sddm/theme.conf
# For some reason symlinks don't work here
sudo cp $(pwd)/sddm/simple-sddm/theme.conf /usr/share/sddm/themes/simple-sddm/theme.conf

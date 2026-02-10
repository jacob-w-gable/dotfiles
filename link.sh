#!/usr/bin/env bash

set -eu

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

mkdir -p $HOME/.config

rm -rf $HOME/.config/nvim
ln -s $(pwd)/nvim $HOME/.config/nvim

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

rm -rf $HOME/.config/ranger
ln -s $(pwd)/ranger $HOME/.config/ranger

ln -s $(pwd)/zsh/.zshrc-core $HOME/.zshrc-core
ln -s $(pwd)/zsh/.p10k.zsh $HOME/.p10k.zsh
ln -s $(pwd)/zsh/.p10k-tty.zsh $HOME/.p10k-tty.zsh

rm -rf $HOME/.config/btop
ln -s $(pwd)/btop $HOME/.config/btop

rm -rf $HOME/.config/picom
ln -s $(pwd)/picom $HOME/.config/picom

rm -rf $HOME/.config/rofi
ln -s $(pwd)/rofi $HOME/.config/rofi

rm -rf $HOME/.config/wal
ln -s $(pwd)/wal $HOME/.config/wal

rm -f $HOME/.tmux.conf
ln -s $(pwd)/tmux/.tmux.conf $HOME/.tmux.conf

mkdir -p $HOME/.tmux
rm -f $HOME/.tmux/tmux-power.tmux
ln -s $(pwd)/tmux/tmux-power.tmux $HOME/.tmux/tmux-power.tmux

rm -rf $HOME/Scripts/wallpaper
mkdir -p $HOME/Scripts
ln -s $(pwd)/awesome/theme/wallpaper $HOME/Scripts/wallpaper

sudo rm -f /etc/sddm.conf
sudo ln -s $(pwd)/sddm/sddm.conf /etc/sddm.conf

sudo rm -f /usr/share/sddm/themes/simple-sddm/theme.conf
# For some reason symlinks don't work here
sudo cp $(pwd)/sddm/simple-sddm/theme.conf /usr/share/sddm/themes/simple-sddm/theme.conf

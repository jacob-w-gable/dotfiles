#!/usr/bin/env bash

mkdir -p $HOME/.config

rm -rf $HOME/.config/nvim || true
ln -s $(pwd)/nvim $HOME/.config/nvim

rm -rf $HOME/.config/awesome || true
ln -s $(pwd)/awesome $HOME/.config/awesome

rm -rf $HOME/.config/gtk-3.0 || true
ln -s $(pwd)/gtk-3.0 $HOME/.config/gtk-3.0

rm -rf $HOME/.config/gtk-4.0 || true
ln -s $(pwd)/gtk-4.0 $HOME/.config/gtk-4.0

rm -rf $HOME/.config/kitty || true
ln -s $(pwd)/kitty $HOME/.config/kitty

rm -rf $HOME/.config/qt5ct || true
ln -s $(pwd)/qt5ct $HOME/.config/qt5ct

rm -rf $HOME/.config/ranger || true
ln -s $(pwd)/ranger $HOME/.config/ranger

ln -s $(pwd)/zsh/.zshrc-core $HOME/.zshrc-core
ln -s $(pwd)/zsh/.p10k.zsh $HOME/.p10k.zsh
ln -s $(pwd)/zsh/.p10k-tty.zsh $HOME/.p10k-tty.zsh

rm -rf $HOME/.config/btop || true
ln -s $(pwd)/btop $HOME/.config/btop

rm -rf $HOME/.config/picom || true
ln -s $(pwd)/picom $HOME/.config/picom

rm -rf $HOME/.config/rofi || true
ln -s $(pwd)/rofi $HOME/.config/rofi

rm -rf $HOME/.config/wal || true
ln -s $(pwd)/wal $HOME/.config/wal

rm -f $HOME/.tmux.conf || true
ln -s $(pwd)/tmux/.tmux.conf $HOME/.tmux.conf

mkdir -p $HOME/.tmux
rm -f $HOME/.tmux/tmux-power.tmux || true
ln -s $(pwd)/tmux/tmux-power.tmux $HOME/.tmux/tmux-power.tmux

rm -rf $HOME/Scripts/wallpaper || true
mkdir -p $HOME/Scripts
ln -s $(pwd)/awesome/theme/wallpaper $HOME/Scripts/wallpaper

sudo rm /etc/sddm.conf || true
sudo ln -s $(pwd)/sddm/sddm.conf /etc/sddm.conf

sudo rm /usr/share/sddm/themes/simple-sddm/theme.conf || true
# For some reason symlinks don't work here
sudo cp $(pwd)/sddm/simple-sddm/theme.conf /usr/share/sddm/themes/simple-sddm/theme.conf

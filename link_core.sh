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

rm -rf $HOME/.config/ranger
ln -s $(pwd)/ranger $HOME/.config/ranger

ln -s $(pwd)/zsh/.zshrc-core $HOME/.zshrc-core
ln -s $(pwd)/zsh/.p10k.zsh $HOME/.p10k.zsh
ln -s $(pwd)/zsh/.p10k-tty.zsh $HOME/.p10k-tty.zsh

rm -rf $HOME/.config/btop
ln -s $(pwd)/btop $HOME/.config/btop

rm -f $HOME/.tmux.conf
ln -s $(pwd)/tmux/.tmux.conf $HOME/.tmux.conf

mkdir -p $HOME/.tmux
rm -f $HOME/.tmux/tmux-power.tmux
ln -s $(pwd)/tmux/tmux-power.tmux $HOME/.tmux/tmux-power.tmux

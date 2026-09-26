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

# Convertible/2-in-1 support. Opt in with `install.sh --tablet`; these enable
# services and install an Xorg input rule that are pointless on other machines.
if [[ "${DOTFILES_TABLET:-false}" == true ]]; then
  rm -rf $HOME/.config/touchegg
  ln -s $(pwd)/touchegg $HOME/.config/touchegg

  mkdir -p $HOME/.config/systemd/user
  rm -rf $HOME/.config/systemd/user/tablet-mode-daemon.service
  ln -s $(pwd)/systemd/user/tablet-mode-daemon.service $HOME/.config/systemd/user/tablet-mode-daemon.service
  systemctl --user daemon-reload
  systemctl --user enable --now tablet-mode-daemon.service

  sudo systemctl enable --now touchegg.service

  # Onboard reads themes from its data dir rather than ~/.config, so this copies
  # rather than symlinks. Safe to skip if wal has not generated colors yet.
  $(pwd)/awesome/scripts/onboard-pywal-theme.sh || true

  sudo mkdir -p /etc/X11/xorg.conf.d
  sudo rm -f /etc/X11/xorg.conf.d/50-wacom-touchscreen.conf
  sudo ln -s $(pwd)/xorg.conf.d/50-wacom-touchscreen.conf /etc/X11/xorg.conf.d/50-wacom-touchscreen.conf
fi

rm -rf $HOME/Scripts/wallpaper
mkdir -p $HOME/Scripts
ln -s $(pwd)/awesome/theme/wallpaper $HOME/Scripts/wallpaper

sudo rm -f /etc/sddm.conf
sudo ln -s $(pwd)/sddm/sddm.conf /etc/sddm.conf

sudo rm -f /usr/share/sddm/themes/simple-sddm/theme.conf
# For some reason symlinks don't work here
sudo cp $(pwd)/sddm/simple-sddm/theme.conf /usr/share/sddm/themes/simple-sddm/theme.conf

# The user half of the systemd-oomd setup, applied to every user service. See
# the file for why. Kept last: on systemd 255 a user daemon-reload was seen to
# empty oomd's watch list until the next system daemon-reload, so this ends with
# one.
mkdir -p "$HOME/.config/systemd/user"
rm -rf "$HOME/.config/systemd/user/service.d"
ln -s "$(pwd)/systemd/user/service.d" "$HOME/.config/systemd/user/service.d"
systemctl --user daemon-reload
sudo systemctl daemon-reload

#!/usr/bin/env bash

# Install all dependencies before running this script.

set -eo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

# Download the Hack nerd font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
unzip Hack.zip -d ~/.fonts
rm Hack.zip

# Install Tela Tela-icon-theme
wget -O tela-icon-theme.zip https://github.com/vinceliuice/Tela-icon-theme/archive/refs/tags/2024-09-04.zip
unzip tela-icon-theme.zip
sudo mkdir -p /usr/share/icons
(cd Tela-icon-theme-2024-09-04 && sudo ./install.sh -d /usr/share/icons)
rm -rf Tela-icon-theme-2024-09-04/ tela-icon-theme.zip

# Configure qt5ct
echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment

# Set lock screen timeout
# if there is a display
if [[ -n "$DISPLAY" ]]; then
  xset s 300
fi

# Install i3lock-color
git clone https://github.com/Raymo111/i3lock-color.git
(cd i3lock-color && ./install-i3lock-color.sh)
rm -rf i3lock-color

# Install wallpapers for sddm
sudo mkdir -p /usr/share/wallpapers/jacob-w-gable/contents/images_dark
sudo cp ./sddm/wallpaper.png /usr/share/wallpapers/jacob-w-gable/contents/images_dark

luarocks install dkjson --local

# Install lain
rm -rf awesome/lain
git clone https://github.com/lcpz/lain.git awesome/lain

# Set up simple sddm theme
git clone https://github.com/JaKooLit/simple-sddm.git
sudo mv simple-sddm /usr/share/sddm/themes
sudo cp sddm/wallpaper.png /usr/share/sddm/themes/simple-sddm/Backgrounds

# Set up picom
git clone https://github.com/yshui/picom.git picom-source
(cd picom-source && git checkout v12.5 && meson setup --buildtype=release build && ninja -C build install)
rm -rf picom-source

# Set up wal
pipx install pywal16

# Setup wallpapers
mkdir -p ~/Pictures/Wallpapers
cp ./awesome/theme/wallpaper.jpg ~/Pictures/Wallpapers/wallpaper1.jpg
cp ./sddm/wallpaper.png ~/Pictures/Wallpapers/wallpaper2.png
cp ./awesome/theme/lockscreen.png ~/Pictures/Wallpapers/wallpaper3.png

# Enable services
sudo systemctl enable sddm --force
sudo systemctl set-default graphical.target

#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y \
  xorg-x11-server-Xorg \
  sddm \
  awesome \
  pasystray \
  blueman \
  xss-lock \
  flameshot \
  dunst \
  kitty \
  breeze-gtk \
  breeze-icon-theme \
  plasma-breeze \
  qt5-qtstyleplugins \
  python3-pillow \
  pulseaudio-utils \
  zathura \
  firefox \
  eom \
  qt5-qtquickcontrols2 \
  qt5-qtdeclarative \
  qt5-qtsvg \
  qt6-qtsvg \
  qt6-qtvirtualkeyboard \
  qt6-qtmultimedia \
  rofi \
  ImageMagick \
  xset

# Install simple-sddm-2 for qt6
git clone https://github.com/JaKooLit/simple-sddm-2.git
sudo mv simple-sddm-2 /usr/share/sddm/themes
sudo cp sddm/wallpaper.png /usr/share/sddm/themes/simple-sddm-2/Backgrounds
sed -i 's/^Current=simple-sddm$/Current=simple-sddm-2/' sddm/sddm.conf
sed -i 's/^InputMethod=.*$/InputMethod=qtvirtualkeyboard/' sddm/sddm.conf
sudo rm -f /usr/share/sddm/themes/simple-sddm-2/theme.conf
# For some reason symlinks don't work here
sudo cp $(pwd)/sddm/simple-sddm-2/theme.conf /usr/share/sddm/themes/simple-sddm-2/theme.conf

# Need to manually install vicious library
rm -rf awesome/vicious
git clone https://github.com/vicious-widgets/vicious.git awesome/vicious

# Extra dependency for awesome stuff
sudo luarocks install minifs

# For building nm-tray
sudo dnf install -y \
  gcc-c++ \
  qt6-qtbase-devel \
  qt6-qtbase-gui \
  qt6-qttools-devel \
  cmake \
  kf6-networkmanager-qt-devel

# Build and install nm-tray
git clone https://github.com/palinek/nm-tray.git
cd nm-tray
mkdir build
cd build
cmake ..
make
sudo mv nm-tray /usr/bin
cd ../..
rm -rf nm-tray

# For building nsxiv
sudo dnf install -y \
  libX11-devel \
  libXinerama-devel \
  libXft-devel \
  imlib2 \
  imlib2-devel \
  freetype-devel \
  fontconfig-devel \
  libexif \
  libexif-devel

# Build and install nsxiv
git clone https://github.com/nsxiv/nsxiv.git
cd nsxiv
make
sudo make install
cd ..
rm -rf nsxiv

# For building i3loc-color:
sudo dnf install -y \
  autoconf \
  automake \
  cairo-devel \
  fontconfig \
  gcc \
  libev-devel \
  libjpeg-turbo-devel \
  libXinerama \
  libxkbcommon-devel \
  libxkbcommon-x11-devel \
  libXrandr \
  pam-devel \
  pkgconf \
  xcb-util-image-devel \
  xcb-util-xrm-devel \
  giflib-devel

# For building picom
sudo dnf install -y \
  dbus-devel \
  gcc \
  git \
  libconfig-devel \
  libev-devel \
  libX11-devel \
  libX11-xcb \
  libxcb-devel \
  libGL-devel \
  libEGL-devel \
  libepoxy-devel \
  meson \
  pcre2-devel \
  pixman-devel \
  uthash-devel \
  xcb-util-image-devel \
  xcb-util-renderutil-devel \
  xorg-x11-proto-devel \
  xcb-util-devel

#!/usr/bin/env bash

# Install all dependencies before running this script.

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# Download the Hack nerd font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
unzip Hack.zip -d ~/.fonts
rm Hack.zip

# Set the default shell to zsh
chsh -s $(which zsh)

# Install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Install rust-analyzer
~/.cargo/bin/rustup component add rust-analyzer

# Install typescript and typescript-language-server
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
nvm install 20
npm install -g typescript typescript-language-server neovim
nam install -g @tailwindcss/language-server
npm install -g neovim

# Install Tela Tela-icon-theme
wget -O tela-icon-theme.zip https://github.com/vinceliuice/Tela-icon-theme/archive/refs/tags/2024-09-04.zip
unzip tela-icon-theme.zip
sudo mkdir -p /usr/share/icons
(cd Tela-icon-theme-2024-09-04 && sudo ./install.sh -d /usr/share/icons)
rm -rf Tela-icon-theme-2024-09-04/ tela-icon-theme.zip

# Configure qt5ct
echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment

# Set lock screen timeout
xset s 300

# Install i3lock-color
git clone https://github.com/Raymo111/i3lock-color.git
(cd i3lock-color && ./install-i3lock-color.sh)
rm -rf i3lock-color

# Install wallpapers for sddm
sudo mkdir -p /usr/share/wallpapers/jacob-w-gable/contents/images_dark
sudo cp ./awesome/theme/wallpapers/* /usr/share/wallpapers/jacob-w-gable/contents/images_dark

# Install reactivex luarocks library, for the Docker nvim extension
sudo luarocks install reactivex

# Reset .zshrc
rm ~/.zshrc
touch ~/.zshrc
echo "source ~/.zshrc-core" >>~/.zshrc

# Set up simple sddm theme
git clone https://github.com/JaKooLit/simple-sddm.git
sudo mv simple-sddm /usr/share/sddm/themes
sudo cp awesome/theme/wallpapers/wallpaper1.png /usr/share/sddm/themes/simple-sddm/Backgrounds

# Set up picom
git clone https://github.com/yshui/picom.git
(cd picom && git checkout v12.5 && meson setup --buildtype=release build && ninja -C build install)
rm -rf picom

# Set up wal
pipx install pywal16

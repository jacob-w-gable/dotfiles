#!/usr/bin/env bash
# Copy the dotfiles into the guest and install them.
#
# rsync rather than git clone: this branch is not pushed anywhere, so the working tree is
# the only copy. The excludes below keep machine-specific and private files on the host -
# gtk-3.0/servers in particular holds a work share and an email address.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

vm_is_running || die "VM is not running; start it with ./vm/run.sh"

echo "==> copying dotfiles into the guest"
rsync -a --delete \
	-e "ssh -q -p $SSH_PORT -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" \
	--exclude '.git/' \
	--exclude 'vm/' \
	--exclude 'gtk-3.0/servers' \
	--exclude 'nvim/lua/config/machine.lua' \
	--exclude 'awesome/config/machine.lua' \
	--exclude 'kitty/acme-bisf.kitty' \
	--exclude 'nvim/pack/github' \
	--exclude 'awesome/lain' \
	--exclude 'awesome/vicious' \
	--exclude '.mypy_cache/' \
	--exclude '__pycache__/' \
	--exclude 'chromium/Pywal' \
	"$REPO_DIR/" "$VM_USER@$VM_HOST:~/dotfiles/"

echo "==> running the core installer (this takes a while)"
ssh_guest 'cd ~/dotfiles && ./install.sh --distro arch --no-devel'

echo "==> installing the Wayland GUI packages"
ssh_guest 'cd ~/dotfiles && ./install/arch/gui-wayland.sh'

# Linked by hand rather than through link_gui.sh: that script is the X11 path and would
# pull in picom, sddm and the rest of a stack the spike does not install.
echo "==> linking the Hyprland and kitty configs"
ssh_guest '
	set -eu
	mkdir -p ~/.config
	# rm first: Hyprland writes a default ~/.config/hypr on first run, and linking onto
	# an existing directory would put the link inside it.
	rm -rf ~/.config/hypr ~/.config/kitty ~/.config/rofi
	ln -s ~/dotfiles/hypr   ~/.config/hypr
	ln -s ~/dotfiles/kitty  ~/.config/kitty
	ln -s ~/dotfiles/rofi   ~/.config/rofi
'

echo "==> restarting Hyprland to pick up the config"
ssh_guest 'sudo systemctl restart getty@tty1'

echo
echo "==> done. screenshot it with ./vm/shot.sh"

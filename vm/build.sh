#!/usr/bin/env bash
# Fetch the Arch cloud image, generate an SSH key, and build the cloud-init seed ISO.
#
# Safe to re-run: the base image and key are only created when missing. The seed ISO and
# the overlay disk are rebuilt every time, so editing this script and re-running gives a
# clean guest.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

vm_is_running && die "VM is running; stop it first with ./vm/stop.sh"

# 1. Base image. Downloaded once, never booted directly - disk.qcow2 overlays it, so a
#    broken experiment is thrown away by recreating the overlay rather than re-fetching
#    530MB.
if [[ ! -f "$BASE_IMG" ]]; then
	echo "==> downloading Arch cloud image"
	curl -fL --progress-bar -o "$BASE_IMG.tmp" "$IMG_URL"

	echo "==> verifying checksum"
	expected=$(curl -fsSL "$SHA_URL" | awk '{print $1}')
	actual=$(sha256sum "$BASE_IMG.tmp" | awk '{print $1}')
	if [[ "$expected" != "$actual" ]]; then
		rm -f "$BASE_IMG.tmp"
		die "checksum mismatch: expected $expected, got $actual"
	fi
	mv "$BASE_IMG.tmp" "$BASE_IMG"
else
	echo "==> base image already present"
fi

# 2. SSH key. Guest-only and disposable, so no passphrase.
if [[ ! -f "$SSH_KEY" ]]; then
	echo "==> generating SSH key"
	ssh-keygen -t ed25519 -N "" -f "$SSH_KEY" -C "hyprland-spike-vm" >/dev/null
fi

# 3. Overlay disk. Backing paths are absolute and recorded in the overlay, so the base
#    image must not move afterwards.
echo "==> creating overlay disk"
rm -f "$DISK_IMG"
qemu-img create -q -f qcow2 -F qcow2 -b "$BASE_IMG" "$DISK_IMG" "$DISK_SIZE"

# 4. cloud-init seed.
echo "==> building seed ISO"
seed_dir=$(mktemp -d)
trap 'rm -rf "$seed_dir"' EXIT

cat >"$seed_dir/meta-data" <<EOF
instance-id: hyprland-spike
local-hostname: hyprland-spike
EOF

# Packages are installed through runcmd rather than cloud-init's `packages:` key: the
# pacman backend is the least exercised of cloud-init's distro paths, and a bare `-Sy`
# without `-u` leaves a partially upgraded system, which on Arch is how you get an
# unbootable one. Doing it by hand also puts any failure in cloud-init-output.log.
#
# Hyprland starts from .bash_profile on tty1 rather than over SSH because it needs a
# libseat seat, which only a logind tty session has. See README.md.
cat >"$seed_dir/user-data" <<EOF
#cloud-config
users:
  - name: $VM_USER
    groups: [wheel, video, input, seat]
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    lock_passwd: false
    plain_text_passwd: hypr
    ssh_authorized_keys:
      - $(cat "$SSH_KEY.pub")

ssh_pwauth: true
disable_root: true

write_files:
  - path: /etc/systemd/system/getty@tty1.service.d/autologin.conf
    content: |
      [Service]
      ExecStart=
      ExecStart=-/usr/bin/agetty --autologin $VM_USER --noclear %I \$TERM

  - path: /home/$VM_USER/.bash_profile
    owner: $VM_USER:$VM_USER
    permissions: "0644"
    # write_files runs before users_groups, so without this the chown fails with
    # getpwnam: name not found. defer moves it to the final stage, after the user exists.
    defer: true
    content: |
      [[ -f ~/.bashrc ]] && . ~/.bashrc
      # Only on the physical console, and only if a session is not already up: an SSH
      # login must not try to start a second compositor.
      if [[ -z \$WAYLAND_DISPLAY && \$XDG_VTNR == 1 ]]; then
        exec Hyprland >~/hypr.log 2>&1
      fi

  # The same again for zsh. install/common/core.sh chsh's the login shell to zsh, and zsh
  # does not read .bash_profile - without this the autologin stops starting Hyprland the
  # moment the dotfiles are installed.
  - path: /home/$VM_USER/.zprofile
    owner: $VM_USER:$VM_USER
    permissions: "0644"
    defer: true
    content: |
      if [[ -z \$WAYLAND_DISPLAY && \$XDG_VTNR == 1 ]]; then
        exec Hyprland >~/hypr.log 2>&1
      fi

runcmd:
  - [ pacman-key, --init ]
  - [ pacman-key, --populate, archlinux ]
  - [ pacman, -Syu, --noconfirm ]
  - [ pacman, -S, --noconfirm, --needed, hyprland, kitty, grim, wl-clipboard, mesa,
      mesa-utils, seatd, git, rsync, base-devel, vulkan-swrast ]
  - [ systemctl, enable, seatd ]
  - [ systemctl, daemon-reload ]
  - [ systemctl, restart, getty@tty1.service ]
EOF

# The volume label must be cidata for the NoCloud datasource to pick it up; genisoimage
# uppercases it to CIDATA, which is what cloud-init matches on.
genisoimage -quiet -output "$SEED_ISO" -volid cidata -joliet -rock \
	"$seed_dir/user-data" "$seed_dir/meta-data"

echo
echo "==> ready. next: ./vm/run.sh"

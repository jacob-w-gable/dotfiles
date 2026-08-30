#!/usr/bin/env bash
# Screenshot the guest's Hyprland session: ./vm/shot.sh [output.png]
#
# Captures inside the guest with grim and copies the PNG out, which gives a pixel-exact
# image of what Hyprland is drawing - rather than a picture of a QEMU window.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

out=${1:-$VM_DIR/shot.png}

vm_is_running || die "VM is not running; start it with ./vm/run.sh"

# WAYLAND_DISPLAY is not inherited by an SSH login, so it has to be discovered from the
# runtime dir. The .lock files sitting alongside the sockets are filtered out.
remote_shot='
set -eu
export XDG_RUNTIME_DIR=/run/user/$(id -u)
sock=$(find "$XDG_RUNTIME_DIR" -maxdepth 1 -name "wayland-*" ! -name "*.lock" | head -1)
[ -n "$sock" ] || { echo "no wayland socket - is Hyprland running on tty1?" >&2; exit 1; }
export WAYLAND_DISPLAY=$(basename "$sock")
grim /tmp/shot.png
'

ssh_guest "$remote_shot" || die "grim failed in the guest; check ~/hypr.log via ./vm/ssh.sh"
scp_from_guest /tmp/shot.png "$out"
echo "==> $out"

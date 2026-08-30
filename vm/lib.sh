#!/usr/bin/env bash
# Shared paths and settings for the spike VM scripts.

set -euo pipefail

VM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$VM_DIR")"

# Kept out of git; see .gitignore.
BASE_IMG="$VM_DIR/base.qcow2"
DISK_IMG="$VM_DIR/disk.qcow2"
SEED_ISO="$VM_DIR/seed.iso"
SSH_KEY="$VM_DIR/id_ed25519"
PID_FILE="$VM_DIR/vm.pid"
CONSOLE_LOG="$VM_DIR/console.log"

IMG_URL="https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2"
SHA_URL="$IMG_URL.SHA256"

SSH_PORT=2222
VM_USER=jacob
VM_HOST=127.0.0.1

DISK_SIZE=40G
VM_MEM=8G
VM_CPUS=6

# The guest display. Also the mode written into hypr/hyprland.lua, so the two agree.
VM_XRES=1920
VM_YRES=1080

ssh_guest() {
	ssh -q -p "$SSH_PORT" -i "$SSH_KEY" \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o LogLevel=ERROR \
		"$VM_USER@$VM_HOST" "$@"
}

scp_from_guest() {
	scp -q -P "$SSH_PORT" -i "$SSH_KEY" \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o LogLevel=ERROR \
		"$VM_USER@$VM_HOST:$1" "$2"
}

vm_is_running() {
	[[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

die() {
	echo "error: $*" >&2
	exit 1
}

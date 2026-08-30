#!/usr/bin/env bash
# Shell into the guest, or run a command in it: ./vm/ssh.sh [command...]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

vm_is_running || die "VM is not running; start it with ./vm/run.sh"
ssh -p "$SSH_PORT" -i "$SSH_KEY" \
	-o StrictHostKeyChecking=no \
	-o UserKnownHostsFile=/dev/null \
	-o LogLevel=ERROR \
	"$VM_USER@$VM_HOST" "$@"

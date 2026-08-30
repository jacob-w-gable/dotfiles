#!/usr/bin/env bash
# Shut the VM down, cleanly if it will, forcibly if it will not.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if ! vm_is_running; then
	echo "==> VM is not running"
	rm -f "$PID_FILE"
	exit 0
fi

pid=$(cat "$PID_FILE")
echo "==> asking the guest to power off"
ssh_guest "sudo systemctl poweroff" 2>/dev/null || true

for _ in $(seq 1 20); do
	kill -0 "$pid" 2>/dev/null || { echo "==> stopped"; rm -f "$PID_FILE"; exit 0; }
	sleep 1
done

echo "==> still up, killing qemu"
kill "$pid" 2>/dev/null || true
rm -f "$PID_FILE"

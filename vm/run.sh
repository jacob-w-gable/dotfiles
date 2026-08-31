#!/usr/bin/env bash
# Boot the spike VM.
#
#   ./vm/run.sh          headless, for the screenshot loop
#   ./vm/run.sh --gui    in a window, to drive Hyprland by hand
#
# Both modes boot the same guest with the same graphics device; only QEMU's host-side
# display differs.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

gui=false
[[ ${1:-} == --gui ]] && gui=true

[[ -f "$DISK_IMG" ]] || die "no disk image; run ./vm/build.sh first"
[[ -f "$SEED_ISO" ]] || die "no seed ISO; run ./vm/build.sh first"
vm_is_running && die "VM is already running (pid $(cat "$PID_FILE"))"

# virtio-vga-gl, i.e. virgl. Plain virtio-vga was tried first and does not work: its
# render node has no 3D driver, so Mesa falls back to kms_swrast on the KMS node, and the
# dumb-buffer allocation that needs then fails with EACCES - Hyprland comes up but can
# never acquire a framebuffer. virgl gives the guest a render node with real GL and
# sidesteps the whole problem.
#
# egl-headless pairs with it in headless mode: it creates a host EGL context for virgl to
# render through without opening a window.
#
# SeaBIOS (the default) rather than OVMF: the Arch cloud image is widely reported to fail
# to boot under UEFI, and there is nothing here that wants it.
args=(
	-enable-kvm
	-cpu host
	-smp "$VM_CPUS"
	-m "$VM_MEM"
	-machine q35
	-drive "file=$DISK_IMG,if=virtio,format=qcow2"
	-drive "file=$SEED_ISO,if=virtio,format=raw,media=cdrom"
	-netdev "user,id=n0,hostfwd=tcp:$VM_HOST:$SSH_PORT-:22"
	-device virtio-net-pci,netdev=n0
	-vga none
	-device "virtio-vga-gl,xres=$VM_XRES,yres=$VM_YRES"
	-pidfile "$PID_FILE"
)

if $gui; then
	# SDL rather than GTK. Both take gl=on, and virtio-vga-gl refuses to start without
	# it, but QEMU's GTK backend presents a black window on this host - an X11 session
	# on the proprietary NVIDIA driver - while the guest renders normally underneath.
	# SDL's GL path works there. Nothing about the guest differs between the two.
	args+=(-display "sdl,gl=on" -serial mon:stdio)
	echo "==> starting VM with a window"
	exec qemu-system-x86_64 "${args[@]}"
fi

args+=(-display egl-headless -serial "file:$CONSOLE_LOG" -daemonize)
: >"$CONSOLE_LOG"
echo "==> starting VM headless"
qemu-system-x86_64 "${args[@]}"

echo "==> waiting for SSH on $VM_HOST:$SSH_PORT (first boot runs cloud-init, be patient)"
for _ in $(seq 1 120); do
	if ssh_guest true 2>/dev/null; then
		# sshd answers well before cloud-init has finished its runcmd, so without this
		# the next step races the package installs and finds rsync missing.
		echo "==> SSH is up; waiting for cloud-init to finish"
		if ! ssh_guest "cloud-init status --wait >/dev/null 2>&1"; then
			echo "warning: cloud-init reported an error; see /var/log/cloud-init-output.log" >&2
		fi
		echo "==> up. shell in with ./vm/ssh.sh"
		exit 0
	fi
	sleep 5
done

die "SSH never came up. See $CONSOLE_LOG"

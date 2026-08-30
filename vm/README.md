# Hyprland spike VM

A throwaway Arch Linux VM for trying the Hyprland config without touching the laptop.

Everything here runs unprivileged: user-mode QEMU with KVM, user networking, no libvirt
and no root on the host. The guest is the official Arch cloud image, so there is no
installer to drive - cloud-init does the first-boot setup from a seed ISO.

## Usage

    ./vm/build.sh        # download the base image, make a keypair and the seed ISO
    ./vm/run.sh          # boot headless, SSH on localhost:2222
    ./vm/run.sh --gui    # boot with a window you can actually drive
    ./vm/ssh.sh          # shell into the guest
    ./vm/provision.sh    # rsync the dotfiles in and install them
    ./vm/shot.sh out.png # screenshot the guest's Hyprland session
    ./vm/stop.sh         # shut the VM down

## Why Hyprland runs on tty1 and not over SSH

Hyprland needs a DRM device and a libseat seat. Its headless backend cannot supply a
render fd on its own - `drmFD()` returns -1 and the renderer aborts - so there is no
"just run it headless" path, whatever the older wlroots documentation suggests. An SSH
session has no seat, so libseat refuses and the DRM backend never starts.

The guest therefore autologins on tty1 and starts Hyprland from `.bash_profile`, which
gets a real `seat0` from logind. SSH is used only to drive `hyprctl` and `grim` against
that already-running instance.

## Graphics

`virtio-vga` gives the guest `/dev/dri/card0`. Without virgl there is no render node, so
Mesa falls back to llvmpipe on the KMS node - slow, but it works and llvmpipe does
advertise the GLES 3.2 that Hyprland asks for. The `-gl` device variants are deliberately
avoided: virgl needs a host GL context, and X11 plus the proprietary NVIDIA driver is the
least reliable corner of that matrix for no benefit to a screenshot loop.

Blur, shadows and animations are off in the spike config. Under software rendering that
is the difference between sluggish-but-usable and unusable.

#!/usr/bin/env python3
"""Watch the Flex 5's tablet-mode switch and accelerometer, and drive
awesomewm's tablet mode via `awesome-client` signals.

Assumes laptop mode at startup (the switch only reports on change, not its
current value) -- correct for the common case of this running as a
systemd --user service started at login, before the screen has been folded.
"""
import re
import subprocess
import sys
import threading

import evdev

SWITCH_DEVICE_NAME = "Lenovo Yoga Tablet Mode Control switch"

# iio-sensor-proxy orientation -> xrandr rotation needed to keep the picture upright.
ORIENTATION_TO_ROTATION = {
    "normal": "normal",
    "bottom-up": "inverted",
    "right-up": "right",
    "left-up": "left",
}


def emit(signal, value):
    lua_value = "true" if value is True else "false" if value is False else f'"{value}"'
    subprocess.run(
        ["awesome-client", f'awesome.emit_signal("{signal}", {lua_value})'],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def find_switch_device():
    for path in evdev.list_devices():
        device = evdev.InputDevice(path)
        if device.name == SWITCH_DEVICE_NAME:
            return device
    return None


class TabletModeState:
    def __init__(self):
        self.is_active = False

    def set(self, active):
        if active == self.is_active:
            return
        self.is_active = active
        emit("tablet::mode", active)
        if not active:
            emit("tablet::orientation", "normal")


def watch_orientation(tablet_mode):
    proc = subprocess.Popen(
        ["monitor-sensor", "--accel"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )
    pattern = re.compile(r"orientation changed:\s*(\S+)")
    for line in proc.stdout:
        match = pattern.search(line)
        if not match:
            continue
        rotation = ORIENTATION_TO_ROTATION.get(match.group(1))
        if rotation and tablet_mode.is_active:
            emit("tablet::orientation", rotation)


def main():
    switch = find_switch_device()
    if switch is None:
        # Not a convertible. Exit successfully so systemd does not treat this
        # as a failure and restart us forever on non-tablet hardware.
        print(f"No {SWITCH_DEVICE_NAME!r}; not a convertible, nothing to do.", file=sys.stderr)
        sys.exit(0)

    tablet_mode = TabletModeState()
    threading.Thread(target=watch_orientation, args=(tablet_mode,), daemon=True).start()

    for event in switch.read_loop():
        if event.type == evdev.ecodes.EV_SW and event.code == evdev.ecodes.SW_TABLET_MODE:
            tablet_mode.set(bool(event.value))


if __name__ == "__main__":
    main()

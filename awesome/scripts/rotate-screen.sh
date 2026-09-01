#!/usr/bin/env bash
# Rotate the internal panel and its touch/pen input together.
#
# Usage: rotate-screen.sh <normal|left|right|inverted> [output]
#
# If [output] is omitted, the first connected output matching "eDP*" is used
# (the internal panel on this laptop). Wacom-driven touch/pen devices are
# matched by name (WACF* vendor prefix on this hardware) via `xsetwacom
# --list`, so no device IDs are hardcoded.
set -euo pipefail

exec >/tmp/rotate-screen.log 2>&1
echo "$(date -Is) rotate-screen.sh $*"

orientation="${1:?usage: rotate-screen.sh <normal|left|right|inverted> [output]}"
output="${2:-}"

case "$orientation" in
normal | left | right | inverted) ;;
*)
  echo "Unknown orientation: $orientation (expected normal|left|right|inverted)" >&2
  exit 1
  ;;
esac

if [ -z "$output" ]; then
  output="$(xrandr --query | awk '/ connected/ && /eDP/ {print $1; exit}')"
fi
if [ -z "$output" ]; then
  echo "Could not determine internal panel output (pass it explicitly)" >&2
  exit 1
fi

xrandr --output "$output" --rotate "$orientation"

case "$orientation" in
normal) wacom_rotate="none" ;;
left) wacom_rotate="ccw" ;;
right) wacom_rotate="cw" ;;
inverted) wacom_rotate="half" ;;
esac

# Pen/eraser stay on the wacom driver, which rotates via its own Rotate
# property. Only devices with a coordinate space support it (PAD devices, i.e.
# express-key buttons, don't and error out if you try). Names are space-padded
# by `--list devices` for column alignment, so trim before use.
xsetwacom --list devices | awk -F'\t' '
  {
    name = $1
    sub(/[[:space:]]+$/, "", name)
    if (name ~ /^WACF/ && $3 ~ /STYLUS|ERASER|TOUCH|CURSOR/) {
      print name
    }
  }
' | while IFS= read -r device; do
  xsetwacom set "$device" Rotate "$wacom_rotate" || echo "Warning: failed to rotate $device"
done

# Finger touch is handed to libinput by xorg.conf.d/50-wacom-touchscreen.conf,
# which has no Rotate property -- it rotates via the X coordinate
# transformation matrix instead.
case "$orientation" in
normal) matrix="1 0 0 0 1 0 0 0 1" ;;
left) matrix="0 -1 1 1 0 0 0 0 1" ;;
right) matrix="0 1 0 -1 0 1 0 0 1" ;;
inverted) matrix="-1 0 1 0 -1 1 0 0 1" ;;
esac

touch_devices="$(xinput list --name-only | grep -i "touchscreen" | grep -vi "pad" || true)"
if [ -n "$touch_devices" ]; then
  echo "$touch_devices" | while IFS= read -r device; do
    xinput set-prop "$device" "Coordinate Transformation Matrix" $matrix ||
      echo "Warning: failed to set transform matrix on $device"
  done
fi

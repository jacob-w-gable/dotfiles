#!/usr/bin/env python3

# This script takes in a hex color code and a percentage,
# and increases the saturation of the color by that percentage,
# outputting the new hex code and the RGB values.

import sys
import colorsys


def rgb_to_ansi(rgb):
    """Convert an RGB tuple to an ANSI background color escape code."""
    return f"\033[48;2;{rgb[0]};{rgb[1]};{rgb[2]}m      \033[0m {rgb_to_hex(rgb)} {rgb}"


def hex_to_rgb(hex_code):
    """Convert a hexadecimal color code to an RGB tuple."""
    return tuple(int(hex_code.lstrip("#")[i:i+2], 16) for i in (0, 2, 4))


def rgb_to_hex(rgb):
    """Convert an RGB tuple to a hexadecimal color code."""
    return "#{:02x}{:02x}{:02x}".format(*rgb)


def saturate_color(hex_code, percentage):
    """Increase the saturation of a color by a given percentage."""
    rgb = hex_to_rgb(hex_code)
    # Normalize RGB to [0, 1]
    r, g, b = [c / 255.0 for c in rgb]
    h, l, s = colorsys.rgb_to_hls(r, g, b)

    # Increase saturation
    s = min(1.0, s + (s * percentage / 100))

    # Convert back to RGB
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    new_rgb = (int(r * 255), int(g * 255), int(b * 255))
    return rgb_to_hex(new_rgb), new_rgb


def main(hex_code, percentage):
    new_hex, new_rgb = saturate_color(hex_code, percentage)
    print("Original Color:")
    print(f"{rgb_to_ansi(hex_to_rgb(hex_code))}")
    print(f"Saturated Color:")
    print(f"{rgb_to_ansi(new_rgb)}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 saturate.py <hex_color> <percentage>")
        print("Example: python3 saturate.py \"#ff0000\" 80")
        sys.exit(1)

    hex_color = sys.argv[1]
    percentage = float(sys.argv[2])
    main(hex_color, percentage)

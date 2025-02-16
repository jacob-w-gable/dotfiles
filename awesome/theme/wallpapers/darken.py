#!/usr/bin/env python3

# This is a script that takes in a hex color code as input as well as a percentage,
# and darkens the color by that percentage, outputting the new hex code and the RGB values.

import sys


def rgb_to_ansi(rgb):
    """Convert an RGB tuple to an ANSI background color escape code."""
    return f"\033[48;2;{rgb[0]};{rgb[1]};{rgb[2]}m      \033[0m {rgb_to_hex(rgb)} {rgb}"


def hex_to_rgb(hex_code):
    """Convert a hexadecimal color code to an RGB tuple."""
    return tuple(int(hex_code.lstrip("#")[i:i+2], 16) for i in (0, 2, 4))


def rgb_to_hex(rgb):
    """Convert an RGB tuple to a hexadecimal color code."""
    return "#{:02x}{:02x}{:02x}".format(*rgb)


def darken_color(hex_code, percentage):
    """Darken a color by a given percentage."""
    rgb = hex_to_rgb(hex_code)
    new_rgb = tuple(int(max(0, c * percentage / 100)) for c in rgb)
    return rgb_to_hex(new_rgb), new_rgb


def main(hex_code, percentage):
    new_hex, new_rgb = darken_color(hex_code, percentage)
    print("Original Color:")
    print(f"{rgb_to_ansi(hex_to_rgb(hex_code))}")
    print(f"Darkened Color:")
    print(f"{rgb_to_ansi(new_rgb)}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 darken.py <hex_color> <percentage>")
        print("Example: python3 darken.py \"#ff0000\" 80")
        sys.exit(1)

    hex_color = sys.argv[1]
    percentage = float(sys.argv[2])
    main(hex_color, percentage)

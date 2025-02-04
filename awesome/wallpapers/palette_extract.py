import sys
from colorthief import ColorThief


def rgb_to_hex(rgb):
    """Convert an RGB tuple to a hexadecimal color code."""
    return "#{:02x}{:02x}{:02x}".format(*rgb)


def rgb_to_ansi(rgb):
    """Convert an RGB tuple to an ANSI background color escape code."""
    return f"\033[48;2;{rgb[0]};{rgb[1]};{rgb[2]}m      \033[0m {rgb_to_hex(rgb)} {rgb}"


def main(image_path):
    # Load image and extract colors
    color_thief = ColorThief(image_path)
    # Query 5 colors, but only use the first 3. This increases the chance of the colors being similar,
    # since multiple colors are often extracted from an image.
    palette = color_thief.get_palette(color_count=5, quality=10)[0:3]

    # sort pallette by brightness
    palette.sort(key=lambda rgb: sum(rgb))

    # Print extracted colors
    print("\nExtracted Colors:")
    for color in palette:
        print(rgb_to_ansi(color))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 palette_preview.py <image_file>")
        sys.exit(1)

    image_file = sys.argv[1]
    main(image_file)

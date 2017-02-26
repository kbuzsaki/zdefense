
SPRITE = [
    "  ####  ",
    " # ## # ",
    "########",
    "###  ###",
    "## ## ##",
    "########",
    " ###### ",
    "###  ###",
]


def sprite_to_pixels(sprite):
    pixels = []
    for row in sprite:
        bits = row.replace(" ", "0").replace("#", "1")
        pixel_val = int(bits, 2)
        pixels.append(pixel_val)
    return pixels


def format_byte(b):
    return '${:02x}'.format(b)


if __name__ == "__main__":
    pixels = sprite_to_pixels(SPRITE)
    for pixel in pixels:
        print("defb " + format_byte(pixel))

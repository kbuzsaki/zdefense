
fat_center = [
    "  ####  ",
    " # ## # ",
    "########",
    "###  ###",
    "## ## ##",
    "########",
    " ###### ",
    "###  ###",
]

fat_left_up = [
    "  ####  ",
    " # ## # ",
    "########",
    "###  ###",
    "## ## ##",
    " #######",
    "####### ",
    "     ###",
]

fat_right_up = [
    "  ####  ",
    " # ## # ",
    "########",
    "###  ###",
    "## ## ##",
    "####### ",
    " #######",
    "###     ",
]

fat_sprites = [fat_center, fat_right_up, fat_center, fat_left_up]

build_zone = [
    "########",
    "# #### #",
    "########",
    "########",
    "########",
    "########",
    "# #### #",
    "########",
]

build_zone = [
    "########",
    "##    ##",
    "# #  # #",
    "#      #",
    "#      #",
    "# #  # #",
    "##    ##",
    "########",
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

def dump_sprites(sprites):
    for sprite_rows in sprites:
        pixels = sprite_to_pixels(sprite_rows)
        for pixel, sprite_row in zip(pixels, sprite_rows):
            print("defb " + format_byte(pixel) + "    ; " + sprite_row)

if __name__ == "__main__":
    dump_sprites([build_zone])

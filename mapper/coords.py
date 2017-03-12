import sys

# pixel address:
# [0, 1, 0, y7,  y6, y2, y1, y0] [y5, y4, y3, x7,  x6, x5, x4, x3]
#
# attr address
# [0, 1, 0,  1,  1,  0, y7, y6] [y5, y4, y3, x7, x6, x5, x4, x3]

def chunk(seq, size):
    return (seq[i:i + size] for i in range(0, len(seq), size))

def format_address(addr):
    return '${:04x}'.format(addr)

def format_byte(b):
    return '${:02x}'.format(b)


def cell_coords_to_pixel_address(cell_x, cell_y):
    x, y = cell_to_pixel(cell_x, cell_y)
    return pixel_coords_to_pixel_address(x, y)

def pixel_coords_to_pixel_address(x, y):
    l_x_bits = (0xf8 & x) >> 3
    l_y_bits = (0x38 & y) << 2
    l_bits = l_x_bits + l_y_bits

    h_lower_y_bits = (0x07 & y)
    h_upper_y_bits = (0xc0 & y) >> 3
    h_upper_bits = 0x40
    h_bits = h_upper_bits + h_lower_y_bits + h_upper_y_bits

    addr_bits = (h_bits << 8) + l_bits

    return addr_bits


def cell_coords_to_attr_address(cell_x, cell_y):
    x, y = cell_to_pixel(cell_x, cell_y)
    return pixel_coords_to_attr_byte_address(x, y)

def pixel_coords_to_attr_byte_address(x, y):
    l_x_bits = (0xf8 & x) >> 3
    l_y_bits = (0x38 & y) << 2
    l_bits = l_x_bits + l_y_bits

    h_upper_y_bits = (0xc0 & y) >> 6
    h_upper_bits = 0x58
    h_bits = h_upper_bits + h_upper_y_bits

    addr_bits = (h_bits << 8) + l_bits

    return addr_bits

def cell_to_pixel(x, y):
    return x << 3, y << 3


def expand_corners(corners):
    cells = [corners[0]]

    prev_corner = corners[0]
    for corner in corners[1:]:
        if corner[0] > prev_corner[0]:
            cells.extend([(x, corner[1]) for x in range(prev_corner[0]+1, corner[0] + 1)])
        elif corner[1] > prev_corner[1]:
            cells.extend([(corner[0], y) for y in range(prev_corner[1]+1, corner[1] + 1)])
        elif corner[1] < prev_corner[1]:
            cells.extend([(corner[0], y) for y in range(prev_corner[1]-1, corner[1] - 1, -1)])
        prev_corner = corner

    return cells

def direction(start, end):
    sx, sy = start
    ex, ey = end

    # moving right - direction 0
    if ex > sx:
        return 0
    elif ey < sy:
        return 2
    else:
        return 3

def print_cell_data(cells, suffix=""):
    cell_addrs = [cell_coords_to_pixel_address(cell_x, cell_y) for cell_x, cell_y in cells]
    print(";", len(cell_addrs) * 2 + 4, "bytes")
    print("; must be aligned")
    print("enemy_path" + suffix + ":")
    print("\tdefw $0000")
    for a in chunk(cell_addrs, 8):
        print("\tdefw " + ", ".join(map(format_address, a)))
    print("\tdefw $ffff")

    attr_addrs = [cell_coords_to_attr_address(cell_x, cell_y) for cell_x, cell_y in cells]
    print()
    print(";", len(attr_addrs) * 2 + 4, "bytes")
    print("; unaligned")
    print("enemy_path_attr" + suffix + ":")
    print("\tdefw $0000")
    for a in chunk(attr_addrs, 8):
        print("\tdefw " + ", ".join(map(format_address, a)))
    print("\tdefw $ffff")

    dirs = [direction(cells[i], cells[i+1]) for i in range(len(cells)-1)]
    # extend the last tile so that enemies move off the map properly
    dirs += [dirs[-1]]
    print()
    print(";", len(dirs) + 2, "bytes")
    print("; must be aligned")
    print("enemy_path_direction" + suffix + ":")
    print("\tdefb " + format_byte(dirs[0]))
    for a in chunk(dirs, 8):
        print("\tdefb " + ", ".join(map(format_byte, a)))
    print("\tdefb $ff")

    """
    xys = sum(cells, ())
    print()
    print(";", len(xys) * 2 + 4, "bytes")
    print("enemy_path_xy" + suffix + ":")
    print("\tdefb $00, $00")
    for a in chunk(xys, 8):
        print("\tdefb " + ", ".join(map(format_byte, a)))
    print("\tdefb $ff, $ff")
    """

def print_coords(coords, chunk_size=8):
    for a in chunk(coords, chunk_size):
        print("\tdefb " + ", ".join(map(format_byte, a)))


if __name__ == "__main__":
    corners = [
        (0, 5),
        (4, 5),
        (4, 9),
        (11, 9),
        (11, 3),
        (19, 3),
        (19, 12),
        (27, 12),
        (27, 7),
        (31, 7),
    ]

    cells = [
        (0, 2),
        (1, 2),
        (2, 2),
        (2, 3),
        (3, 3),
        (4, 3),
        (4, 2),
        (5, 2),
        (6, 2),
        (7, 2),
    ]
    cells = [(b, a) for a in range(24) for b in range(4)]
    cells = expand_corners(corners)


    print(len(cells))
    print()

    print_cell_data(cells)



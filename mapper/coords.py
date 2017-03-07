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


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("invalid args")
        sys.exit(1)

    cell_x = int(sys.argv[1])
    cell_y = int(sys.argv[2])

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
    #cells = [(0, a) for a in range(24)]
    cells = expand_corners(corners)

    print(cells)


    cell_addrs = [cell_coords_to_pixel_address(cell_x, cell_y) for cell_x, cell_y in cells]
    print(len(cell_addrs))
    #print("defw " + ", ".join(map(format_address, addrs)))
    print()
    print()

    print("enemy_path:")
    for a in chunk(cell_addrs, 8):
        print("\tdefw " + ", ".join(map(format_address, a)))

    print()
    print("enemy_path_attr:")
    attr_addrs = [cell_coords_to_attr_address(cell_x, cell_y) for cell_x, cell_y in cells]
    for a in chunk(attr_addrs, 8):
        print("\tdefw " + ", ".join(map(format_address, a)))

    print()
    print("enemy_path_direction:")
    dirs = [direction(cells[i], cells[i+1]) for i in range(len(cells)-1)]
    for a in chunk(dirs, 8):
        print("\tdefb " + ", ".join(map(format_byte, a)))

    print()
    print("enemy_path_xy:")
    xys = sum(cells, ())
    for a in chunk(xys, 8):
        print("\tdefb " + ", ".join(map(format_byte, a)))



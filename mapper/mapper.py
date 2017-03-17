from enum import Enum, unique

import coords


TILE_MAP = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0],
            [1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0],
            [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0],
            [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0],
            [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0],
            [0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
SIMPLE_TILE_MAP = [
    "################################",
    "################################",
    "################################",
    "###########         ############",
    "########### ####### ############",
    "     ###### ####### ############",
    "#### ###### ####### ############",
    "#### ###### ####### #######     ",
    "#### ###### ####### ####### ####",
    "####        ####### ####### ####",
    "################### ####### ####",
    "################### ####### ####",
    "###################         ####",
    "################################",
    "################################",
    "################################",
]

SIMPLE_TILE_MAP_A = [
    "################################",
    "###############.#.##############",
    "###########avvvvvvvvvb##########",
    "###########>         <##########",
    "vvvvvb#####> e^^^^^f <.#########",
    "     <####.> <.#.#.> <.######.##",
    "^^^f <#####> <#####> <.####avvvv",
    "##.> <.#.#.> <.###.> <#####>    ",
    "###> gvvvvvh <#####> <.###.> e^^",
    "###>         <####.> <#####> <.#",
    "###c^^^^^^^^^d#####> <.#.#.> <##",
    "#######.#.#########> gvvvvvh <.#",
    "###################>         <##",
    "###################c^^^^^^^^^d##",
    "#######################.#.######",
    "################################",
]

SIMPLE_TILE_MAP_B = [
    "################################",
    "################################",
    "################################",
    "################################",
    "################################",
    "##.#%#%#.#%#.#.#.#.#.#%#%#.#%#%#",
    "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
    "                                ",
    "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",
    "#%#%#.#%#%#.#.#.#.#.#%#.#%#%#.##",
    "################################",
    "################################",
    "################################",
    "################################",
    "################################",
    "################################",
]

SIMPLE_TILE_MAP_C = [
    "################################",
    "################################",
    "################################",
    "#############.#.#.#.############",
    "###########avvvvvvvvvb##########",
    "###########>         <##########",
    "##########.> e^^^^^f <.#########",
    "###########> <.#.#.> <##########",
    "##%#%#.#.#.> <#####> <.#.#.#####",
    "vvvvvvvvvvvh <.###.> gvvvvvvvvvv",
    "             <#####>            ",
    "^^^^^^^^^^^^^d#####c^^^^^^^^^^^^",
    "#####.#.#.#############.#.#.####",
    "################################",
    "################################",
    "################################",
]

SIMPLE_TILE_MAP_D = [
    "#######> <######################",
    "#######> <######################",
    "#######> <######################",
    "#######> <#######.#.#.#.########",
    "#######> <#####avvvvvvvvvb######",
    "######.> <#####>         <######",
    "#######> <.###.> e^^^^^f <.#####",
    "######.> <#####> <.#.#.> <######",
    "#######> <.#.#.> <#####> <.#####",
    "######.> gvvvvvh <.###.> <######",
    "#######>         <#####> <.#####",
    "#######c^^^^^^^^^d#####> <######",
    "#########.#.#.#.#######> <######",
    "#######################> <######",
    "#######################> <######",
    "#######################> <######",
]

MAP_SUFFIXES = [
    (SIMPLE_TILE_MAP_A, "_a"),
    (SIMPLE_TILE_MAP_B, "_b"),
    (SIMPLE_TILE_MAP_C, "_c"),
    (SIMPLE_TILE_MAP_D, "_d"),
]

@unique
class Tiles(Enum):
    blank = 0
    buildable = 1
    impassable = 2
    baz = 3
    top_wall = 4
    bottom_wall = 5
    left_wall = 6
    right_wall = 7
    top_left_corner = 8
    top_right_corner = 9
    bottom_left_corner = 10
    bottom_right_corner = 11
    top_left_nub = 12
    top_right_nub = 13
    bottom_left_nub = 14
    bottom_right_nub = 15

CHARACTER_MAP = {
    ".": Tiles.buildable,
    "#": Tiles.impassable,
    "%": Tiles.impassable,

    " ": Tiles.blank,
    "^": Tiles.bottom_wall,
    "v": Tiles.top_wall,
    ">": Tiles.left_wall,
    "<": Tiles.right_wall,

    "a": Tiles.top_left_corner,
    "b": Tiles.top_right_corner,
    "c": Tiles.bottom_left_corner,
    "d": Tiles.bottom_right_corner,

    "h": Tiles.top_left_nub,
    "g": Tiles.top_right_nub,
    "f": Tiles.bottom_left_nub,
    "e": Tiles.bottom_right_nub,
}


def pad_map(tile_map):
    col_padded = [[row[0]] + row + [row[-1]] for row in tile_map]
    return [col_padded[0]] + col_padded + [col_padded[-1]]


def slice_square(arr, x, y):
    return [row[x-1:x+2] for row in arr[y-1:y+2]]


TOP_LEFT_TILE_MAPPER = {
    ((0, 0), (0, 1)): Tiles.top_left_corner,
    ((0, 0), (1, 1)): Tiles.top_wall,
    ((1, 0), (1, 1)): Tiles.top_wall,
    ((0, 1), (0, 1)): Tiles.left_wall,
    ((1, 1), (0, 1)): Tiles.left_wall,
    ((0, 1), (1, 1)): Tiles.top_left_nub,
    ((1, 1), (1, 1)): Tiles.blank,
}

TOP_RIGHT_TILE_MAPPER = {
    ((0, 0), (1, 0)): Tiles.top_right_corner,
    ((0, 0), (1, 1)): Tiles.top_wall,
    ((0, 1), (1, 1)): Tiles.top_wall,
    ((1, 0), (1, 0)): Tiles.right_wall,
    ((1, 1), (1, 0)): Tiles.right_wall,
    ((1, 0), (1, 1)): Tiles.top_right_nub,
    ((1, 1), (1, 1)): Tiles.blank,
}

BOTTOM_LEFT_TILE_MAPPER = {
    ((0, 1), (0, 0)): Tiles.bottom_left_corner,
    ((1, 1), (0, 0)): Tiles.bottom_wall,
    ((1, 1), (1, 0)): Tiles.bottom_wall,
    ((0, 1), (0, 1)): Tiles.left_wall,
    ((0, 1), (1, 1)): Tiles.left_wall,
    ((1, 1), (0, 1)): Tiles.bottom_left_nub,
    ((1, 1), (1, 1)): Tiles.blank,
    ((1, 1), (1, 1)): Tiles.blank,
}

BOTTOM_RIGHT_TILE_MAPPER = {
    ((1, 0), (0, 0)): Tiles.bottom_right_corner,
    ((1, 1), (0, 0)): Tiles.bottom_wall,
    ((1, 1), (0, 1)): Tiles.bottom_wall,
    ((1, 0), (1, 0)): Tiles.right_wall,
    ((1, 0), (1, 1)): Tiles.right_wall,
    ((1, 1), (1, 0)): Tiles.right_wall,
    ((1, 1), (1, 0)): Tiles.bottom_right_nub,
    ((1, 1), (1, 1)): Tiles.blank,
}


class Tile:

    def __init__(self, tile_map, x, y):
        padded = pad_map(tile_map)
        self.square = slice_square(padded, x+1, y+1)

    def cells(self):
        if not self.center:
            return [[Tiles.blank, Tiles.blank]] * 2

        top_left = TOP_LEFT_TILE_MAPPER[self.top_left_cells]
        top_right = TOP_RIGHT_TILE_MAPPER[self.top_right_cells]
        bottom_left = BOTTOM_LEFT_TILE_MAPPER[self.bottom_left_cells]
        bottom_right = BOTTOM_RIGHT_TILE_MAPPER[self.bottom_right_cells]

        return [[top_left, top_right], [bottom_left, bottom_right]]

    @property
    def top_left_cells(self):
        return ((self.top_left, self.top), (self.left, self.center))

    @property
    def top_right_cells(self):
        return ((self.top, self.top_right), (self.center, self.right))

    @property
    def bottom_left_cells(self):
        return ((self.left, self.center), (self.bottom_left, self.bottom))

    @property
    def bottom_right_cells(self):
        return ((self.center, self.right), (self.bottom, self.bottom_right))

    @property
    def center(self):
        return self.square[1][1]

    @property
    def top(self):
        return self.square[0][1]

    @property
    def bottom(self):
        return self.square[-1][1]

    @property
    def left(self):
        return self.square[1][0]

    @property
    def right(self):
        return self.square[1][-1]

    @property
    def top_left(self):
        return self.square[0][0]

    @property
    def top_right(self):
        return self.square[0][-1]

    @property
    def bottom_left(self):
        return self.square[-1][0]

    @property
    def bottom_right(self):
        return self.square[-1][-1]


def cat_matrix(left, right):
    return list(l + r for l, r in zip(left, right))

def make_tiles(tile_map):
    tiles = []

    for y, row in enumerate(tile_map):
        tiles_row = [[], []]
        for x, col in enumerate(row):
            tile = Tile(tile_map, x, y)
            tiles_row = cat_matrix(tiles_row, tile.cells())
        tiles += tiles_row

    return tiles

def make_simple_tiles(simple_tile_map):
    return [[CHARACTER_MAP[c] for c in row] for row in simple_tile_map]

def make_hex_vals(row):
    pairs = [(row[i*2], row[i*2+1]) for i in range(len(row)//2)]
    return ["".join(hex(e)[-1] for e in pair) for pair in pairs]

def make_defb(row):
    return "defb " + ", ".join("$" + e for e in make_hex_vals(row))


def parse_col_cells(x, col):
    cells = []
    for y, row in enumerate(col):
        if row == " ":
            cells.append((x, y))
    return cells

def parse_cell_coords(simple_tile_map):
    cells = []
    for x, col in enumerate(zip(*simple_tile_map)):
        col_cells = parse_col_cells(x, col)
        if not col_cells:
            continue
        if not cells or (col_cells[0][1] == cells[-1][1]):
            cells.extend(col_cells)
        else:
            cells.extend(reversed(col_cells))
    return cells

def filter_coords(simple_tile_map, pred):
    cells = []
    for y, row in enumerate(simple_tile_map):
        for x, col in enumerate(row):
            if pred(col):
                cells.append((x, y))
    return cells

def filter_build_cells(simple_tile_map):
    return filter_coords(simple_tile_map, lambda c: c == ".")

def get_attackable_tiles(position):
    x, y = position
    return [
        (x+2, y-1),
        (x+2, y),
        (x+2, y+1),

        (x-2, y-1),
        (x-2, y),
        (x-2, y+1),

        (x+1, y+2),
        (x,   y+2),
        (x-1, y+2),

        (x+1, y-2),
        (x,   y-2),
        (x-1, y-2),
    ]

def get_build_tile_attackables(simple_tile_map):
    build_tiles = filter_build_cells(simple_tile_map)
    position_cells = parse_cell_coords(simple_tile_map)

    build_tile_attackables = []
    for build_tile in build_tiles:
        # all of the cells that this build tile could attack
        attackable_tiles = get_attackable_tiles(build_tile)
        # all of the position indices that the build tile can attack
        attackables = []

        for position, position_cell in reversed(list(enumerate(position_cells))):
            if position_cell in attackable_tiles:
                # +1 because of filler start position
                attackables.append(position + 1)
                # then remove the positions this covers so that we don't include them
                attackable_tiles.remove(position_cells[position])
                attackable_tiles.remove(position_cells[position-1])
                attackable_tiles.remove(position_cells[position-2])

        # pad with 255
        attackables = tuple((attackables + [255, 255, 255, 255])[:4])
        build_tile_attackables.append(attackables)

    return build_tile_attackables


def print_build_tile_data(simple_tile_map, suffix):
    build_cells = filter_build_cells(simple_tile_map)
    attackables = get_build_tile_attackables(simple_tile_map)

    print(";", len(attackables) * 4, "bytes")
    print("; must be aligned")
    print("build_tile_attackables" + suffix + ":")
    coords.print_coords(sum(attackables, ()), 4)

    print()
    print(";", len(build_cells) * 2 + 2, "bytes")
    print("; unaligned")
    print("build_tile_xys" + suffix + ":")
    coords.print_coords(sum(build_cells, ()), 2)
    print("\tdefb $ff, $ff")

    return (len(build_cells) * 2 + 2) + (len(attackables) * 4)

def print_tile_map_data(simple_tile_map, suffix):
    tiles = make_simple_tiles(simple_tile_map)
    print(";", len(tiles) * 16, "bytes")
    print("; must be aligned")
    print("tile_map" + suffix + ":")
    for row in tiles:
        print("\t" + make_defb([e.value for e in row]))

    return (len(tiles) * 16)


def print_map_data(simple_tile_map, suffix):
    print_next_defs()
    cells = parse_cell_coords(simple_tile_map)
    coords.print_cell_data(cells, suffix)

    print_next_defs()
    print_build_tile_data(simple_tile_map, suffix)

    print_next_defs()
    print_tile_map_data(simple_tile_map, suffix)

def print_map_filler_buffers(m, s):
    print_next_defs(0x80)
    print("enemy_path" + s + ":")
    print_next_defs(0x80)
    print("enemy_path_attr" + s + ":")
    pass


defs_address = 0xa000

def print_next_defs(incr=0x100):
    print()
    print("defs ${:04x} - $".format(defs_address))
    global defs_address
    defs_address += incr


def do_stuff(simple_tile_map):
    cells = parse_cell_coords(simple_tile_map)
    for i, cell in enumerate(cells):
        print(i, cell)
    print()
    build_cells = filter_build_cells(simple_tile_map)
    attackables = get_build_tile_attackables(simple_tile_map)
    for build_cell, attackable in zip(build_cells, attackables):
        print(build_cell, "\t", attackable)
    pass


if __name__ == "__main__":
    for m, s in MAP_SUFFIXES:
        print_map_data(m, s)
        print()
        print()
        print()

    defs_address = 0xc000

    print()
    print()
    print()
    print("; empty addresses to go in the upper ram chip a the bottom of main.asm")
    for m, s in MAP_SUFFIXES:
        print_map_filler_buffers(m, s)


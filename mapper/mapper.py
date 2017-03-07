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
    "################################",
    "##########avvvvvvvvvb###########",
    "##########>         <###########",
    "vvvvvb####> e^^^^^f <###########",
    "     <####> <#####> <###########",
    "^^^f <####> <#####> <#####avvvvv",
    "###> <####> <#####> <#####>     ",
    "###> gvvvvh <#####> <#####> e^^^",
    "###>        <#####> <#####> <###",
    "###c^^^^^^^^d#####> <#####> <###",
    "##################> gvvvvvh <###",
    "##################>         <###",
    "##################c^^^^^^^^^d###",
    "################################",
    "################################",
]

SIMPLE_TILE_MAP_B = [
    "################################",
    "################################",
    "################################",
    "################################",
    "################################",
    "################################",
    "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
    "                                ",
    "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",
    "################################",
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
    "################################",
    "###########avvvvvvvvb###########",
    "###########>        <###########",
    "###########> e^^^^f <###########",
    "###########> <####> <###########",
    "###########> <####> <###########",
    "vvvvvvvvvvvh <####> gvvvvvvvvvvv",
    "             <####>             ",
    "^^^^^^^^^^^^^d####c^^^^^^^^^^^^^",
    "################################",
    "################################",
    "################################",
    "################################",
]

SIMPLE_TILE_MAP = SIMPLE_TILE_MAP_C

@unique
class Tiles(Enum):
    blank = 0
    buildable = 1
    bar = 2
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
    "#": Tiles.buildable,
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
        if not cells or (col_cells[0][1] == cells[-1][1]):
            cells.extend(col_cells)
        else:
            cells.extend(reversed(col_cells))
    return cells

if __name__ == "__main__":
    cells = parse_cell_coords(SIMPLE_TILE_MAP)
    coords.print_cell_data(cells)
    print()
    tiles = make_simple_tiles(SIMPLE_TILE_MAP)
    print("tile_map:")
    for row in tiles:
        print("\t" + make_defb([e.value for e in row]))

import sys
from PIL import Image

filename = sys.argv[1]

print("reading: " + filename)
print()


sprite_width = 8
sprite_divider = 1
total_sprite_width = sprite_width + sprite_divider

im = Image.open(filename)

pixels = im.load()
width, height = im.size

all_pixels = [[0] * width for _ in range(height)]

for y in range(height):
    for x in range(width):
        cpixel = pixels[x, y]
        if round(sum(cpixel)) / float(len(cpixel)) > 127:
            all_pixels[y][x] = '0'
        else:
            all_pixels[y][x] = '1'

byte_list = [['']*height for _ in range(int(width / total_sprite_width))]

for y in range(height):
    for i in range(int(width / total_sprite_width)):
        binary_string = "".join(all_pixels[y][i * total_sprite_width:i * total_sprite_width + sprite_width])

        byte_list[i][y] = str(int(binary_string, 2))

"""
print("Expanded Format:")
for line in byte_list:
    for byte in line:
        print("defb " + byte)
    print()
"""

print("Compact Format:")
for line in byte_list:
    print("defb " + ", ".join(line))



         
        
    


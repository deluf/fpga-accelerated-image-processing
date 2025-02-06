
from PIL import Image

# 3-3-2 bitmap palette, only needed to save the ROM as an image that can be actually visualized
palette = []
for r in range(8):
    for g in range(8):
        for b in range(4):
            palette.extend([
                int(r * 255 / 7),
                int(g * 255 / 7),
                int(b * 255 / 3)
            ])

# The ROM is always generated as follows:
#  - First 4 bytes: number of rows, as a big-endian unsigned integer
#  - Next 4 bytes: number of columns, as a big-endian unsigned integer
#  - Next ROWS * COLS bytes: the values of the pixels, one per byte

def generate_test_ROM(ROWS_=8, COLS_=32):
    # Generates a simple ROWSxCOLS ROM to test the system with.
    # Pixels are uniformly distributed between 0 and 255
    #  at steps of 256 / (ROWS * COLS)
    ROWS = ROWS_
    COLS = COLS_
    pixels = [int(i * 256 / (ROWS * COLS)) for i in reversed(range(0, ROWS * COLS))]

    with open("ROM.bin", "wb") as ROM:
        ROM.write((ROWS).to_bytes(4, byteorder="big", signed=False))
        ROM.write((COLS).to_bytes(4, byteorder="big", signed=False))
        ROM.write(bytearray(pixels))
    print(f"Generated ROM.bin file containing {len(pixels)} 8-bit pixels")

    grayscale_img = Image.new(size=(COLS, ROWS), mode="L")
    grayscale_img.putdata(pixels)
    grayscale_img.save(f"inputs/test_{ROWS}x{COLS}_grayscale.png")
    print(f"Generated inputs/test_{ROWS}x{COLS}_grayscale.png")


def generate_unipi_grayscale_ROM():
    # Generates a 128x128 ROM containing an 8-bits-per-pixel grayscaled version of unipi's logo
    img = Image.open("inputs/unipi.png").convert("L")
    ROWS = img.height
    COLS = img.width
    pixels = list(img.getdata())

    with open("ROM.bin", "wb") as ROM:
        ROM.write((ROWS).to_bytes(4, byteorder="big", signed=False))
        ROM.write((COLS).to_bytes(4, byteorder="big", signed=False))
        ROM.write(bytearray(pixels))
    print(f"Generated ROM.bin file containing {len(pixels)} 8-bit pixels")
    
    img.save(f"inputs/unipi_{ROWS}x{COLS}_grayscale.png")
    print(f"Generated inputs/unipi_{ROWS}x{COLS}_grayscale.png")

def generate_332_ROM_from_image(image_path):
    # Generates a ROM containing an 8-bits-per-pixel 3-3-2 bitmap (RRRGGGBB) of the specified image
    original_img = Image.open(image_path).convert("RGB")
    ROWS = original_img.height
    COLS = original_img.width

    pixels = list(original_img.getdata())
    red_values =    [pixel[0] for pixel in pixels]
    green_values =  [pixel[1] for pixel in pixels]
    blue_values =   [pixel[2] for pixel in pixels]
    
    encoded_pixels = []
    for r, g, b in zip(red_values, green_values, blue_values):
        encoded_pixels.append(
            int((r & 0b11100000) | ((g & 0b11100000) >> 3) | ((b & 0b11000000) >> 6))
        )

    with open("ROM.bin", "wb") as ROM:
        ROM.write((ROWS).to_bytes(4, byteorder="big", signed=False))
        ROM.write((COLS).to_bytes(4, byteorder="big", signed=False))
        ROM.write(bytearray(encoded_pixels))
    print(f"Generated ROM.bin file containing {len(pixels)} 8-bit pixels")

    bitmap_img = Image.new(size=(COLS, ROWS), mode="P")
    bitmap_img.putdata(encoded_pixels)
    bitmap_img.putpalette(palette)
    bitmap_img.save(f"{image_path[:-4]}_{ROWS}x{COLS}_332-bitmap.png")
    print(f"Generated {image_path[:-4]}_{ROWS}x{COLS}_332-bitmap.png")


# Main script

print("# ROM image generator #")
print("  (1) Generate a simple test ROM (that can be either interpreted as grayscale or 3-3-2 bitmap)")
print("  (2) Generate a ROM with a grayscaled version of unipi's logo")
print("  (3) Generate a ROM with a 3-3-2 bitmap version of an image of your choice")
model = input(" > ")

try:
    model = int(model)
    if model <= 0 or model > 4:
        raise ValueError
except ValueError:
    print("Bad input")

match model:
    case 1:
        rows = input(" How many rows ? ")
        cols = input(" How many columns ? ")

        try:
            rows = int(rows)
            cols = int(cols)
            if rows <= 0 or cols <= 0:
                raise ValueError
        except ValueError:
            print("Bad input")

        generate_test_ROM(ROWS_=rows, COLS_=cols)
    case 2:
        generate_unipi_grayscale_ROM()
    case 3:
        path = input(" Enter the path of the image : ")
        generate_332_ROM_from_image(path)

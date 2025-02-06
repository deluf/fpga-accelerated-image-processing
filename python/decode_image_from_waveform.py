
from PIL import Image

# Parameters to adjust
WAVEFORM = "colorful-alpha-100"
ROWS = 179
COLS = 313


file_path = f"outputs/{WAVEFORM}.lst"

with open(file_path, 'r') as file:
    lines = file.readlines()[4:-1]

print(f"Decoding {file_path}")

clock_period = 100000   # 100 ns
start_time = 250000     # First useful sample
end_time = ROWS * COLS * clock_period + start_time
last_sample = int(lines[-1].strip().split()[0])
pixels = []

next_line_index = 1
for line in lines:

    # Parse the f0 coefficient as a bit string
    f0_str = line.strip().split()[-1]
    f0_str_reverse = f0_str[::-1]

    # Convert it to 8.3 fixed point notation 
    f0 = 0.0
    i = -3
    for bit_char in f0_str_reverse:
        bit = int(bit_char, 2)
        f0 += bit * pow(2, i)
        i += 1

    # Round it to the nearest integer (f0 is now a pixel)
    f0 = round(f0)

    # The waveform does not contain one f0 value per clock period, hence,
    #  we must take that into account and manually repeat the same f0
    #  value if needed
    simtime = int(line.strip().split()[0])
    
    if (simtime == last_sample):
        while (simtime < end_time):
            pixels.append(f0)
            simtime += clock_period
        break

    next_sample_time = int(lines[next_line_index].strip().split()[0])

    while (simtime < next_sample_time):
        pixels.append(f0)
        simtime += clock_period

    next_line_index += 1


if len(pixels) != ROWS * COLS:
    exit(f"Expected {ROWS * COLS} pixels, found {len(pixels)}")

# Convert the pixels to both 3-3-2 bitmap and grayscale
palette = []
for r in range(8):
    for g in range(8):
        for b in range(4):
            palette.extend([
                int(r * 255 / 7),
                int(g * 255 / 7),
                int(b * 255 / 3)
            ])

bitmap_img = Image.new(size=(COLS, ROWS), mode="P")
bitmap_img.putdata(pixels)
bitmap_img.putpalette(palette)
bitmap_img.save(f"outputs/{WAVEFORM}_332-bitmap_out.png")
print(f"Generated outputs/{WAVEFORM}_332-bitmap_out.png")

grayscale_img = Image.new(mode="L", size=(COLS, ROWS))
grayscale_img.putdata(pixels)
grayscale_img.save(f"outputs/{WAVEFORM}_grayscale_out.png")
print(f"Generated outputs/{WAVEFORM}_grayscale_out.png")

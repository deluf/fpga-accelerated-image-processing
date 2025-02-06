
import os
import math

ROM_filename = "ROM.bin"

if not os.path.isfile(ROM_filename):
	print("Generate a ROM first")
	exit()

print(f"Reading {ROM_filename}")

# Read the ROM byte per byte and construct a list of pixel values
pixels = []
with open("ROM.bin", "rb") as ROM:
	ROWS = int.from_bytes(ROM.read(4), byteorder="big", signed=False)
	COLS = int.from_bytes(ROM.read(4), byteorder="big", signed=False)
	while (byte := ROM.read(1)):
		pixels.append(int.from_bytes(byte))

if ROWS < 1 or COLS < 1:
	print(f"Expected a ROM with at least one row and one column. Found {ROWS} rows and {COLS} columns")

pixel_count = len(pixels)
if pixel_count != ROWS * COLS:
	print(f"Expected a ROM with a pixel count of {ROWS * COLS}. Found {pixel_count}")

print(f"Detected {ROWS}x{COLS} ROM of {pixel_count} pixels")

# Generate VHDL interface for the selected ROM
entity_name = f"ROM"
output_file = open(entity_name + ".vhdl", "w")

output_file.write("\n")
output_file.write("library IEEE;\n")
output_file.write("\tuse IEEE.std_logic_1164.all;\n")
output_file.write("\tuse IEEE.numeric_std.all;\n")
output_file.write("\n")
output_file.write("entity " + entity_name + " is\n")
output_file.write("\tport (\n")
output_file.write("\t\taddress\t: in\tstd_logic_vector(" + str( math.ceil( math.log2(pixel_count) ) - 1) + " downto 0);\n")
output_file.write("\t\tvalue\t: out\tstd_logic_vector(7 downto 0)\n")
output_file.write("\t);\n")
output_file.write("end entity;\n")
output_file.write("\n")
output_file.write("architecture Arch of " + entity_name + " is\n")
output_file.write("\n")
output_file.write("\ttype ROM_t is array (natural range 0 to " + str(pixel_count - 1) + ") of std_logic_vector(7 downto 0);\n")
output_file.write("\tconstant ROM: ROM_t := (\n")

addresses = [_ for _ in range(pixel_count)]
for address, pixel in zip(addresses, pixels):
	output_file.write(f"\t\t{address} => \"{pixel:08b}\"{"," if address != (pixel_count - 1) else ""}\n")

output_file.write("\t);\n")
output_file.write("\n")
output_file.write("begin\n")
output_file.write("\n")
output_file.write("\tvalue <= ROM( to_integer( unsigned(address) ) );\n")
output_file.write("\n")
output_file.write("end architecture;\n")

output_file.close()

print(f"Generated {entity_name}.vhdl")

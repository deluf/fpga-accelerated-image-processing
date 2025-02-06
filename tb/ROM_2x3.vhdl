
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity ROM_2x3 is
	port (
		address	: in	std_logic_vector(2 downto 0);
		value	: out	std_logic_vector(7 downto 0)
	);
end entity;

architecture Arch of ROM_2x3 is

	type ROM_t is array (natural range 0 to 5) of std_logic_vector(7 downto 0);
	constant ROM: ROM_t := (
		0 => "11010100",
		1 => "10101010",
		2 => "01111111",
		3 => "01010101",
		4 => "00101010",
		5 => "00000000"
	);

begin

	value <= ROM( to_integer( unsigned(address) ) );

end architecture;

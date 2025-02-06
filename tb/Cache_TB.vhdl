
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

entity Cache_TB is 
end entity;

architecture Arch of Cache_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
    constant ROM_ROWS      	: positive	:= 2;
    constant ROM_COLS       : positive	:= 3;
    constant ADDRESS_MAX    : positive 	:= ROM_ROWS * ROM_COLS - 1;
    constant ADDRESS_BITS   : positive 	:= integer( ceil( log2( real(ROM_ROWS * ROM_COLS) ) ) );
	constant PIXEL_BITS     : positive	:= 8;

	component ROM_2x3 is
        port (
            address	: in	std_logic_vector(ADDRESS_BITS - 1 downto 0);
            value	: out	std_logic_vector(PIXEL_BITS - 1 downto 0)
        );
    end component;

	component Cache is
		generic (
			ADDRESS_MAX     : positive;
			ADDRESS_BITS    : positive;
			PIXEL_BITS      : positive;
			ROM_COLS	    : positive
		);
		port (
			clk		        : in	std_logic;
			reset_n	        : in	std_logic;
			start         	: in    std_logic;
			pixel           : in 	std_logic_vector(PIXEL_BITS - 1 downto 0);
			address         : out	std_logic_vector(ADDRESS_BITS - 1 downto 0);
			current_pixel   : out 	std_logic_vector(PIXEL_BITS - 1 downto 0);
			upper_row_pixel : out 	std_logic_vector(PIXEL_BITS - 1 downto 0)
		);
	end component;
	
	-- Testbench signals
	signal testing	    : boolean 	:= true;
	signal clk          : std_logic := '0';

	-- Inputs
    signal reset_n      : std_logic := '0';
    signal start_ext	: std_logic := '0';
	signal pixel_ext	: std_logic_vector(PIXEL_BITS - 1 downto 0) := (others => '0');
	
	-- Outputs
    signal address_ext 			: std_logic_vector(ADDRESS_BITS - 1 downto 0);
	signal current_pixel_ext	: std_logic_vector(PIXEL_BITS - 1 downto 0);
    signal upper_row_pixel_ext	: std_logic_vector(PIXEL_BITS - 1 downto 0);

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	pixel_rom: ROM_2x3
    port map (
		address	=> address_ext,
		value	=> pixel_ext 
	);

	DUT: Cache
	generic map (
        ADDRESS_MAX     => ADDRESS_MAX,
        ADDRESS_BITS    => ADDRESS_BITS,
        PIXEL_BITS      => PIXEL_BITS,
        ROM_COLS	    => ROM_COLS
    )
    port map (
        clk		        => clk,
        reset_n	        => reset_n,
        start         	=> start_ext,
        pixel           => pixel_ext,
        address         => address_ext,
        current_pixel   => current_pixel_ext,
        upper_row_pixel => upper_row_pixel_ext
    );

	p_STIMULUS: process begin

		wait for 0.75 * CLOCK_PERIOD;

		-- Reset high but start low. Noting should happen
		reset_n	<= '1';

		wait for CLOCK_PERIOD;

		-- Start high and reset high. The cache should start fetching pixels
		start_ext	<= '1';

		-- With a 2x3 test ROM there are 6 addressable pixels, {0, ..., 5}.
		-- The cache should automatically stop after the 6-th clock cycle
		wait for 7 * CLOCK_PERIOD;

		-- Resetting should overwrite the current address and the upper row pixel with 0.
		--  Consequently, the current pixel should get the value of the first cell of the ROM
		reset_n	<= '0';

		-- End simulation
		wait for CLOCK_PERIOD;
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;

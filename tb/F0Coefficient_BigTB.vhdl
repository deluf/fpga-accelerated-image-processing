
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

entity F0Coefficient_BigTB is 
end entity;

architecture Arch of F0Coefficient_BigTB is

	-- Test bench used to generate and parse the f0 coefficients
	--  for big ROMs representing real-world images.

	-- Parameters to adjust
	constant ROM_ROWS       : positive	:= 128;
	constant ROM_COLS       : positive	:= 128;
	constant ALPHA_VALUE    : std_logic_vector(9 downto 0)	:= "0000000" & "100";

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant PIXEL_BITS	 	: positive	:= 8;
	constant ADDRESS_MAX  	: positive 	:= ROM_ROWS * ROM_COLS - 1;
    constant ADDRESS_BITS 	: positive 	:= integer( ceil( log2( real(ROM_ROWS * ROM_COLS) ) ) );
	constant ALPHA_I_BITS	: positive	:= 7;
	constant ALPHA_F_BITS	: positive	:= 3;
	
	component F0Coefficient is 
		generic (
			PIXEL_BITS      : positive;
        	ROM_COLS        : positive;
			ADDRESS_MAX		: positive;
			ADDRESS_BITS	: positive;
			ALPHA_I_BITS    : positive;
			ALPHA_F_BITS    : positive
		);
		port (
			clk         : in    std_logic;
			reset_n     : in    std_logic;
			alpha       : in    std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);
        	pixel       : in    std_logic_vector(PIXEL_BITS - 1 downto 0);
        	address     : out   std_logic_vector(ADDRESS_BITS - 1 downto 0);
			f_bad_input : out   std_logic;
			f0		    : out 	std_logic_vector(PIXEL_BITS + ALPHA_F_BITS - 1 downto 0)
		);
	end component;
	
	component ROM is
        port (
            address	: in	std_logic_vector(ADDRESS_BITS - 1 downto 0);
            value	: out	std_logic_vector(PIXEL_BITS - 1 downto 0)
        );
    end component;
		
	-- Testbench signals
	signal testing	: boolean := true;
	signal clk      : std_logic := '0';

	-- Inputs
	signal reset_n 		: std_logic := '0';
    signal alpha_ext  	: std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0) := ALPHA_VALUE;
	signal pixel_ext    : std_logic_vector(PIXEL_BITS - 1 downto 0) := (others => '0');
    
	-- Outputs
	signal address_ext    	: std_logic_vector(ADDRESS_BITS - 1 downto 0);		
    signal f_bad_input_ext  : std_logic;
    signal f0_ext    		: std_logic_vector(PIXEL_BITS + ALPHA_F_BITS - 1 downto 0);

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	pixel_rom : ROM
	port map (
		address => address_ext,
		value	=> pixel_ext
	);

	DUT : F0Coefficient
	generic map (
		PIXEL_BITS 		=> PIXEL_BITS,
		ROM_COLS        => ROM_COLS,
		ADDRESS_MAX		=> ADDRESS_MAX,
		ADDRESS_BITS	=> ADDRESS_BITS,
		ALPHA_I_BITS	=> ALPHA_I_BITS,
		ALPHA_F_BITS 	=> ALPHA_F_BITS
	)
	port map (
		clk			=> clk,
		reset_n 	=> reset_n,
		alpha 		=> alpha_ext,
		pixel		=> pixel_ext,
		address		=> address_ext,
		f_bad_input => f_bad_input_ext,
		f0   		=> f0_ext
	);

	p_STIMULUS: process begin
		
		wait for CLOCK_PERIOD;

		reset_n	<= '1';

		wait for (ROM_ROWS * ROM_COLS + 1) * CLOCK_PERIOD;

		-- Everything should instantaneously go back to default
		reset_n	<= '0';

		-- End simulation
		wait for CLOCK_PERIOD;
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;


library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity ComputingUnit_TB is 
end entity;

architecture Arch of ComputingUnit_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant PIXEL_BITS	 	: positive	:= 8;
	constant ALPHA_BITS	 	: positive	:= 3;
	
	component ComputingUnit is
		generic (
			PIXEL_BITS : positive;
			ALPHA_BITS : positive
		);
		port (
			current_pixel	: in	std_logic_vector(PIXEL_BITS - 1 downto 0);
			upper_row_pixel	: in	std_logic_vector(PIXEL_BITS - 1 downto 0);
			alpha			: in	std_logic_vector(ALPHA_BITS - 1 downto 0);
			f0				: out 	std_logic_vector(PIXEL_BITS + ALPHA_BITS - 1 downto 0)
		);
	end component;
	
	-- Testbench signals
	signal testing	: boolean := true;
	signal clk      : std_logic := '0';

	-- Inputs
    signal current_pixel_ext    : std_logic_vector(PIXEL_BITS - 1 downto 0) := (others => '0');
    signal upper_row_pixel_ext 	: std_logic_vector(PIXEL_BITS - 1 downto 0) := (others => '0');
    signal alpha_ext  			: std_logic_vector(ALPHA_BITS - 1 downto 0) := (others => '0');

	-- Outputs
    signal f0_ext    			: std_logic_vector(PIXEL_BITS + ALPHA_BITS - 1 downto 0);

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	DUT: ComputingUnit
	generic map (
		PIXEL_BITS => PIXEL_BITS,
		ALPHA_BITS => ALPHA_BITS
	)
	port map (
		current_pixel	=> current_pixel_ext,
		upper_row_pixel => upper_row_pixel_ext,
		alpha 			=> alpha_ext,
		f0   			=> f0_ext
	);

	p_STIMULUS: process begin
		
		wait for CLOCK_PERIOD;

		alpha_ext <= "010"; -- 0.250
		current_pixel_ext 	<= std_logic_vector( to_unsigned(200, PIXEL_BITS) );
		upper_row_pixel_ext <= std_logic_vector( to_unsigned(100, PIXEL_BITS) );
		-- f0 = 100 * 0.250 + 200 * 0.750 = 175
		-- f0 = 100 * 2 + 200 * 6 = 1400

		wait for CLOCK_PERIOD;

		alpha_ext <= "100"; -- 0.500
		current_pixel_ext 	<= std_logic_vector( to_unsigned(200, PIXEL_BITS) );
		upper_row_pixel_ext <= std_logic_vector( to_unsigned(100, PIXEL_BITS) );
		-- f0 = 100 * 0.500 + 200 * 0.500 = 150
		-- f0 = 100 * 4 + 200 * 4 = 1200

		wait for CLOCK_PERIOD;

		alpha_ext <= "010"; -- 0.250
		current_pixel_ext 	<= std_logic_vector( to_unsigned(0, PIXEL_BITS) );
		upper_row_pixel_ext <= std_logic_vector( to_unsigned(255, PIXEL_BITS) );
		-- f0 = 255 * 0.250 + 0 * 0.750 = 63.750
		-- f0 = 255 * 2 + 0 * 6 = 510

		wait for CLOCK_PERIOD;

		alpha_ext <= "010"; -- 0.250
		current_pixel_ext 	<= std_logic_vector( to_unsigned(100, PIXEL_BITS) );
		upper_row_pixel_ext <= std_logic_vector( to_unsigned(100, PIXEL_BITS) );
		-- f0 = 100 * 0.250 + 100 * 0.750 = 100
		-- f0 = 100 * 2 + 100 * 6 = 800

		wait for CLOCK_PERIOD;

		alpha_ext <= "111"; -- 0.875
		current_pixel_ext 	<= std_logic_vector( to_unsigned(255, PIXEL_BITS) );
		upper_row_pixel_ext <= std_logic_vector( to_unsigned(255, PIXEL_BITS) );
		-- f0 = 255 * 0.125 + 255 * 0.875 = 255
		-- f0 = 255 * 1 + 255 * 7 = 2040

		wait for CLOCK_PERIOD;

		alpha_ext <= "010"; -- 0.250
		current_pixel_ext 	<= std_logic_vector( to_unsigned(0, PIXEL_BITS) );
		upper_row_pixel_ext <= std_logic_vector( to_unsigned(0, PIXEL_BITS) );
		-- f0 = 0 * 0.250 + 0 * 0.750 = 0
		-- f0 = 0 * 2 + 0 * 6 = 0

		wait for CLOCK_PERIOD;

		alpha_ext <= "011"; -- 0.325
		current_pixel_ext 	<= std_logic_vector( to_unsigned(179, PIXEL_BITS) );
		upper_row_pixel_ext <= std_logic_vector( to_unsigned(51, PIXEL_BITS) );
		-- f0 = 51 * 0.325 + 179 * 0.625 = 128.45
		-- f0 = 51 * 3 + 179 * 5 = 1048

		wait for CLOCK_PERIOD;
		
		-- End simulation
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;

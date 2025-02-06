
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity SampleAndHold_TB is 
end entity;

architecture Arch of SampleAndHold_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant ALPHA_I_BITS	: positive	:= 7;
	constant ALPHA_F_BITS	: positive	:= 3;
	
    component SampleAndHold is
    	generic (
            ALPHA_I_BITS    : positive;
            ALPHA_F_BITS    : positive
        );
        port (
            clk		        : in	std_logic;
            reset_n	        : in	std_logic;
            alpha           : in    std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);
            alpha_cleaned   : out   std_logic_vector(ALPHA_F_BITS - 1 downto 0);
            f_bad_input     : out   std_logic;
            start           : out   std_logic
        );
    end component;

	-- Testbench signals
	signal testing	    	: boolean := true;
	signal clk          	: std_logic := '0';

	-- Inputs
    signal reset_n      	: std_logic := '0';
    signal alpha_ext      		: std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0) := (others => '0');
	
	-- Outputs
	signal alpha_cleaned_ext    : std_logic_vector(ALPHA_F_BITS - 1 downto 0);
	signal f_bad_input_ext  	: std_logic;
	signal start_ext      		: std_logic;

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	DUT: SampleAndHold
    generic map (
        ALPHA_I_BITS    => ALPHA_I_BITS,
        ALPHA_F_BITS    => ALPHA_F_BITS
    )
    port map (
        clk		        => clk,
        reset_n	        => reset_n,
        alpha           => alpha_ext,
        alpha_cleaned   => alpha_cleaned_ext,
        f_bad_input     => f_bad_input_ext,
        start           => start_ext
    );

	p_STIMULUS: process begin

		wait for 1.25 * CLOCK_PERIOD;

		-- reset_n is still '0', this should have no effect
		alpha_ext <= (3 => '1', others => '0');

		wait for CLOCK_PERIOD;

		alpha_ext <= (others => '0');

		wait for CLOCK_PERIOD;

		-- f_bad_input should rise (alpha is all zeros)
		reset_n	<= '1';

		wait for CLOCK_PERIOD;

		alpha_ext <= (4 => '1', others => '0');

		wait for CLOCK_PERIOD;

		alpha_ext <= (4 => '1', 0 => '1', others => '0');

		wait for CLOCK_PERIOD;

		alpha_ext <= (others => '0');

		wait for CLOCK_PERIOD;

		-- f_bad_input should go down and start should go up
		alpha_ext <= (1 => '1', others => '0');

		wait for 5 * CLOCK_PERIOD;

		-- Trying to change alpha mid-computations. This should have no effect
		alpha_ext <= (0 => '1', others => '0');

		wait for CLOCK_PERIOD;

		alpha_ext <= (6 => '1', others => '0');

		wait for CLOCK_PERIOD;

		reset_n <= '0';
		
		wait for CLOCK_PERIOD;

		-- End simulation
		wait for CLOCK_PERIOD;
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;

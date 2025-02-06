
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity Counter_TB is 
end entity;

architecture Arch of Counter_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant N_BIT			: positive	:= 3;
	
	component Counter is
        generic (
            N_BIT	: positive
        );
		port (
			clk		    : in	std_logic;
			reset_n	    : in	std_logic;
			enabler     : in    std_logic;
			increment   : in	std_logic_vector(N_BIT - 1 downto 0);
			count 		: out 	std_logic_vector(N_BIT - 1 downto 0)
		);
	end component;
	
	-- Testbench signals
	signal testing	    	: boolean := true;
	signal clk          	: std_logic := '0';

	-- Inputs
    signal reset_n      	: std_logic := '0';
    signal enabler      	: std_logic := '0';
    signal increment_ext	: std_logic_vector(N_BIT - 1 downto 0) := (others => '0');

	-- Outputs
    signal count_ext		: std_logic_vector(N_BIT - 1 downto 0);

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	DUT: Counter
	generic map (
		N_BIT => N_BIT
	)
	port map (
		clk   		=> clk,
		reset_n 	=> reset_n,
		enabler 	=> enabler,
		increment  	=> increment_ext,
		count		=> count_ext
	);

	p_STIMULUS: process begin

		wait for 0.75 * CLOCK_PERIOD;

		-- At the next rising edge, the counter should start, but the 
		--  count should still be 0, because the increment is set to 0.
		reset_n	<= '1';
		enabler	<= '1';

		wait for CLOCK_PERIOD;

		-- At the next rising edge, the count should be 1.
		-- When te counter overflows, it should automatically restart
		increment_ext <= std_logic_vector(to_unsigned(1, N_BIT));	-- "0000_0001";
	
		wait for 6 * CLOCK_PERIOD;

		-- Resetting the counter in the middle of the computations,
		--  the count should immediately go to 0.
		reset_n	<= '0';

		-- End simulation
		wait for CLOCK_PERIOD;
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;

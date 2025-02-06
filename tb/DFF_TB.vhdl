
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity DFF_TB is 
end entity;

architecture Arch of DFF_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant N_BIT			: positive	:= 8;
	
	component DFF is
		generic (
			N_BIT	: positive
		);
		port (
			clk		: in	std_logic;
			reset_n	: in	std_logic;
			enabler	: in	std_logic;
			d		: in	std_logic_vector(N_BIT - 1 downto 0);
			q 		: out 	std_logic_vector(N_BIT - 1 downto 0)
		);
	end component;
	
	-- Testbench signals
	signal testing	: boolean := true;
	signal clk      : std_logic := '0';

	-- Inputs
    signal reset_n  : std_logic := '0';
    signal enabler	: std_logic := '0';
    signal d_ext	: std_logic_vector(N_BIT - 1 downto 0) := (others => '0');

	-- Outputs
    signal q_ext	: std_logic_vector(N_BIT - 1 downto 0);

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	DUT: DFF
	generic map (
		N_BIT => N_BIT
	)
	port map (
		clk   	=> clk,
		reset_n => reset_n,
		enabler => enabler,
		d   	=> d_ext,
		q		=> q_ext
	);

	p_STIMULUS: process begin

		wait for 0.75 * CLOCK_PERIOD;

		-- End the reset phase and enable the flip flop. Nothing should happen instantly
		reset_n	<= '1';
		enabler	<= '1';

		wait for CLOCK_PERIOD;

		-- q should follow d at the next rising edge of the clock
		d_ext <= std_logic_vector(to_unsigned(45, N_BIT));

		wait for 1.5 * CLOCK_PERIOD;

		-- q should immediately go to 0
		reset_n	<= '0';

		wait for CLOCK_PERIOD;

		-- q should not follow d anymore
		reset_n	<= '1';
		enabler <= '0';

		wait for 0.5 * CLOCK_PERIOD;
		d_ext <= std_logic_vector(to_unsigned(45, N_BIT));	-- "0010_1101";
		wait for 0.5 * CLOCK_PERIOD;
		d_ext <= std_logic_vector(to_unsigned(29, N_BIT));	-- "0001_1101"
		wait for 0.5 * CLOCK_PERIOD;
		d_ext <= std_logic_vector(to_unsigned(75, N_BIT));	-- "0100_1011"
 
		-- End simulation
		wait for CLOCK_PERIOD;
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;


library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity ShiftRegister_TB is 
end entity;

architecture Arch of ShiftRegister_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant STAGES   		: positive	:= 4;
	constant N_BIT      	: positive	:= 8;
	
	component ShiftRegister is
		generic (
			STAGES	: positive;
			N_BIT 	: positive
		);
		port (
			clk		: in 	std_logic;	
			reset_n	: in 	std_logic;	
			enabler : in 	std_logic;
			d		: in 	std_logic_vector(N_BIT - 1 downto 0);
			q		: out 	std_logic_vector(N_BIT - 1 downto 0)
		);
	end component;
	
	-- Testbench signals
	signal testing	: boolean := true;
	signal clk      : std_logic := '0';

	-- Inputs
    signal reset_n  : std_logic := '0';
	signal enabler 	: std_logic := '0';
    signal d_ext	: std_logic_vector(N_BIT - 1 downto 0) := (others => '0');

	-- Outputs
    signal q_ext	: std_logic_vector(N_BIT - 1 downto 0);

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	DUT: ShiftRegister
	generic map (
		STAGES 	=> STAGES,
		N_BIT 	=> N_BIT
	)
	port map (
		clk   	=> clk,
		reset_n => reset_n,
		enabler => enabler,
		d   	=> d_ext,
		q		=> q_ext
	);

	p_STIMULUS: process begin

		wait until rising_edge(clk);

		reset_n	<= '1';
		enabler <= '1';
	
		wait for 0.75 * CLOCK_PERIOD;

		d_ext <= std_logic_vector(to_unsigned(1, N_BIT));

		wait for CLOCK_PERIOD;

		d_ext <= std_logic_vector(to_unsigned(2, N_BIT));

		wait for CLOCK_PERIOD;

		d_ext <= std_logic_vector(to_unsigned(3, N_BIT));

		wait for CLOCK_PERIOD;

		d_ext <= std_logic_vector(to_unsigned(4, N_BIT));


		wait for CLOCK_PERIOD;

		d_ext <= std_logic_vector(to_unsigned(0, N_BIT));

		-- Expected behaviour: after STAGES rising edges of the clock, the exact
		--  same sequence of inputs d (1, 2, 3, 4) is repeated at the output q.

		-- End simulation
		wait for (STAGES + 1) * CLOCK_PERIOD;
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;

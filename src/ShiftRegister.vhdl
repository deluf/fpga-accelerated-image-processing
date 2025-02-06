
library IEEE;
	use IEEE.std_logic_1164.all;

-- Async reset-active-low shift register with a configurable number of bits and stages
--  (i.e., the number of rising edges of the clock after which the input appears at the output)
entity ShiftRegister is
	generic (
		STAGES 	: positive;
		N_BIT 	: positive
	);
	port (
		clk		: in 	std_logic;	
		reset_n	: in 	std_logic;	
		enabler	: in 	std_logic;
		d		: in 	std_logic_vector(N_BIT - 1 downto 0);	
		q		: out 	std_logic_vector(N_BIT - 1 downto 0)
	);
end entity;

architecture Arch of ShiftRegister is

	component DFF
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
	
	type q_wires_t is array (0 to STAGES - 2) of std_logic_vector(N_BIT - 1 downto 0);
	signal q_wires : q_wires_t;

begin

	-- A K-stage shift register is composed by a cascade of K flip-flops
	g_DFF: for i in 0 to STAGES - 1 generate
		
		-- The input of the first flip-flop is the input of the shift register
		g_FIRST: if i = 0 generate 
			i_DFF: DFF
			generic map (
				N_BIT => N_BIT
			)
			port map (
				clk 	=> clk,
				reset_n => reset_n,
				enabler => enabler,
				d 		=> d,
				q	 	=> q_wires(i)
			);
		end generate;

		-- The input of the i-th flip-flop is the output of the i-1 th flip-flop
		g_OTHERS: if (i > 0 and i < STAGES - 1) generate 
			i_DFF: DFF
			generic map (
				N_BIT => N_BIT
			)
			port map (
				clk 	=> clk,
				reset_n => reset_n,
				enabler => enabler,
				d	 	=> q_wires(i-1),
				q	 	=> q_wires(i)
			);
		end generate;

		-- The output of the last flip-flop is the output of the shift register
		g_LAST: if i = STAGES - 1 generate 
			i_DFF: DFF
			generic map (
				N_BIT => N_BIT
			)
			port map (
				clk 	=> clk,
				reset_n => reset_n,
				enabler => enabler,
				d	 	=> q_wires(i-1),
				q	 	=> q
			);
		end generate;

	end generate;

end architecture;

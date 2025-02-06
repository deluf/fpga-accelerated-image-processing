
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity Multiplier_TB is 
end entity;

architecture Arch of Multiplier_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant N_BIT	 		: positive	:= 2;
	constant M_BIT	 		: positive	:= 2;
	
	component Multiplier is
		generic (
			N_BIT : positive;
			M_BIT : positive
		);
		port (
			x		: in	std_logic_vector(N_BIT - 1 downto 0);
			y		: in	std_logic_vector(M_BIT - 1 downto 0);
			c		: in	std_logic_vector(N_BIT - 1 downto 0);
			p		: out 	std_logic_vector(M_BIT + N_BIT - 1 downto 0)
		);
	end component;
	
	-- Testbench signals
	signal testing	: boolean := true;
	signal clk      : std_logic := '0';

	-- Inputs
    signal x_ext    : std_logic_vector(N_BIT - 1 downto 0) := (others => '0');
    signal y_ext    : std_logic_vector(M_BIT - 1 downto 0) := (others => '0');
    signal c_ext  	: std_logic_vector(N_BIT - 1 downto 0) := (others => '0');

	-- Outputs
    signal p_ext    : std_logic_vector(M_BIT + N_BIT - 1 downto 0);

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	DUT: Multiplier
	generic map (
		N_BIT => N_BIT,
		M_BIT => M_BIT
	)
	port map (
		x	=> x_ext,
		y   => y_ext,
		c 	=> c_ext,
		p   => p_ext
	);

	p_STIMULUS: process begin

		l_GENERATE_C: for c in 0 to (2 ** N_BIT) - 1 loop
			l_GENERATE_X: for x in 0 to (2 ** N_BIT) - 1 loop
				l_GENERATE_Y: for y in 0 to (2 ** M_BIT) - 1 loop
					x_ext <= std_logic_vector(to_unsigned(x, N_BIT));
					y_ext <= std_logic_vector(to_unsigned(y, M_BIT));
					c_ext <= (others => '0');
					wait until rising_edge(clk);
				end loop;
			end loop;
		end loop;

		-- End simulation
		wait for CLOCK_PERIOD;
		testing  <= false;
		wait until rising_edge(clk); 

	end process;

end architecture;

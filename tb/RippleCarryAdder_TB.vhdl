
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity RippleCarryAdder_TB is 
end entity;

architecture Arch of RippleCarryAdder_TB is

	constant CLOCK_PERIOD	: time		:= 100 ns;
	constant N_BIT	 		: positive	:= 2;
	constant MAX_VALUE 		: integer 	:= (2**N_BIT) - 1;
	
	component RippleCarryAdder is
		generic (
			N_BIT : positive
		);
		port (
			a		: in	std_logic_vector(N_BIT - 1 downto 0);
			b		: in	std_logic_vector(N_BIT - 1 downto 0);
			cin		: in	std_logic;
			s		: out 	std_logic_vector(N_BIT - 1 downto 0);
			cout	: out 	std_logic
		);
	end component;
	
	-- Testbench signals
	signal testing	: boolean := true;
	signal clk      : std_logic := '0';

	-- Inputs
    signal a_ext    : std_logic_vector(N_BIT - 1 downto 0) := (others => '0');
    signal b_ext    : std_logic_vector(N_BIT - 1 downto 0) := (others => '0');
    signal cin_ext  : std_logic := '0';
	
	-- Outputs
    signal s_ext    : std_logic_vector(N_BIT - 1 downto 0);
    signal cout_ext	: std_logic;

begin

	clk <= not clk after CLOCK_PERIOD/2 when testing else '0';
	
	DUT: RippleCarryAdder
	generic map (
		N_BIT => N_BIT
	)
	port map (
		a    	=> a_ext,
		b   	=> b_ext,
		cin 	=> cin_ext,
		s   	=> s_ext,
		cout	=> cout_ext
	);

	p_STIMULUS: process begin

		l_GENERATE_CIN: for i in std_logic range '0' to '1' loop
			l_GENERATE_A: for j in 0 to MAX_VALUE loop
				l_GENERATE_B: for k in 0 to MAX_VALUE loop
					a_ext <= std_logic_vector( to_unsigned(j, N_BIT) );
					b_ext <= std_logic_vector( to_unsigned(k, N_BIT) );
					cin_ext <= i;
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

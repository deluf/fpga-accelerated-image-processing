
library IEEE;
	use IEEE.std_logic_1164.all;

-- N-bit ripple carry adder
entity RippleCarryAdder is 
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
end entity;

architecture Arch of RippleCarryAdder is
	
	component FullAdder is
		port (
			a		: in	std_logic;
			b		: in	std_logic;
			cin		: in	std_logic;
			s		: out 	std_logic;
			cout	: out 	std_logic
		);
	end component;

	-- Propagate the carry between the N full adders
	signal carry : std_logic_vector(N_BIT - 2 downto 0);

begin
	
	g_FA: for i in 0 to N_BIT - 1 generate
		
		-- The carry input of the first full adder is the carry input of the ripple carry adder
		g_FIRST: if (i = 0) generate
			i_FA : FullAdder
			port map (
				a		=> a(i),
				b 		=> b(i),
				cin  	=> cin,
				s    	=> s(i),
				cout 	=> carry(i)
			);
		end generate;

		-- The carry input of the i-th full adder is the carry output of the i-th - 1 full adder
		g_OTHERS: if (i > 0 and i < N_BIT - 1) generate
			i_FA : FullAdder
			port map (
				a		=> a(i),
				b 		=> b(i),
				cin  	=> carry(i-1),
				s    	=> s(i),
				cout 	=> carry(i)
			);
		end generate;

		-- The carry output of the last full adder is the carry output of the ripple carry adder
		g_LAST: if (i = N_BIT - 1) generate
			i_FA : FullAdder
			port map (
				a		=> a(i),
				b 		=> b(i),
				cin  	=> carry(i-1),
				s    	=> s(i),
				cout 	=> cout
			);
		end generate;

	end generate;

end architecture;

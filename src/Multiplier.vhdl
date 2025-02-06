
library IEEE;
	use IEEE.std_logic_1164.all;

-- Performs p = x * y + c, where:
--	- x is a N bit natural
--  - y is a M bit natural
--  - c is a N bit natural
-- 	- p, consequently, is a N + M bit natural
entity Multiplier is 
	generic (
		N_BIT : positive;
		M_BIT : positive
	);
	port (
		x		: in	std_logic_vector(N_BIT - 1 downto 0);
		y		: in	std_logic_vector(M_BIT - 1 downto 0);
		c		: in	std_logic_vector(N_BIT - 1 downto 0);
		p		: out 	std_logic_vector(N_BIT + M_BIT - 1 downto 0)
	);
end entity;

architecture Arch of Multiplier is
	
	component ElementaryMultiplier is
		generic (
			N_BIT : positive
		);
		port (
			x		: in	std_logic_vector(N_BIT - 1 downto 0);
			y		: in	std_logic;
			c		: in	std_logic_vector(N_BIT - 1 downto 0);
			p		: out 	std_logic_vector(N_BIT downto 0)
		);
	end component;

	type intermediate_products_t is array (0 to M_BIT - 1) of std_logic_vector(N_BIT downto 0);
	signal intermediate_products : intermediate_products_t;

begin
	
	-- A NxM multiplier is composed by a cascade of M Nx1 elementary multipliers,
	--  each one multiplying x by a digit of y, and summing it to (part of) the
	--	result of the preceding elementary multiplier
	g_EM: for i in 0 to M_BIT - 1 generate
		
		-- The c of the first elementary multiplier is the c of the entire multiplier circuitry
		g_FIRST: if (i = 0) generate
			i_EM : ElementaryMultiplier
			generic map (
				N_BIT => N_BIT
			)
			port map (
				x	=> x,
				y 	=> y(i),
				c  	=> c,
				p  	=> intermediate_products(i)
			);
		end generate;

		g_OTHERS: if (i > 0) generate
			i_EM : ElementaryMultiplier
			generic map (
				N_BIT => N_BIT
			)
			port map (
				x	=> x,
				y 	=> y(i),
				c  	=> intermediate_products(i - 1)(N_BIT downto 1),
				p  	=> intermediate_products(i)
			);
		end generate;

	end generate;

	process (intermediate_products)
	begin
		-- The rightmost digit of the result of the i-th elementary 
		--  multiplier is the i-th rightmost digit of the final product
		for i in 0 to M_BIT - 2 loop
			p(i) <= intermediate_products(i)(0);
		end loop;

		-- The remaining leftmost N+1 bits of the final product
		--  are the result of the last elementary multiplier
		p(N_BIT + M_BIT - 1 downto M_BIT - 1) <= intermediate_products(M_BIT - 1);
	end process;

end architecture;

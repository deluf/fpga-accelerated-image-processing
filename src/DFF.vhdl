
library IEEE;
	use IEEE.std_logic_1164.all;

-- N-bit async reset-active-low D-flip-flop with enabler
entity DFF is 
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
end entity;

architecture Arch of DFF is
begin

	process(clk, reset_n)
  	begin
    	if reset_n = '0' then
      		q <= (others => '0');
    	elsif rising_edge(clk) then
      		if enabler = '1' then
        		q <= d;
			-- Inferred latch: 
			-- else q <= q;
      		end if;
    	end if;
  	end process;

end architecture;

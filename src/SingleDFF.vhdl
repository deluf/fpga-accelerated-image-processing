
library IEEE;
	use IEEE.std_logic_1164.all;

-- 1-bit async reset-active-low D-flip-flop with enabler
entity SingleDFF is 
	port (
		clk		: in	std_logic;
		reset_n	: in	std_logic;
		enabler	: in	std_logic;
		d		: in	std_logic;
		q 		: out 	std_logic
	);
end entity;

architecture Arch of SingleDFF is
begin

	process(clk, reset_n)
  	begin
    	if reset_n = '0' then
      		q <= '0';
    	elsif rising_edge(clk) then
      		if enabler = '1' then
        		q <= d;
			-- Inferred latch: 
			-- else q <= q;
      		end if;
    	end if;
  	end process;

end architecture;

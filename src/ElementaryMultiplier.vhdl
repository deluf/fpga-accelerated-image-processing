
library IEEE;
	use IEEE.std_logic_1164.all;

-- Performs p = x * y + c, where:
--	- x is a N bit natural
--  - y is a 1 bit digit
--  - c is a N bit natural
-- 	- p, consequently, is a N + 1 bit natural
entity ElementaryMultiplier is 
	generic (
		N_BIT : positive
	);
	port (
		x		: in	std_logic_vector(N_BIT - 1 downto 0);
		y		: in	std_logic;
		c		: in	std_logic_vector(N_BIT - 1 downto 0);
		p		: out 	std_logic_vector(N_BIT downto 0)
	);
end entity;

architecture Arch of ElementaryMultiplier is
	
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

    signal RCA_b 	: std_logic_vector(N_BIT - 1 downto 0);
    signal RCA_s 	: std_logic_vector(N_BIT - 1 downto 0);
    signal RCA_cout : std_logic;

begin
	
    RCA : RippleCarryAdder
    generic map (
        N_BIT   => N_BIT
    )
    port map (
        a		=> c,
        b 		=> RCA_b,
        cin  	=> '0',
        s    	=> RCA_s,
        cout 	=> RCA_cout
    );

	-- If y = '0' then p = c, else p = x + c
    RCA_b <= x when y = '1' else (others => '0');
    p <= RCA_cout & RCA_s;

end architecture;


library IEEE;
    use IEEE.std_logic_1164.all;

-- Async reset-active-low counter with configurable size (bit width) and increment
entity Counter is 
	generic (
		N_BIT	: positive
	);
	port (
		clk		    : in	std_logic;
		reset_n	    : in	std_logic;
        enabler     : in    std_logic;
		increment   : in	std_logic_vector(N_BIT - 1 downto 0);
		count       : out 	std_logic_vector(N_BIT - 1 downto 0)
	);
end entity;

architecture Arch of Counter is

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

    signal RCA_to_DFF : std_logic_vector(N_BIT - 1 downto 0);
    signal DFF_to_RCA : std_logic_vector(N_BIT - 1 downto 0);

begin

    RCA: RippleCarryAdder 
    generic map (
        N_BIT   => N_BIT
    )
    port map (
        a 	    => DFF_to_RCA,
        b 	    => increment,
        cin 	=> '0',
        s       => RCA_to_DFF,
        cout    => open
    );
    
    current_count_register: DFF
    generic map (
        N_BIT   => N_BIT
    )
    port map (
        clk 	=> clk,
        reset_n => reset_n,
        enabler => enabler,
        d 		=> RCA_to_DFF,
        q	 	=> DFF_to_RCA
    );

    count <= DFF_to_RCA;

end architecture;

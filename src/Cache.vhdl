
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.to_unsigned;

-- In order to calculate every f0 coefficient in one clock cycle, 
--  the last ROM_COLS pixels used must be cached
entity Cache is 
	generic (
        ADDRESS_MAX     : positive;
        ADDRESS_BITS    : positive;
        PIXEL_BITS      : positive;
		ROM_COLS	    : positive
	);
	port (
		clk		        : in	std_logic;
		reset_n	        : in	std_logic;
        start           : in    std_logic;
        pixel           : in 	std_logic_vector(PIXEL_BITS - 1 downto 0);
        address         : out	std_logic_vector(ADDRESS_BITS - 1 downto 0);
        current_pixel   : out 	std_logic_vector(PIXEL_BITS - 1 downto 0);
        upper_row_pixel : out 	std_logic_vector(PIXEL_BITS - 1 downto 0)
	);
end entity;

architecture Arch of Cache is

    component ShiftRegister is
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
    end component;

    component Counter is
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
    end component;

    signal enabler          : std_logic;
    signal counter_overflow : std_logic;

    -- VHDL does not allow an output signal to appear to the right of any assignment statement (<=)
    signal address_internal : std_logic_vector(ADDRESS_BITS - 1 downto 0);

begin

    -- The whole cache circuit stops when the current address reaches the maximum one
    counter_overflow <= '1' when address_internal = std_logic_vector( to_unsigned(ADDRESS_MAX, ADDRESS_BITS) ) else '0';
    enabler <= start and not counter_overflow;

    -- At each clock cyle, the counter increments the address
    address_counter : Counter
    generic map (
        N_BIT   => ADDRESS_BITS
    )
    port map (
        clk         => clk,
        reset_n     => reset_n,
        enabler     => enabler,
        increment   => std_logic_vector( to_unsigned(1, ADDRESS_BITS) ),
        count       => address_internal
    );

    -- The cache is simply a ROM_COLS-stage shift register.
    -- This way, the pixel on the upper row is the output of the shift register
    cached_pixels : ShiftRegister
    generic map (
		STAGES  => ROM_COLS,
		N_BIT 	=> PIXEL_BITS
	)
	port map (
		clk		=> clk,
		reset_n	=> reset_n,
		enabler	=> enabler,
		d   	=> pixel,
		q   	=> upper_row_pixel
	);

    address <= address_internal;
    current_pixel <= pixel;
    
end architecture;

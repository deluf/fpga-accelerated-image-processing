
library IEEE;
	use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.to_unsigned;

-- Main circuit
entity F0Coefficient is 
	generic (
        -- Number of bits needed to represent a pixel.
        -- According to the specifications, this should be set to 8.
        -- If different than 8, then the ROM should be re-generated accordingly
        PIXEL_BITS      : positive;
        -- Number or columns of the image inside the ROM
        ROM_COLS        : positive;
        -- Highest addressable pixel (ROM cell)
        ADDRESS_MAX     : positive;
        -- Number of bits needed to represent the address above
        ADDRESS_BITS    : positive;
        -- Number of bits needed to represent the integer part of alpha.
        -- According to the specifications, this should be set to 7
        ALPHA_I_BITS    : positive;
        -- Number of bits needed to represent the fractional part of alpha.
        -- According to the specifications, this should be set to 3
        ALPHA_F_BITS    : positive
	);
	port (
		clk         : in    std_logic;
        -- Async reset-active-low
        reset_n     : in    std_logic;
        alpha       : in    std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);
        -- Signals to and from the ROM
        pixel       : in    std_logic_vector(PIXEL_BITS - 1 downto 0);
        address     : out   std_logic_vector(ADDRESS_BITS - 1 downto 0);
        -- Bad input flag, raised when alpha is not between 0 and 1 (extremes excluded)
        f_bad_input : out   std_logic;
		f0		    : out 	std_logic_vector(PIXEL_BITS + ALPHA_F_BITS - 1 downto 0)
	);
end entity;

architecture Arch of F0Coefficient is

    component Cache is 
    	generic (
            PIXEL_BITS      : positive;
            ADDRESS_MAX     : positive;
            ADDRESS_BITS    : positive;
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
    end component;

	component ComputingUnit is
        generic (
            PIXEL_BITS : positive;
            ALPHA_BITS : positive
        );
        port (
            current_pixel	: in	std_logic_vector(PIXEL_BITS - 1 downto 0);
            upper_row_pixel	: in	std_logic_vector(PIXEL_BITS - 1 downto 0);
            alpha			: in	std_logic_vector(ALPHA_BITS - 1 downto 0);
            f0				: out 	std_logic_vector(PIXEL_BITS + ALPHA_BITS - 1 downto 0)
        );
	end component;

    component SampleAndHold is
    	generic (
            ALPHA_I_BITS    : positive;
            ALPHA_F_BITS    : positive
        );
        port (
            clk		        : in	std_logic;
            reset_n	        : in	std_logic;
            alpha           : in    std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);
            alpha_cleaned   : out   std_logic_vector(ALPHA_F_BITS - 1 downto 0);
            f_bad_input     : out   std_logic;
            start           : out   std_logic
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

    component SingleDFF is 
        port (
            clk		: in	std_logic;
            reset_n	: in	std_logic;
            enabler	: in	std_logic;
            d		: in	std_logic;
            q 		: out 	std_logic
        );
    end component;

    -- Output signals are held by registers
    signal f0_internal 	        : std_logic_vector(PIXEL_BITS + ALPHA_F_BITS - 1 downto 0);
    signal f_bad_input_internal : std_logic;
    -- (The address is held by a register inside the cache)

    -- Sample and Hold to Cache signal
    signal start : std_logic;

    -- Sample and Hold to Computing Unit signal
    signal alpha_cleaned : std_logic_vector(ALPHA_F_BITS - 1 downto 0);

    -- Cache to Computing Unit signals
    signal current_pixel    : std_logic_vector(PIXEL_BITS - 1 downto 0);
    signal upper_row_pixel  : std_logic_vector(PIXEL_BITS - 1 downto 0);

begin

    -- Alpha is sampled once (and cleaned of its integer part) as soon as it 
    --  follows the specifications (and the reset phase is over).
    -- The Sample And Hold circuit also tells the Cache when to start fetching pixels
    alpha_SnH: SampleAndHold
    generic map (
        ALPHA_I_BITS    => ALPHA_I_BITS,
        ALPHA_F_BITS    => ALPHA_F_BITS
    )
    port map (
        clk		        => clk,
        reset_n	        => reset_n,
        alpha           => alpha,
        alpha_cleaned   => alpha_cleaned,
        f_bad_input     => f_bad_input_internal,
        start           => start
    );

    -- In order to calculate every f0 coefficient in one clock cycle, 
    --  the last ROM_COLS pixels used must be cached
    row_cache : Cache
    generic map (
        ADDRESS_MAX     => ADDRESS_MAX,
        ADDRESS_BITS    => ADDRESS_BITS,
        PIXEL_BITS      => PIXEL_BITS,
        ROM_COLS	    => ROM_COLS
    )
    port map (
        clk		        => clk,
        reset_n	        => reset_n,
        start           => start,
        pixel           => pixel,
        address         => address,
        current_pixel   => current_pixel,
        upper_row_pixel => upper_row_pixel
    );

    -- The computing unit is responsible for actually calculating f0
    CU : ComputingUnit
    generic map (
        PIXEL_BITS  => PIXEL_BITS,
        ALPHA_BITS  => ALPHA_F_BITS
    )
    port map (
        current_pixel   => current_pixel,
        upper_row_pixel => upper_row_pixel,
        alpha           => alpha_cleaned,
        f0              => f0_internal
    );

    -- The output registers are always sampling (unless the reset signal is low)
    f0_out_register : DFF
    generic map (
        N_BIT	=> PIXEL_BITS + ALPHA_F_BITS
    )
    port map (
        clk		=> clk,
        reset_n	=> reset_n,
        enabler	=> '1',
        d		=> f0_internal,
        q 		=> f0
    );

    f_bad_input_out_register : SingleDFF
    port map (
        clk		=> clk,
        reset_n	=> reset_n,
        enabler	=> '1',
        d		=> f_bad_input_internal,
        q 		=> f_bad_input
    );


end architecture;

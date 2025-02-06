
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.to_unsigned;

-- Samples alpha as soon as it follows the specifications (and the reset phase is over)
entity SampleAndHold is 
	generic (
        -- Number of bits needed to represent the integer part of alpha
        ALPHA_I_BITS    : positive;
        -- Number of bits needed to represent the fractional part of alpha
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
end entity;

architecture Arch of SampleAndHold is
    
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

    signal f_good_input : std_logic;

    signal start_internal : std_logic;
    signal hold : std_logic;
    
    signal alpha_mux        : std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);
    signal alpha_sampled    : std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);

begin

    -- Alpha must be between 0 and 1 (extremes excluded), i.e. :
    --  1. The integer part of alpha is composed by all '0'
    --  2. The fractional part of alpha is composed by at least one '1'
    f_good_input <= 
        '1' when ( 
                alpha_mux(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto ALPHA_F_BITS) = 
                std_logic_vector( to_unsigned(0, ALPHA_I_BITS) )
            )
            and not (
                alpha_mux(ALPHA_F_BITS - 1 downto 0) = 
                std_logic_vector( to_unsigned(0, ALPHA_F_BITS) )
            )
        else '0';

    -- When the reset signal is low, even if the input is good the circuit can not start.
    -- The hold signal is held by a register because it is used as enabler to update
    --  the alpha register one last time before starting the computations
    start_register : SingleDFF
    port map (
        clk		=> clk,
        reset_n	=> reset_n,
        enabler	=> '1',
        d		=> f_good_input,
        q 		=> start_internal
    );
    hold <= not start_internal;

    -- When the hold signal is still on, the circuit sees the alpha coming from the user.
    -- When the hold signal goes down, the circuit sees the sampled version of alpha
    alpha_sample_and_hold_register : DFF
    generic map (
        N_BIT	=> ALPHA_I_BITS + ALPHA_F_BITS
    )
    port map (
        clk		=> clk,
        reset_n	=> reset_n,
        enabler	=> hold,
        d		=> alpha(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0),
        q 		=> alpha_sampled
    );

    alpha_mux <= alpha when hold = '1' else alpha_sampled;
    
    -- Output signals
    start <= start_internal;
    f_bad_input <= not f_good_input;
    alpha_cleaned <= alpha_sampled(ALPHA_F_BITS - 1 downto 0);

end architecture;

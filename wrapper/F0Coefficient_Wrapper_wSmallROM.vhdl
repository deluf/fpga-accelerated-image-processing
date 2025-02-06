
library IEEE;
	use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.to_unsigned;
    use IEEE.math_real."ceil";
    use IEEE.math_real."log2";

-- Since Vivado only evaluates Register-to-Register paths, 
--  the inputs of the circuit are wrapped with registers.
-- (All of the outputs are already held by registers)

-- In this wrapper:
-- The ROM is 16x16 big
-- Alpha is represented in 7.3 fixed-point notation
-- Pixels are represented using 8 bits
entity F0Coefficient_Wrapper_wSmallROM is 
	port (
		clk         : in    std_logic;
        reset_n     : in    std_logic;
        alpha       : in    std_logic_vector(9 downto 0);
        f_bad_input : out   std_logic;
		f0		    : out 	std_logic_vector(10 downto 0)
	);
end entity;

architecture Arch of F0Coefficient_Wrapper_wSmallROM is

	constant PIXEL_BITS	 	: positive	:= 8;
	constant ROM_ROWS       : positive	:= 16;
	constant ROM_COLS       : positive	:= 16;
	constant ADDRESS_MAX  	: positive 	:= ROM_ROWS * ROM_COLS - 1;
    constant ADDRESS_BITS 	: positive 	:= integer( ceil( log2( real(ROM_ROWS * ROM_COLS) ) ) );
	constant ALPHA_I_BITS	: positive	:= 7;
	constant ALPHA_F_BITS	: positive	:= 3;
	
	component F0Coefficient is 
		generic (
			PIXEL_BITS      : positive;
        	ROM_COLS        : positive;
			ADDRESS_MAX		: positive;
			ADDRESS_BITS	: positive;
			ALPHA_I_BITS    : positive;
			ALPHA_F_BITS    : positive
		);
		port (
			clk         : in    std_logic;
			reset_n     : in    std_logic;
			alpha       : in    std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);
        	pixel       : in    std_logic_vector(PIXEL_BITS - 1 downto 0);
        	address     : out   std_logic_vector(ADDRESS_BITS - 1 downto 0);
			f_bad_input : out   std_logic;
			f0		    : out 	std_logic_vector(PIXEL_BITS + ALPHA_F_BITS - 1 downto 0)
		);
	end component;
    
    component Wrapper_SmallROM is
        port (
            address	: in	std_logic_vector(ADDRESS_BITS - 1 downto 0);
            value	: out	std_logic_vector(PIXEL_BITS - 1 downto 0)
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

    signal alpha_wrapped    : std_logic_vector(ALPHA_I_BITS + ALPHA_F_BITS - 1 downto 0);
    signal pixel_wrapped    : std_logic_vector(PIXEL_BITS - 1 downto 0);
    signal pixel            : std_logic_vector(PIXEL_BITS - 1 downto 0);
    signal address          : std_logic_vector(ADDRESS_BITS - 1 downto 0);

begin

    alpha_in_register : DFF
    generic map (
        N_BIT	=> ALPHA_I_BITS + ALPHA_F_BITS
    )
    port map (
        clk		=> clk,
        reset_n	=> reset_n,
        enabler	=> '1',
        d		=> alpha,
        q 		=> alpha_wrapped
    );

    pixel_in_register : DFF
    generic map (
        N_BIT	=> PIXEL_BITS
    )
    port map (
        clk		=> clk,
        reset_n	=> reset_n,
        enabler	=> '1',
        d		=> pixel,
        q 		=> pixel_wrapped
    );

    f0_circuit : F0Coefficient
	generic map (
		PIXEL_BITS 		=> PIXEL_BITS,
		ROM_COLS        => ROM_COLS,
		ADDRESS_MAX		=> ADDRESS_MAX,
		ADDRESS_BITS	=> ADDRESS_BITS,
		ALPHA_I_BITS	=> ALPHA_I_BITS,
		ALPHA_F_BITS 	=> ALPHA_F_BITS
	)
	port map (
		clk			=> clk,
		reset_n 	=> reset_n,
		alpha 		=> alpha_wrapped,
		pixel		=> pixel_wrapped,
		address		=> address,
		f_bad_input => f_bad_input,
		f0   		=> f0
	);

    pixel_rom : Wrapper_SmallROM
	port map (
		address => address,
		value	=> pixel
	);

end architecture;


library IEEE;
	use IEEE.std_logic_1164.all;

-- Given alpha, the current pixel y(i,j), and the pixel on the upper row y(i-1,j),
--	computes f0 = alpha * y(i-1,j) + (1-alpha) * y(i,j).
-- The output of each product can be represented in PIXEL_BITS.ALPHA_BITS fixed point notation.
-- Taking into account that alpha is in (0, 1), the output f0 can still be represented in
--  PIXEL_BITS.ALPHA_BITS fixed point notation
entity ComputingUnit is 
	generic (
		-- Number of bits needed to represent a pixel
		PIXEL_BITS : positive;
		-- Number of bits needed to represent the fractional part of alpha
		ALPHA_BITS : positive
	);
	port (
		current_pixel	: in	std_logic_vector(PIXEL_BITS - 1 downto 0);
		upper_row_pixel	: in	std_logic_vector(PIXEL_BITS - 1 downto 0);
		alpha			: in	std_logic_vector(ALPHA_BITS - 1 downto 0);
		f0				: out 	std_logic_vector(PIXEL_BITS + ALPHA_BITS - 1 downto 0)
	);
end entity;

architecture Arch of ComputingUnit is
	
	component Multiplier is
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
	end component;

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

	-- current_product =  y(i,j) * (1 - alpha)
	signal current_product : std_logic_vector(PIXEL_BITS + ALPHA_BITS - 1 downto 0);
	
	-- upper_row_product =  y(i-1,j) * (alpha)
	signal upper_row_product : std_logic_vector(PIXEL_BITS + ALPHA_BITS - 1 downto 0);

	signal not_alpha 			: std_logic_vector(ALPHA_BITS - 1 downto 0);
	signal alpha_complement 	: std_logic_vector(ALPHA_BITS - 1 downto 0);
	
begin
	
	-- (1 - alpha), called alpha_complement, can be computed as not_alpha + 1
	not_alpha <= not alpha;
	alpha_complement_RCA : RippleCarryAdder
    generic map (
        N_BIT   => ALPHA_BITS
    )
    port map (
        a		=> not_alpha,
        b 		=> (others => '0'),
        cin  	=> '1',
        s    	=> alpha_complement,
        cout 	=> open
    );

	-- Multiplier for the current pixel: computes y(i,j) * (1 - alpha)
	current_pixel_MUL : Multiplier
	generic map (
		N_BIT => PIXEL_BITS,
		M_BIT => ALPHA_BITS
	)
	port map (
		x	=> current_pixel,
		y 	=> alpha_complement,
		c  	=> (others => '0'),
		p  	=> current_product
	);
	
	-- Multiplier for the pixel on the upper row: computes y(i-1,j) * alpha
	upper_row_pixel_MUL : Multiplier
	generic map (
		N_BIT => PIXEL_BITS,
		M_BIT => ALPHA_BITS
	)
	port map (
		x	=> upper_row_pixel,
		y 	=> alpha,
		c  	=> (others => '0'),
		p  	=> upper_row_product
	);

	-- Computes the sum between the two preceding products.
	-- Given that alpha is in (0, 1), the sum never overflows
    f0_RCA : RippleCarryAdder
    generic map (
        N_BIT   => PIXEL_BITS + ALPHA_BITS
    )
    port map (
        a		=> current_product,
        b 		=> upper_row_product,
        cin  	=> '0',
        s    	=> f0,
        cout 	=> open
    );

end architecture;

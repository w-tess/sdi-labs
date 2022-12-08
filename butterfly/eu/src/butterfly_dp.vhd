library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity butterfly_dp is  
	
	-- N = I/O bit-width
	-- EDGE = clock value during sample
	generic (
		N : integer := 16;
		EDGE : std_logic := '1'
	);
	
	port (
		ina, inb, wr, wi : in signed(N-1 downto 0);   
		clk : in std_logic; 
		le : in std_logic_vector(9 downto 0);
		sel_in, sel_out, sf_2h_1l : in std_logic;
		sel_int : in std_logic_vector(2 downto 0); 
		outa, outb : out signed(N-1 downto 0);
	);
			
end entity butterfly_dp;

architecture behavioral of butterfly_dp is

	component sign_ext is 

		-- N = I/O bit-width before sign extention
		-- M = I/O bit-width after sign extention

		generic (
			N : integer := 16;
			M : integer := 33;
		);
	
		port (
        	ina, inb, wr, wi : in signed(N-1 downto 0);
			ina_ext, inb_ext, wr_ext, wi_ext : out signed(M-1 downto 0);
		);	

	end component sign_ext;

	component regfile0 is
	
		generic (
			N : integer := 33;
			EDGE : std_logic := '1'
		);
		
		port (
			ina_ext, inb_ext, wr_ext, wi_ext : in signed(N-1 downto 0);   
			clk : in std_logic; 
			le : in std_logic_vector(9 downto 0);
			sel_in, sel_out : in std_logic;
			sel_int : in std_logic_vector(2 downto 0); 
			outa_ext, outb_ext : out signed(N-1 downto 0);
			add0_outc, round0_outb : in signed(N-1 downto 0);
			r2 : buffer signed(N-1 downto 0);;
			ar_ai, br_bi, wr_wi : out signed(N-1 downto 0);
		);
				
	end component regfile0;

	component mpy_n is

		generic (
			N : integer := 33
		);
	
		port (
			clk : in std_logic;
			ina, inb : in signed(N-1 downto 0);
			outc : out signed(N-1 downto 0)
		);
	
	end component mpy_n;

	component add_n is

		generic (
			N : integer := 33
		);
	
		port (
			clk : in std_logic;
			ina, inb: in signed(N-1 downto 0);
			outc: out signed(N-1 downto 0)
		);
	
	end component add_n;

	component round0 is

		generic (
			N : integer := 33
		);
	
		port (
			clk : in std_logic;
			ina : in signed(N-1 downto 0);
			outb: out signed(N-1 downto 0)
		);

	end component round0;

	component sh0 is

		generic (
			N : integer := 16;
			M : integer := 33;
		);
	
		port (
        	outa_ext, outb_ext : in signed(M-1 downto 0);
			sf_2h_1l : in std_logic;
			outa, outb : out signed(N-1 downto 0);
		);

	end component sh0;




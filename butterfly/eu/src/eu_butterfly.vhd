library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eu_butterfly is  

	generic (
		N : integer := 16;
		M : integer := 33;
	);
	
	port (
		ina, inb, wr, wi : in signed(N-1 downto 0);
		clk : in std_logic;
		le : in std_logic_vector(9 downto 0);
		sel_in, sel_out, sf_2h_1l : in std_logic;
		sel_int : in std_logic_vector(2 downto 0);
		outa, outb : out signed(N-1 downto 0)
	);
		
end entity eu_butterfly;

architecture behavioral of eu_butterfly is

	component regfile is
		generic (
			N : integer := 33;
			EDGE : std_logic := '1'
		);
		port (
			clk : in std_logic;
			le : in std_logic_vector(9 downto 0);
			sel_int : in std_logic_vector(2 downto 0);
			sel_in, sel_out : in std_logic;
			ina_ext, inb_ext : in signed(N-1 downto 0);
			wr_ext, wi_ext : in signed(N-1 downto 0);
			add0_outc, round0_outb : in signed(N-1 downto 0);
			r2_q : out signed(N-1 downto 0);
			rmux0_out, rmux1_out : out signed(N-1 downto 0);
			rmux2_out, rmux3_out : out signed(N-1 downto 0);
			rmux4_out : out signed(N-1 downto 0)
		);
	end component regfile;

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

	component round_n is
		generic (
			N : integer := 33
		);
		port (
			clk : in std_logic;
			ina : in signed(N-1 downto 0);
			outb: out signed(N-1 downto 0)
		);
	end component round_n;

	component sf is
		generic (
			N : integer := 16;
		);
		port (
			sf_2h_1l : in std_logic;
        	ina : in signed(N-1 downto 0);
			outb : out signed(N-1 downto 0)
		);
	end component sf;

	ina_ext, inb_ext : signed(N-1 downto 0);
	wr_ext, wi_ext : signed(M-1 downto 0);

begin
	-- estensione del segno per i dati in ingresso
	ina_ext <= resize(ina, M);
	inb_ext <= resize(inb, M);
	wr_ext <= resize(wr, M);
	wi_ext <= resize(wi, M);

	
	
end architecture behavioral;




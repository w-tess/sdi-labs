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
		clk, sf_2h_1l : in std_logic;
		le : in std_logic_vector(9 downto 0);
		sel_in, sel_out, sel_mux01, sel_mux2 : in std_logic;
		sel_int : in std_logic_vector(2 downto 0);
		sub_add_n, sel_mux3 : in std_logic_vector(1 downto 0);
		outa, outb : out signed(N-1 downto 0)
	);
		
end entity eu_butterfly;

architecture behavioral of eu_butterfly is

	component regfile is
		generic (
			N : integer := 33;

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
			sh : out signed(N-1 downto 0);
			mpy : out signed(N-1 downto 0)
		);
	end component mpy_n;

	component add_n is
		generic (
			N : integer := 33
		);
		port (
			clk : in std_logic;
			sub_add_n : in std_logic;
			ina, inb: in signed(N-1 downto 0);
			outc: out signed(N-1 downto 0)
		);
	end component add_n;

	component round is
		generic (
			N : integer := 33
		);
		port (
			ina : in signed(N-1 downto 0);
			outb: out signed(N-1 downto 0)
		);
	end component round;


	signal ina_ext, inb_ext : signed(M-1 downto 0);
	signal wr_ext, wi_ext : signed(M-1 downto 0);
	signal sf0_in, sf1_in : signed(N-1 downto 0);
	signal rmux3_out, rmux4_out : signed(M-1 downto 0);
	signal r2_q, rmux0_out, rmux1_out, rmux2_out : signed(M-1 downto 0);
	signal mux0_out, mux1_out, mux2_out : signed(M-1 downto 0);
	signal mpy0_mpy, mpy0_sh : signed(M-1 downto 0);
	signal add0_outc, add1_outc : signed(M-1 downto 0);
	signal mux3_out : signed(M-1 downto 0);
	signal round0_outb : signed(M-1 downto 0);

begin
	-- estensione del segno per i dati in ingresso
	ina_ext <= resize(ina, M);
	inb_ext <= resize(inb, M);
	wr_ext <= resize(wr, M);
	wi_ext <= resize(wi, M);

	regfile : regfile
	generic map(N => M)
	port map(
		clk => clk, 
		le => le, 
		sel_int => sel_int,
		sel_in => sel_in,
		sel_out => sel_out,
		ina_ext => ina_ext,
		inb_ext => inb_ext,
		wr_ext => wr_ext,
		wi_ext => wi_ext,
		add0_outc => add0_outc,
		round0_outb => round0_outb,
		r2_q => r2_q,
		rmux0_out => rmux0_out,
		rmux1_out => rmux1_out,
		rmux2_out => rmux2_out,
		rmux3_out => rmux3_out,
		rmux4_out => rmux4_out

	);

	sf0_in <= rmux3_out(M-1 downto 17);
	sf1_in <= rmux4_out(M-1 downto 17);

	sf0 : outb <= shift_right(sf0_in, 1) when sf_2h_1l = '0' else
				  shift_right(sf0_in, 2);
	sf1 : outa <= shift_right(sf1_in, 1) when sf_2h_1l = '0' else
				  shift_right(sf1_in, 2);
	
	mpy0 : mpy_n
	generic map(N => M)
	port map(
		clk => clk, 
		ina => mux1_out,
		inb => mux0_out,
		mpy => mpy0_mpy,
		sh => mpy0_sh

	);

	add0 : add_n
	generic map(N => M)
	port map(
		clk => clk, 
		sub_add_n => sub_add_n,
		ina => mux2_out,
		inb => mpy0_mpy,
		outc => add0_outc

	);

	add1 : add_n
	generic map(N => M)
	port map(
		clk => clk, 
		sub_add_n => sub_add_n,
		ina => mpy0_sh,
		inb => add0_outc,
		outc => add1_outc

	);

	round0 : round
	generic map(N => M)
	port map(
		ina => round0_ina,
		outb => round0_outb

	);

	mux0 : mux0_out <= rmux2_out when sel_mux01 = '0' else rmux0_out;

	mux1 : mux1_out <= rmux1_out when sel_mux01 = '0' else '2';
	
	mux2 : mux2_out <= rmux0_out when sel_mux2 = '0' else r2_q;
	
	mux3 : mux3_out <= add0_outc when sel_mux3 = "00" else add1_outc when sel_mux3 = "01" else r2_q;


end architecture behavioral;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
	
	-- N = I/O bit-width
	generic (
		N : integer := 33
	);
	
	port (
		-- ingressi per i comandi
		clk : in std_logic;
		le : in std_logic_vector(9 downto 0);
		sel_int : in std_logic_vector(2 downto 0);
		sel_in, sel_out : in std_logic;
		-- ingressi per i dati
		ina_ext, inb_ext : in signed(N-1 downto 0);
		wr_ext, wi_ext : in signed(N-1 downto 0);
		add0_outc, round0_outb : in signed(N-1 downto 0);
		-- uscite per i dati
		r2_q : out signed(N-1 downto 0);
		rmux0_out, rmux1_out : out signed(N-1 downto 0);
		rmux2_out, rmux3_out : out signed(N-1 downto 0);
		rmux4_out : out signed(N-1 downto 0)
	);
			
end entity regfile;

architecture behavioral of regfile is

	type ri_t is array(9 downto 0) of signed(N-1 downto 0);
	signal ri_d : ri_t;
	signal ri_q : ri_t;

	component reg_n is  
		generic (
			N : integer := 33;
			EDGE : std_logic := '1'
		);
		port (
			d : in signed(N-1 downto 0);
			clk, le : in std_logic;   
			q : out signed(N-1 downto 0)
		);	
	end component reg_n;

begin

	-- definisco tramite un generate i vari registri 
	-- interni al REGFILE
	reg_chain : for i in 9 downto 0 generate
		reg_i : reg_n
			port map(
				d => ri_d(i),
				clk => clk,
				le => le(i),
				q => ri_q(i)
			);
	end generate;

	-- definisco i multiplexer interni al REGFILE, le 
	-- label fanno fede ai nomi presenti sullo schematico
	rmux0 : rmux0_out <= ri_q(4) when sel_int(0) = '0' else ri_q(5);

    rmux1 : rmux1_out <= ri_q(6) when sel_int(1) = '0' else ri_q(7);

    rmux2 : rmux2_out <= ri_q(8) when sel_int(2) = '0' else ri_q(9);

    rmux3 : rmux3_out <= ri_q(1) when sel_out = '0' else ri_q(3);

    rmux4 : rmux4_out <= ri_q(0) when sel_out = '0' else ri_q(2);

    rmux5 : ri_d(2) <= round0_outb when sel_in = '0' else add0_outc;

	-- assegnazione degli ingressi dei registri
	ri_d(0) <= round0_outb;
	ri_d(1) <= round0_outb;
    ri_d(3) <= round0_outb;
    ri_d(4) <= ina_ext;
    ri_d(5) <= ina_ext;
    ri_d(6) <= inb_ext;
    ri_d(7) <= inb_ext;
    ri_d(8) <= wr_ext;
    ri_d(9) <= wi_ext;

	-- assegno l'uscita di R2
	r2_q <= ri_q(2);

end architecture behavioral;
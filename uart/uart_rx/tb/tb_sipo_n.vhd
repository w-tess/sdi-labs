library ieee;
use ieee.std_logic_1164.all;

entity tb_sipo_n is
end entity tb_sipo_n;

architecture test of tb_sipo_n is

	component sipo_n is

		generic(N : integer := 8);
	
		port(
			si, sipo_rst : in std_logic;
			sipo_se, clk : in std_logic;
			po : buffer std_logic_vector(N-1 downto 0)
		);
		
	end component sipo_n;

	signal tb_si, tb_sipo_rst : std_logic;
	signal tb_sipo_se, tb_clk : std_logic;
	signal tb_po: std_logic_vector(7 downto 0);

	constant tck : time := 10 ns;

begin

	DUT : sipo_n 
		port map(
			si => tb_si, 
			sipo_rst => tb_sipo_rst, 
			sipo_se => tb_sipo_se, 
			clk => tb_clk, 
			po => tb_po
		);

	clk_gen : process is
	begin
		tb_clk <= '0', '1' after tck/2;
		wait for tck;
	end process;

	tb_si <= '1','0' after tck, '1' after 4*tck;

	tb_sipo_rst <= '1', '0' after tck, 
						'1' after 10*tck, 
						'0' after 11*tck;

	tb_sipo_se <= '0', '1' after tck;

end architecture test;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_s_multiplier_n is
end entity tb_s_multiplier_n;

architecture test of tb_s_multiplier_n is
	
	component s_multiplier_n is

		generic (
			N : integer := 8
		);
	
		port (
			ina, inb : in signed(N-1 downto 0);
			outc : out signed(2*N-1 downto 0)
		);
	
	end component s_multiplier_n;

	signal tb_ina, tb_inb : signed(7 downto 0);
	signal tb_outc : signed(15 downto 0);

begin
	
	DUT : s_multiplier_n port map (ina => tb_ina, inb => tb_inb, outc => tb_outc);

	tb_ina <= X"32", X"10" after 5 ns, X"A1" after 10 ns, 
					 X"7A" after 15 ns, X"B2" after 20 ns; 

	tb_inb <= X"4F", X"97" after 5 ns, X"2A" after 10 ns, 
					 X"5C" after 15 ns, X"30" after 20 ns;
	
end architecture test;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_s_multiplier_n is
end entity tb_s_multiplier_n;

architecture test of tb_s_multiplier_n is
	
	component s_multiplier_n is

		generic (
			N : integer := 12
		);
	
		port (
			ina, inb : in signed(N-1 downto 0);
			outc : out signed(N-1 downto 0)
		);
	
	end component s_multiplier_n;

	signal tb_ina, tb_inb : signed(11 downto 0);
	signal tb_outc : signed(11 downto 0);

begin
	
	DUT : s_multiplier_n 
		port map (ina => tb_ina, inb => tb_inb, outc => tb_outc);

	tb_ina <= X"332", X"160" after 5 ns, X"0A1" after 10 ns, 
					  X"87A" after 15 ns, X"5B2" after 20 ns; 

	tb_inb <= X"04F", X"397" after 5 ns, X"B2A" after 10 ns, 
					  X"D5C" after 15 ns, X"EF0" after 20 ns;
	
end architecture test;
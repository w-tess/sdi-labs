library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_s_adder_n is
end entity tb_s_adder_n;

architecture test of tb_s_adder_n is
	
	component s_adder_n is

		generic (
			N : integer := 8
		);
	
		port (
			ina, inb: in signed(N-1 downto 0);
			outc: out signed(N-1 downto 0)
		);
	
	end component s_adder_n;

	signal tb_ina, tb_inb : signed(7 downto 0);
	signal tb_outc : signed(7 downto 0);

begin
	
	DUT : s_adder_n port map(ina => tb_ina, inb => tb_inb, outc => tb_outc);

	tb_ina <= X"A1", X"37" after 5 ns, X"C9" after 10 ns,
				  X"1F" after 15 ns, X"DA" after 20 ns;

	tb_inb <= X"23", X"F1" after 5 ns, X"60" after 10 ns,
				  X"35" after 15 ns, X"05" after 20 ns;
	
end architecture test;
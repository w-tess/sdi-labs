library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_s_adder_n is
end entity tb_s_adder_n;

architecture test of tb_s_adder_n is
	
	component s_adder_n is

		generic (
			N : integer := 12
		);
	
		port (
			ina, inb: in signed(N-1 downto 0);
			outc: out signed(N-1 downto 0)
		);
	
	end component s_adder_n;

	signal tb_ina, tb_inb : signed(11 downto 0);
	signal tb_outc : signed(11 downto 0);

begin
	
	DUT : s_adder_n 
		port map(ina => tb_ina, inb => tb_inb, outc => tb_outc);

	tb_ina <= X"AC1", X"B37" after 5 ns, X"8C9" after 10 ns,
				  	  X"16F" after 15 ns, X"3DA" after 20 ns;

	tb_inb <= X"023", X"1F1" after 5 ns, X"460" after 10 ns,
				  	  X"335" after 15 ns, X"905" after 20 ns;
	
end architecture test;
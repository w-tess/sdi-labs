library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sat is
end entity tb_sat;

architecture test of tb_sat is
	
	component sat is
		generic (
			N : integer := 12;
			MAX : integer := 2**10-1
		);
		port (
			ina : in signed(N-1 downto 0);
			outa : out signed(N-1 downto 0)
		);
	end component sat;

	signal tb_ina, tb_outa : signed(11 downto 0);

begin
	
	DUT : sat 
		port map(ina => tb_ina, outa => tb_outa);
	
	tb_ina <= X"324", X"6DF" after 5 ns,  X"C3A" after 10 ns,
			  		  X"801" after 15 ns, X"AB2" after 20 ns; 
	
end architecture test;
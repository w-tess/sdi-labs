library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_round is
	generic(N : integer := 33);
end entity tb_round;

architecture test of tb_round is

	component round is
		generic(
			N : integer := 33
		);
		port (
			ina : in signed(N-1 downto 0);
			outb : out signed(N-1 downto 0)
		);
	end component round;

	signal tb_ina : signed(N-1 downto 0);
	signal tb_outb : signed(N-1 downto 0);
	constant tck : time := 10 ns;

begin
	
	DUT : round
		port map(
			ina => tb_ina,
			outb => tb_outb
		);
	
	data_gen : process is
	begin
		tb_ina <= to_signed(-235048212, 33);
		wait for tck;
		tb_ina <= to_signed( 194849605, 33);
		wait for tck;
		tb_ina <= to_signed( 235906825, 33);
		wait for tck;
		tb_ina <= to_signed(-569340282, 33);
		wait for tck;
		tb_ina <= to_signed( 506928167, 33);
		wait for tck;
		tb_ina <= to_signed(-793018521, 33);
		wait for tck;
		assert false 
		report "simulation completed succesfully." 
		severity note;
		wait;
	end process;

end architecture test;
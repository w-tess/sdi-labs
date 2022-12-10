library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_round is
	generic(N : integer := 33);
end entity tb_round;

architecture test of tb_round is

	component round is
		generic(
			N : integer := 33;
		);
		port (
			ina : in signed(N-1 downto 0);
			outb : out signed(N-1 downto 0);
		);
	end component round;

	signal tb_ina : signed(N-1 downto 0);
	signal tb_outb : signed(N-1 downto 0);

begin
	
	DUT : round
		port map(
			ina => tb_ina,
			outb => tb_outb
		);
	
	data_gen : process is
	begin
		tb_ina <= to_signed()
	end process;

end architecture test;
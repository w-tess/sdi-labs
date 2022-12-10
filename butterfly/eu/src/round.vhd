library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round is

	generic(
		N : integer := 33;
	);

	port (
		ina : in signed(N-1 downto 0);
		outb : out signed(N-1 downto 0);
	);

end entity round;

architecture behavioral of round is

	type round_t is array(0 to 15) of signed(2 downto 0);

	constant round_rom : round_t := (
		"000",
		"000",
		"001",
		"010",
		"010",
		"010",
		"011",
		"100",
		"100",
		"100",
		"101",
		"110",
		"110",
		"110",
		"111",
		"111"
	);

	signal addr : signed(3 downto 0);
	signal tmp_round : signed(2 downto 0);

begin

	addr <= ina(N-14 downto N-17);

	tmp_round <= round_rom(to_integer(addr));

	outb <= ina(N-1 downto N-13) & 
			tmp_round & 
			ina(N-17 downto 0);
	
end architecture behavioral;
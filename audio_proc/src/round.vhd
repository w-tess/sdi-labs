library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round is

	generic(
		N : integer := 12
	);

	port (
		ina : in signed(N-1 downto 0);
		outb : out signed(N-1 downto 0)
	);

end entity round;

architecture behavioral of round is

	type round_t is array(0 to 15) of signed(2 downto 0);

	-- definisco la ROM secondo una politica di
	-- arrotondamento di tipo "round-to-nearest-even"
	constant round_rom : round_t := (
		"000", "000", "001", "010",	
		"010", "010", "011", "100",
		"100", "100", "101", "110",
		"110", "110", "111", "111"
	);

	signal addr : unsigned(3 downto 0);
	signal tmp_round : signed(2 downto 0);

begin

	-- se 
	-- - N e' il parallelismo interno 
	-- - M e' il parallelismo di I/O
	-- - "word" indica il dato su "N" bit da arrotondare
	-- - "word1" indica gli "M" MSB di "word"
	-- - "word2" indica gli "N-M" LSB di "word"
	-- allora "addr" e' definito dai 3 LSB di "word1" e 
	-- dal MSB di "word2"
	addr <= unsigned
		(std_logic_vector(ina(N-(N/2+1) downto N-(N/2+4))));

	-- recupero i 3 LSB arrotondati
	tmp_round <= round_rom(to_integer(addr));

	-- ricompongo il dato su "N" bit
	outb <= ina(N-1 downto N-(N/2)) & 
			tmp_round & 
			ina(N-(N/2+4) downto 0);
	
end architecture behavioral;
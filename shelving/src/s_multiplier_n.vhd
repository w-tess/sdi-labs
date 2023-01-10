library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- signed multiplier on "N" bits
entity s_multiplier_n is

	generic (
		N : integer := 8
	);

	port (
		ina, inb : in signed(N-1 downto 0);
		outc : out signed(2*N-1 downto 0)
	);

end entity s_multiplier_n;

architecture behavioral of s_multiplier_n is

begin

	outc <= ina * inb;
	
end architecture behavioral;
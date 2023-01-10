library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- signed adder on "N" bits
entity s_adder_n is

	generic (
		N : integer := 8
	);

	port (
		ina, inb: in signed(N-1 downto 0);
		outc: out signed(N-1 downto 0)
	);

end entity s_adder_n;

architecture behavioral of s_adder_n is
begin
	
	outc <= ina + inb;
		
end architecture behavioral;
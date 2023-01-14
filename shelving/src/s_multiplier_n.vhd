library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- signed multiplier on "N" bits
entity s_multiplier_n is

	generic (
		N : integer := 12
	);

	port (
		ina, inb : in signed(N-1 downto 0);
		outc : out signed(N-1 downto 0)
	);

end entity s_multiplier_n;

architecture behavioral of s_multiplier_n is
begin

	mpy_proc : process(ina, inb) is
		variable tmp_outc : signed(2*N-1 downto 0);
	begin
		tmp_outc := ina * inb;
		tmp_outc := shift_right(tmp_outc, 8);
		outc <= tmp_outc(11 downto 0); 
	end process;

end architecture behavioral;
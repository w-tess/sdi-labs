library ieee;
use ieee.std_logic_1164.all;

entity dff is

	generic(
		RST_V : std_logic := '1';
		CLK_V : std_logic := '1'
	);	

	port(
		d_in, clk : in std_logic;
		rst, en : in std_logic;
		d_out : out std_logic
	);

end entity dff;

architecture behavioral of dff is
begin

	process (clk) is
	begin
		if (clk'event and clk = CLK_V) then
			if (rst = RST_V) then
				d_out <= '1';
			elsif (en = '1') then
				d_out <= d_in;
			end if;
		end if;
	end process;
	 
end architecture behavioral;
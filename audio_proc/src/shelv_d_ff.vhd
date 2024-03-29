library ieee;
use ieee.std_logic_1164.all;

entity shelv_d_ff is

	generic(
		RST_V : std_logic := '1';
		CLK_V : std_logic := '1'
	);	

	port(
		d_in, clk : in std_logic;
		rst, en : in std_logic;
		d_out : out std_logic
	);

end entity shelv_d_ff;

architecture behavioral of shelv_d_ff is
begin

	process (clk) is
	begin
		if (clk'event and clk = CLK_V) then
			if (rst = RST_V) then
				d_out <= '0';
			elsif (en = '1') then
				d_out <= d_in;
			end if;
		end if;
	end process;
	 
end architecture behavioral;
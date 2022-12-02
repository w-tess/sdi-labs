library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_voter is
end entity tb_voter;

architecture test of tb_voter is

	component voter is

		port(
			din : in std_logic_vector(2 downto 0);
			dout : out std_logic
		);
	
	end component voter;
	
	signal tb_din : std_logic_vector(2 downto 0) := "000";
	signal tb_dout : std_logic;

begin

	DUT : voter 
	port map(
		din => tb_din, 
		dout => tb_dout
	);
	
	tb_din_cnt : process is
		variable cnt : integer range 0 to 8 := 0;
	begin
		wait for 1 ns;

		cnt := cnt + 1;
		if(tb_din = "111") then
			cnt := 0;
		end if;

		tb_din <= std_logic_vector(to_unsigned(cnt, 3));
	end process;

end architecture test;
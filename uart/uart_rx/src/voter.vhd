library ieee;
use ieee.std_logic_1164.all;

entity voter is

	port(
		din : in std_logic_vector(2 downto 0);
		dout : out std_logic
	);
	
end entity voter;

architecture behavioral of voter is
begin

	dout <= din(1) and din (0) when din(2) = '0' else
			din(1) or din (0);

end architecture behavioral;
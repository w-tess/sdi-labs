library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- sommatore su "N" bit con pipe interna
entity add_n is

	generic (
		N : integer := 33
	);

	port (
		clk : in std_logic;
		ina, inb: in signed(N-1 downto 0);
		outc: out signed(N-1 downto 0)
	);

end entity add_n;

architecture behavioral of add_n is
	signal tmp_outc : signed(N-1 downto 0);
begin
	
	tmp_outc <= ina + inb;

	-- la pipe non e' connessa a segnali di 
	-- controllo, campiona incondizionatamente
	-- ad ogni fronte di salita
	pipe_add : process(clk)
	begin
		if clk'event and clk = '1' then
			outc <= tmp_outc;
		end if;
	end process pipe_add;
		
end architecture behavioral;
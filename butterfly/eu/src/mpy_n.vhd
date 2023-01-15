library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- moltiplicatore su "N" bit con pipe interna
entity mpy_n is

	generic (
		N : integer := 33
	);

	port (
		clk : in std_logic;
		ina, inb : in signed(N-1 downto 0);
		sh : out signed(N-1 downto 0);
		mpy : out signed(N-1 downto 0)
	);

end entity mpy_n;

architecture behavioral of mpy_n is
	signal tmp_mpy : signed(2*N-1 downto 0);
begin

	tmp_mpy <= ina * inb;

	-- la pipe non e' connessa a segnali di 
	-- controllo, campiona incondizionatamente
	-- ad ogni fronte di salita
	pipe_mpy : process(clk)
	begin
		if clk'event and clk = '1' then
			mpy <= tmp_mpy(N-1 downto 0);
		end if;
	end process pipe_mpy;

	-- l'uscita sh e' disponibile subito
	sh <= tmp_mpy(N-1 downto 0);

end architecture behavioral;
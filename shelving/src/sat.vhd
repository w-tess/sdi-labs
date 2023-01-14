library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sat is

	generic (
		N : integer := 12;
		MAX : integer := 2**10-1
	);

	port (
		ina : in signed(N-1 downto 0);
		outa : out signed(N-1 downto 0)
	);

end entity sat;

architecture behavioral of sat is
begin
	
	-- processo per saturare il dato filtrato
	sat_proc : process(ina) is
		variable maxval : signed(N-1 downto 0) 
				        := to_signed(MAX, N);
	begin
		-- caso di saturazione positiva
		if ina > maxval then
			outa <= maxval;
		-- caso di saturazione negativa
		elsif abs(ina) > maxval then
			outa <= -maxval;
		-- caso in cui non saturo
		else	
			outa <= ina;
		end if;
	end process;
	
end architecture;
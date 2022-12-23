library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_n is  
	
	-- N = I/O bit-width
	-- EDGE = clock value during sample
	generic (
		N : integer := 33;
		EDGE : std_logic := '1'
	);
	
	port (
		d : in signed(N-1 downto 0);   
		clk, le : in std_logic;
		q : out signed(N-1 downto 0)
	);
			
end entity reg_n; 
 
architecture behavioral of reg_n is 
begin 

	process (clk) is
	begin  
		if (clk'event and clk = EDGE) then
			if (le = '1') then
				q <= d;
			end if;
		end if;		
	end process; 
	
end architecture behavioral;
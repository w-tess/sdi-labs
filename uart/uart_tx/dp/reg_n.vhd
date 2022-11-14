library ieee;
use ieee.std_logic_1164.all;

entity reg_n is  
	
	-- N = I/O bit-width
	-- EDGE = clock value during sample
	generic (
		N : integer := 8;
		EDGE : std_logic := '1'
	);
	
	port (
		d : in std_logic_vector(N-1 downto 0);   
		clk, le : in std_logic;   
		q : out std_logic_vector(N-1 downto 0)
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
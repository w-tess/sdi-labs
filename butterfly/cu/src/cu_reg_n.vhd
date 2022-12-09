library ieee;
use ieee.std_logic_1164.all;

entity cu_reg_n is
	
	-- N = I/O bit-width
	-- RST_V = reset value to reset
	-- CLK_V = clock value to sample
	generic (
		N : integer := 8;
		RST_V : std_logic := '1';
		CLK_V : std_logic := '1'
	);
	
	port (
		d : in std_logic_vector(N-1 downto 0);
		rst, clk, le : in std_logic;
		q : out std_logic_vector(N-1 downto 0)
	);
			
end entity cu_reg_n;
 
architecture behavioral of cu_reg_n is 
begin 

	process (clk, rst) is
	begin  
		if (rst = RST_V) then
			q <= (others => '0');
		elsif (clk'event and clk = CLK_V) then
			if (le = '1') then
				q <= d;
			end if;
		end if;
	end process; 
	
end architecture behavioral;
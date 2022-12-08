library ieee;
use ieee.std_logic_1164.all;

-- synchronous register
entity reg_n is
	
	-- N = I/O bit-width
	-- RST_V = reset value to reset
	-- CLK_V = clock value to sample
	generic (
		N : integer := 8;
		RST_V : std_logic := '1';
		CLK_V : std_logic := '1'
	);
	
	port (
		d_in : in std_logic_vector(N-1 downto 0);
		rst, clk, en : in std_logic;
		d_out : out std_logic_vector(N-1 downto 0)
	);
			
end entity reg_n;
 
architecture behavioral of reg_n is 
begin 

	process (clk) is
	begin  
		if (clk'event and clk = CLK_V) then
			if (rst = RST_V) then
				d_out <= (others => '0');
			elsif (en = '1') then
				d_out <= d_in;
			end if;
		end if;
	end process; 
	
end architecture behavioral;
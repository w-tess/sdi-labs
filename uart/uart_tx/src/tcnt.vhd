library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tcnt is

	generic(
		tcount : integer := 7
	);
	
	port(
		le, clk, rst : in std_logic;
		tc : out std_logic
	);
							 
end entity tcnt;

architecture behavioral of tcnt is 

	signal cnt : integer range 0 to tcount+1;

begin 

	-- processo che sintetizza un contatore con
	-- enable e reset sincroni
	cnt_proc : process(clk) is
	begin
		if(clk'event and clk = '1') then
			if rst = '1' then
				cnt <= 0;
			elsif le = '1' then
				cnt <= cnt + 1;
			end if;
		end if;
	end process;

	-- processo combinatorio per attivare il 
	-- terminal count "tc"
	tc_active : process(cnt) is
	begin
		tc <= '0';
		if(cnt = tcount) then
			tc <= '1';
		end if;
    end process;

end architecture behavioral;
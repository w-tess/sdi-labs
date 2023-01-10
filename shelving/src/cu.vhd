library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cu is
	port (
		CLK : in std_logic;
		RST_n : in std_logic;
		VIN : in std_logic;
		LE1 : out std_logic;
		LE2 : out std_logic;
		LE3 : out std_logic;
		RSTN : out std_logic;
		DONE : out std_logic
	);
end cu;

architecture beh of cu is
	type state_t is (IDLE_S, VALID_S, RESET_S);
	signal state : state_t;
	signal future_state : state_t;
	
	begin --beh
	
		process (VIN, RST_n, state)
		begin --process
		case state is
			when RESET_S =>
				if (RST_n = '1') then
					future_state <= IDLE_S;
				else
					future_state <= RESET_S;
				end if;
			when VALID_S =>
				if (RST_n = '0') then
					future_state <= RESET_S;
				else 
					if(VIN = '1') then
						future_state <= VALID_S;
					else 
						future_state <= IDLE_S;
					end if;
				end if;
			when IDLE_S =>
				if (RST_n = '0') then
					future_state <= RESET_S;
				else 
					if(VIN = '1') then
						future_state <= VALID_S;
					else 
						future_state <= IDLE_S;
					end if;
				end if;
			when others =>
				future_state <= RESET_S;
		end case;
		end process;
	
		process(CLK)
		begin --process
		if CLK'event and CLK = '1' then
			state <= future_state;
		end if;
		end process;
		
		process (state)
		begin --process
		LE1 <= '1';
		LE2 <= '0';
		LE3 <= '0';
		RSTN <= '1';
		DONE <= '0';
		case state is 
			when RESET_S => 
				LE1 <= '0';
				LE3 <= '1';
				RSTN <= '0';
			when VALID_S => 
				LE2 <= '1';
				DONE <= '1';
			when IDLE_S => 
			when others => 
		end case;
		end process;
end beh;
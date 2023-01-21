library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cu_audio_proc is

	port (
		clk : in std_logic;
		rst_n : in std_logic;
		vin : in std_logic;
		le1 : out std_logic;
		le2 : out std_logic;
		le3 : out std_logic;
		rst : out std_logic;
		done : out std_logic
	);
	
end entity cu_audio_proc;

architecture behavioral of cu_audio_proc is
	type state_t is (RESET, INIT, IDLE, HOLD, VALID);
	signal state : state_t;
	signal next_state : state_t;
	
	begin
	
		state_transition : process (vin, state) is
		begin 
			case state is
				when RESET =>
					next_state <= INIT;
				when INIT => 
					next_state <= IDLE;
				when IDLE =>
					if(vin = '1') then
						next_state <= HOLD;
					else 
						next_state <= IDLE;
					end if;
				when HOLD => 
					next_state <= VALID;
				when VALID =>
					next_state <= IDLE;
				when others =>
					next_state <= RESET;
			end case;
		end process;
	
		state_register : process(clk, rst_n) is
		begin
			if rst_n = '0' then
				state <= RESET;
			elsif clk'event and clk = '1' then
				state <= next_state;
			end if;
		end process;
		
		output_evaluation : process(state) is
		begin
			-- valori di default
			le1 <= '0';
			le2 <= '0';
			le3 <= '0';
			rst <= '0';
			done <= '0';
			
			case state is
				when RESET => 
					rst <= '1';
				when INIT => 
					le3 <= '1';
				when IDLE => 
					le1 <= '1';
				when HOLD => 
				when VALID => 
					le2 <= '1';
					done <= '1';
				when others => 
			end case;
		
		end process;

end architecture behavioral;
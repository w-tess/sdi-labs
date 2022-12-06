library ieee;
use ieee.std_logic_1164.all;

entity control_unit_rx is
	
	port(
		cu_clk, cu_rst, cu_start_rx, cu_stop : in std_logic;
		cu_end_rx, cu_tc_sipo0, cu_tc_sipo1 : in std_logic;
		cu_sipo_rst, cu_sipo0_se, cu_sipo1_se : out std_logic;
		cu_cnt0_rst, cu_cnt0_le, cu_cnt1_rst: out std_logic;
		cu_cnt1_le, cu_done : out std_logic
	);
								  
end entity control_unit_rx;

architecture behavioral of control_unit_rx is
	
	type uart_rx_state is (
		RESET, WAIT_START, EN_SIPO0, START, 
		WAIT_SAMPLE, EN_SIPO0_2, EN_SIPO1, DONE
	);

	signal present_state, next_state : uart_rx_state;

begin

	-- processo di transizione stati

	state_transition : process (
		present_state, cu_start_rx, cu_stop, 
		cu_tc_sipo0, cu_tc_sipo1, cu_end_rx
		) is
	begin

		case present_state is
		
			when RESET => 
				next_state <= WAIT_START;
	
			when WAIT_START => 
				if(cu_start_rx = '1') then
					next_state <= START;
				else
					if(cu_tc_sipo0 = '1') then 
						next_state <= EN_SIPO0;
					else
						next_state <= WAIT_START;
					end if;
				end if;
								 
			when EN_SIPO0 => 
				next_state <= WAIT_START;

			when START => 
				next_state <= WAIT_SAMPLE;
			
			when WAIT_SAMPLE => 
				if(cu_tc_sipo0 = '1') then
					next_state <= EN_SIPO0_2;
				else 
					next_state <= WAIT_SAMPLE;
				end if;
								 
			when EN_SIPO0_2 => 
				if(cu_tc_sipo1 = '1') then
					next_state <= EN_SIPO1;
				else
					next_state <= WAIT_SAMPLE;
				end if;
										 
			when EN_SIPO1 => 
				if(cu_end_rx = '1') then
					if(cu_stop = '1') then
						next_state <= DONE;
					else
						next_state <= RESET;
					end if;
				else
					next_state <= WAIT_SAMPLE;			
				end if;
							  
			when DONE => 
				next_state <= RESET;
			
			when others => 
				next_state <= RESET;
		
		end case;
	
	end process;
	
	-- processo di aggiornamento dello stato

	state_updating : process(cu_clk, cu_rst) is
	begin
	
		if(cu_rst = '0') then
			present_state <= RESET;
		elsif(cu_clk'event and cu_clk = '1') then
			present_state <= next_state;
		end if;
	
	end process;
	
	-- processo di aggiornamento delle uscite

	output_evaluation : process(present_state) is
	begin
		
		cu_sipo_rst <= '0';
		cu_sipo0_se <= '0';
		cu_sipo1_se <= '0';
		cu_cnt0_rst <= '0';
		cu_cnt1_rst <= '0';
		cu_cnt0_le <= '0';
		cu_cnt1_le <= '0';
		cu_done <= '0';
		
		case present_state is
			
			when RESET => 
				cu_sipo_rst <= '1';
				cu_cnt0_rst <= '1';
				cu_cnt1_rst <= '1';
			
			when WAIT_START => 
				cu_cnt0_le <= '1';
			
			when EN_SIPO0 => 
				cu_sipo0_se <= '1';
				cu_cnt0_rst <= '1';

			when START => 
				cu_sipo1_se <=  '1';
				cu_cnt0_le <=  '1';
				cu_cnt1_le <=  '1';
			
			when WAIT_SAMPLE => 
				cu_cnt0_le <= '1';
				cu_cnt1_le <= '1';
			
			when EN_SIPO0_2 => 
				cu_sipo0_se <= '1';
				cu_cnt0_rst <= '1';
				cu_cnt1_le <= '1';
			
			when EN_SIPO1 => 
				cu_sipo1_se <= '1';
				cu_cnt0_le <= '1';
				cu_cnt1_rst <= '1';
			
			when DONE => 
				cu_done <= '1';
			
			when others =>
		
		end case;
			
	end process;

end architecture behavioral;
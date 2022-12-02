library ieee;
use ieee.std_logic_1164.all;

entity tb_control_unit_rx is
end entity tb_control_unit_rx;

architecture test of tb_control_unit_rx is

	component control_unit_rx is
	
		port(
			cu_clk, cu_rst, cu_start_rx, cu_stop : in std_logic;
			cu_end_rx, cu_tc_sipo0, cu_tc_sipo1 : in std_logic;
			cu_sipo_rst, cu_sipo0_se, cu_sipo1_se : out std_logic;
			cu_cnt0_rst, cu_cnt0_le, cu_cnt1_rst : out std_logic;
			cu_cnt1_le, cu_done : out std_logic
		);
									  
	end component control_unit_rx;
	
	signal tb_cu_clk, tb_cu_rst, tb_cu_start_rx : std_logic;
	signal tb_cu_stop, tb_cu_tc_sipo0, tb_cu_tc_sipo1 : std_logic;
	signal tb_cu_end_rx, tb_cu_sipo_rst, tb_cu_sipo0_se : std_logic;
	signal tb_cu_sipo1_se, tb_cu_cnt0_rst, tb_cu_cnt0_le : std_logic;
	signal tb_cu_cnt1_rst, tb_cu_cnt1_le, tb_cu_done : std_logic;

	constant tck : time := 10 ns;

begin

	DUT : control_unit_rx 
		port map(
			cu_clk => tb_cu_clk, 
			cu_rst => tb_cu_rst, 
			cu_start_rx => tb_cu_start_rx, 
			cu_stop => tb_cu_stop,
			cu_end_rx => tb_cu_end_rx,
			cu_tc_sipo0 => tb_cu_tc_sipo0, 
			cu_tc_sipo1 => tb_cu_tc_sipo1, 
			cu_sipo_rst => tb_cu_sipo_rst, 
			cu_sipo0_se => tb_cu_sipo0_se, 
			cu_sipo1_se => tb_cu_sipo1_se, 
			cu_cnt0_rst => tb_cu_cnt0_rst, 
			cu_cnt0_le => tb_cu_cnt0_le, 
			cu_cnt1_rst => tb_cu_cnt1_rst, 
			cu_cnt1_le => tb_cu_cnt1_le, 
			cu_done => tb_cu_done
		);
										 
	tb_clk_gen : process is
	begin
		tb_cu_clk <= '0', '1' after tck/2;
		wait for tck;
	end process;
	
	tb_cu_rst <= '0', '1' after tck/4;
	
	tb_cu_start_rx <= '0', '1' after 6*tck, 
						   '0' after 7*tck;
		
	tb_cu_tc_sipo0 <= '0', '1' after 3*tck, 
						   '0' after 4*tck, 
						   '1' after 9*tck, 
						   '0' after 10*tck,
						   '1' after 12*tck, 
						   '0' after 13*tck,
						   '1' after 15*tck,
						   '0' after 16*tck;
	
	tb_cu_tc_sipo1 <= '0', '1' after 13*tck, 
						   '0' after 14*tck,
						   '1' after 16*tck,
						   '0' after 17*tck;

	tb_cu_stop <= '0', '1' after 15*tck;
	
	tb_cu_end_rx <= '0', '1' after 15*tck;

end architecture test;
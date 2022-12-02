library ieee;
use ieee.std_logic_1164.all;

entity tb_control_unit_tx is
end entity;

architecture test of tb_control_unit_tx is

	component control_unit_tx is 
	
		port(
			clk, cu_rst : in std_logic;
			cu_wr, cu_tc, cu_stop : in std_logic;
			cu_reg_le, cu_piso_le, cu_piso_se : out std_logic;
			cu_piso_rst, cu_cnt_rst, cu_cnt_le : out std_logic
		);
	
	end component control_unit_tx;

	signal tb_cu_rst, tb_cu_wr : std_logic;
	signal tb_cu_tc, tb_cu_stop : std_logic;
	signal tb_cu_reg_le, tb_cu_piso_le, tb_cu_piso_se : std_logic;
	signal tb_cu_piso_rst, tb_cu_cnt_rst, tb_cu_cnt_le : std_logic;
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	
	constant tck : time := 10 ns;

begin

	DUT : control_unit_tx 
		port map(
			clk => tb_clk, 
			cu_rst => tb_cu_rst, 
			cu_wr => tb_cu_wr, 
			cu_tc => tb_cu_tc,
			cu_stop => tb_cu_stop, 
			cu_reg_le => tb_cu_reg_le, 
			cu_piso_le => tb_cu_piso_le, 
			cu_piso_se => tb_cu_piso_se, 
			cu_piso_rst => tb_cu_piso_rst,
			cu_cnt_rst => tb_cu_cnt_rst, 
			cu_cnt_le => tb_cu_cnt_le
		);

	clk_gen : process is
	begin
		tb_clk <= tb_clk nor end_sim;
		wait for tck/2;
	end process;

	ctrl_gen : process is
	begin
		tb_cu_rst <= '0'; tb_cu_wr <= '0';
		tb_cu_tc <= '0'; tb_cu_stop <= '0';
		wait for tck/10;
		tb_cu_rst <= '1';
		wait for tck/10*9;
		wait for tck;
		tb_cu_wr <= '1';
		wait for tck;
		tb_cu_wr <= '0';
		wait for 3*tck;
		tb_cu_tc <= '1';
		wait for tck;
		tb_cu_tc <= '0';
		wait for 3*tck;
		tb_cu_tc <= '1'; tb_cu_stop <= '1';
		wait for tck;
		tb_cu_tc <= '0';
		wait for tck;
		end_sim <= '1';
		wait;
	end process;

end architecture test;
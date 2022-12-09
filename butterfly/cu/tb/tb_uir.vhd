library ieee;
use ieee.std_logic_1164.all;
use work.type_def.all;

entity tb_uir is
end entity tb_uir;

architecture test of tb_uir is
	component uir is
		generic (
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);
		port (
			d : in rom_t;
			rst, clk, le : in std_logic;
			q : out rom_t
		);		
	end component uir;

	signal tb_rst, tb_le : std_logic;
	signal tb_d, tb_q : rom_t;
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin
	
	DUT : uir
		generic map(RST_V => '0')
		port map(
			d => tb_d,
			rst => tb_rst,
			clk => tb_clk,
			le => tb_le,
			q => tb_q
		);

	clk_gen : process is
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;

		if end_sim = '1' then
			assert false 
			report "simulation completed succesfully." 
			severity note;
			wait;
		end if;
	end process;

	data_gen : process is
	begin
		tb_rst <= '1';
		tb_le <= '1';
		tb_d <= (
			cc => '1', 
			next_state => "0000", 
			rom_sel_in => '0', 
			rom_sel_int => "000", 
			rom_sel_out => '1', 
			rom_le => "0000000011", 
			rom_sel_mux01 => '0', 
			rom_sel_mux2 => '0', 
			rom_sel_mux3 => "00", 
			rom_done => '0'
		);
		wait for 2 ns;
		tb_rst <= '0';
		wait for 1 ns;
		tb_rst <= '1';
		wait for 7 ns;
		tb_d <= (
			cc => '0', 
			next_state => "0011", 
			rom_sel_in => '0', 
			rom_sel_int => "000", 
			rom_sel_out => '0', 
			rom_le => "0000010100", 
			rom_sel_mux01 => '0', 
			rom_sel_mux2 => '0', 
			rom_sel_mux3 => "00", 
			rom_done => '0'
		);
		wait for tck;
		tb_d <= (
			cc => '0', 
			next_state => "0101", 
			rom_sel_in => '1', 
			rom_sel_int => "111", 
			rom_sel_out => '1', 
			rom_le => "0010000000", 
			rom_sel_mux01 => '0', 
			rom_sel_mux2 => '0', 
			rom_sel_mux3 => "00", 
			rom_done => '0'
		);
		wait for tck;
		end_sim <= '1';
		wait;
	end process;
	
end architecture test;
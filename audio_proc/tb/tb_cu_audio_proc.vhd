library ieee;
use ieee.std_logic_1164.all;

entity tb_cu_audio_proc is
end entity tb_cu_audio_proc;

architecture test of tb_cu_audio_proc is
	
	component cu_audio_proc is
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
	end component cu_audio_proc;

	signal tb_rst_n, tb_vin : std_logic;
	signal tb_le1, tb_le2, tb_le3 : std_logic;
	signal tb_rst, tb_done : std_logic;
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin
	
	DUT : cu_audio_proc 
		port map(
			clk => tb_clk, 
			rst_n => tb_rst_n,
			vin => tb_vin,
			le1 => tb_le1,
			le2 => tb_le2,
			le3 => tb_le3,
			rst => tb_rst,
			done => tb_done
		);

	clk_gen : process is
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;

		if end_sim = '1' then wait; end if;
	end process;

	tb_rst_n <= '0', '1' after 1 ns;
	tb_vin <= '0', '1' after 3*tck, '0' after 4*tck;
	end_sim <= '1' after 8*tck;
	
end architecture test;
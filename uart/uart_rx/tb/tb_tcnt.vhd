library ieee;
use ieee.std_logic_1164.all;

entity tb_tcnt is
end entity tb_tcnt;

architecture test of tb_tcnt is

	component tcnt is

		generic(
			tcount : integer := 3
		);
		
		port(
			le, clk, rst : in std_logic;
			tc : out std_logic
		);
								 
	end component tcnt;

	signal tb_le, tb_rst, tb_tc : std_logic;
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin

	DUT : tcnt 
		generic map(tcount => 7)
		port map(
			le => tb_le,
			clk => tb_clk,
			rst => tb_rst,
			tc => tb_tc
		);

	clk_gen : process is
	begin
		tb_clk <= tb_clk nor end_sim;
		wait for tck/2;
	end process;

	data_gen : process is
	begin
		tb_rst <= '1'; tb_le <= '1';
		wait for tck;
		tb_rst <= '0';
		wait for 3*tck;
		tb_rst <= '1';
		wait for tck;
		tb_rst <= '0';
		wait;
	end process;

	-- processo di termine simulazione,
	-- end_sim si attiva un ciclo di clock
	-- dopo l'attivazione di "tc"
	proc_end : process is
	begin
		wait until tb_tc = '1';
		wait for tck;
		end_sim <= '1';
		wait;
	end process;

end architecture test;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity tb_cu_butterfly is
end entity tb_cu_butterfly;

architecture test of tb_cu_butterfly is
	
	component cu_butterfly is
		port(
			cu_reset : in std_logic;
			cu_clk : in std_logic;
			cu_start : in std_logic;
			cu_commands : out commands_t
		);
	end component cu_butterfly;

	signal tb_cu_reset : std_logic := '1';
	signal tb_cu_clk : std_logic := '1';
	signal tb_cu_start : std_logic;
	signal tb_cu_commands : commands_t;
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin
	
	DUT : cu_butterfly port map(
		cu_reset => tb_cu_reset,
		cu_clk => tb_cu_clk,
		cu_start => tb_cu_start,
		cu_commands => tb_cu_commands
	);

	clk_gen : process is
	begin
		tb_cu_clk <= not tb_cu_clk;
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
		tb_cu_reset <= '1';
		tb_cu_start <= '0';
		wait for 3 ns;
		tb_cu_reset <= '0';
		wait for 1 ns;
		tb_cu_reset <= '1';
		wait for tck + 3 ns;
		tb_cu_start <= '1';
		wait for 4 ns;
		tb_cu_start <= '0';
		wait for 2 ns;
		tb_cu_start <= '1';
		wait for 5 ns;
		tb_cu_start <= '0';
		
		-- abilitare le 4 righe successive
		-- per esecuzione continua
		wait for 5*tck + 4 ns;
		tb_cu_start <= '1';
		wait for 5 ns;
		tb_cu_start <= '0';

		wait until tb_cu_commands.le = "0000000011";
		wait for tck;
		end_sim <= '1';
		wait;
	end process;
	
end architecture test;
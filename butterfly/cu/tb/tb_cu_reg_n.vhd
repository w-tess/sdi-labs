library ieee;
use ieee.std_logic_1164.all;

entity tb_cu_reg_n is
end entity tb_cu_reg_n;

architecture test of tb_cu_reg_n is
	component cu_reg_n is
		generic (
			N : integer := 8;
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);
		port (
			d : in std_logic_vector(N-1 downto 0);
			rst, clk, le : in std_logic;
			q : out std_logic_vector(N-1 downto 0)
		);		
	end component cu_reg_n;

	signal tb_rst, tb_le : std_logic;
	signal tb_d, tb_q : std_logic_vector(7 downto 0);
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin
	
	DUT : cu_reg_n
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
		tb_d <= x"2A";
		wait for 2 ns;
		tb_rst <= '0';
		wait for 1 ns;
		tb_rst <= '1';
		wait for 7 ns;
		tb_d <= x"1B";
		wait for tck;
		tb_d <= x"62";
		wait for tck;
		tb_d <= x"3E";
		wait for tck;
		end_sim <= '1';
		wait;
	end process;
	
end architecture test;
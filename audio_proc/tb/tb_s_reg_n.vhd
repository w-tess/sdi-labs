library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_s_reg_n is
end entity tb_s_reg_n;

architecture test of tb_s_reg_n is
	
	component s_reg_n is  

		generic (
			N : integer := 8;
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);
		
		port (
			d_in : in signed(N-1 downto 0);   
			rst, clk, en : in std_logic;   
			d_out : out signed(N-1 downto 0)
		);
				
	end component s_reg_n; 

	signal tb_d_in, tb_d_out : signed(7 downto 0);
	signal tb_rst, tb_clk, tb_en : std_logic;

begin
	
	DUT : s_reg_n port map(d_in => tb_d_in, d_out => tb_d_out, 
						   rst => tb_rst, clk => tb_clk, en => tb_en);
	
	clk_gen : process is
	begin
		tb_clk <= '0', '1' after 5 ns;
		wait for 10 ns;
	end process;

	tb_d_in <= X"D1", X"8A" after 10 ns, X"7B" after 20 ns,
					  X"24" after 30 ns, X"09" after 40 ns;

	tb_rst <= '0', '1' after 50 ns, '0' after 60 ns;

	tb_en <= '1', '0' after 20 ns, '1' after 30 ns;
	
end architecture test;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_rx is

	generic(
		TSYMB : integer := 32;
		NFRAME : integer := 10
	);

end entity tb_uart_rx;

architecture test of tb_uart_rx is
	
	component uart_rx is

		generic (
			TSYMB : integer := 1042;
			N : integer := 8
		);
	
		port (
			rx, clk, rst : in std_logic;
			done : out std_logic;
			dout : out std_logic_vector(N-1 downto 0)
		);
																					 
	end component uart_rx;

	signal tb_rx, tb_clk, tb_rst, tb_done : std_logic;
	signal tb_dout : std_logic_vector(NFRAME-3 downto 0);

	constant tck : time := 10 ns;
begin

	DUT : uart_rx 
		generic map (
			TSYMB => TSYMB,
			N => NFRAME - 2
		)
		port map (
			rx => tb_rx, 
			clk => tb_clk, 
			rst => tb_rst, 
			done => tb_done, 
			dout => tb_dout
		);

	clk_gen : process is
	begin
		tb_clk <= '0', '1' after tck/2;
		wait for tck;
	end process;

	tb_rst <= '0', '1' after tck/4;

	tb_rx <= '1', '0' after TSYMB*tck, 
				  '0' after 2*TSYMB*tck,
				  '1' after 3*TSYMB*tck, 
				  '1' after 4*TSYMB*tck,
			  	  '0' after 5*TSYMB*tck,
				  '0' after 6*TSYMB*tck,
				  '0' after 7*TSYMB*tck,
				  '1' after 8*TSYMB*tck, 
				  '0' after 9*TSYMB*tck, 
				  '1' after 10*TSYMB*tck;

end architecture test;
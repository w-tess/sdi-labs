library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fft_1616 is
end entity tb_fft_1616;

architecture behavioral of tb_fft_1616 is
	
	component fft_1616 is
		port(
			start, clk, reset_n : in std_logic;
			samples : in fft_t(0 to 15);
			fourth_level : out fft_t(0 to 15);
			fourth_done : out done_vect_t
		);
	end component fft_1616;

begin
	
	
	
end architecture behavioral;
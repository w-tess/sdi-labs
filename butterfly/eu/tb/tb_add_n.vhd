library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_add_n is
	generic(N : integer := 33);
end entity tb_add_n;

architecture test of tb_add_n is
	
	component add_n is
		generic (
			N : integer := 33
		);
		port (
			clk : in std_logic;
			sub_add_n : in std_logic;
			ina, inb: in signed(N-1 downto 0);
			outc: out signed(N-1 downto 0)
		);
	end component add_n;

	signal tb_clk : std_logic := '1';
	signal tb_sub_add_n : std_logic;
	signal tb_ina, tb_inb, tb_outc : signed(N-1 downto 0);
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin
	
	DUT : add_n 
		generic map(N => N)
		port map(
			clk => tb_clk,
			sub_add_n => tb_sub_add_n,
			ina => tb_ina,
			inb => tb_inb,
			outc => tb_outc
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
		tb_sub_add_n <= '0';
		tb_ina <= to_signed(20934, N); 
		tb_inb <= to_signed(-5867, N);
		wait for 10 ns;
		tb_ina <= to_signed(-405, N); 
		tb_inb <= to_signed(6043, N);
		wait for 10 ns;
		tb_ina <= to_signed(277, N); 
		tb_inb <= to_signed(24, N);
		wait for 10 ns;
		tb_sub_add_n <= '1';
		tb_ina <= to_signed(-2454, N); 
		tb_inb <= to_signed(-57, N);
		wait for 10 ns;
		tb_ina <= to_signed(-5690, N); 
		tb_inb <= to_signed(0, N);
		wait for 10 ns;
		tb_ina <= to_signed(1, N); 
		tb_inb <= to_signed(8959, N);
		wait for 10 ns;
		end_sim <= '1';
		wait;
	end process;

end architecture test;
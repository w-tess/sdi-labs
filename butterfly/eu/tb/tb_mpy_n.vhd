library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- nei testbench l'entity non presenta segnali di I/O,
-- tuttavia e' comoda la possibilita' di utilizzare 
-- dei generics per parametrizzare anche la simulazione
entity tb_mpy_n is
	generic(N : integer := 33);
end entity tb_mpy_n;

architecture test of tb_mpy_n is
	
	component mpy_n is
		generic (
			N : integer := 33
		);
		port (
			clk : in std_logic;
			ina, inb : in signed(N-1 downto 0);
			outc : out signed(N-1 downto 0)
		);
	end component mpy_n;

	signal tb_clk : std_logic := '1';
	signal tb_ina, tb_inb, tb_outc : signed(32 downto 0);
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin
	
	DUT : mpy_n 
		generic map(N => 33)
		port map(
			clk => tb_clk,
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

	-- stimoli
	-- essendo il moltiplicatore pensato per lavorare 
	-- con dati su 33 bit, ma con soli 16 bit significativi,
	-- i campioni usati per il test sono tutti campioni in 
	-- CA2 rappresentabili su 16 bit
	data_gen : process is
	begin
		tb_ina <= to_signed(20934, 33); 
		tb_inb <= to_signed(-5867, 33);
		wait for 10 ns;
		tb_ina <= to_signed(-405, 33); 
		tb_inb <= to_signed(6043, 33);
		wait for 10 ns;
		tb_ina <= to_signed(277, 33); 
		tb_inb <= to_signed(24, 33);
		wait for 10 ns;
		tb_ina <= to_signed(-2454, 33); 
		tb_inb <= to_signed(-57, 33);
		wait for 10 ns;
		tb_ina <= to_signed(-5690, 33); 
		tb_inb <= to_signed(0, 33);
		wait for 10 ns;
		tb_ina <= to_signed(1, 33); 
		tb_inb <= to_signed(8959, 33);
		wait for 10 ns;
		end_sim <= '1';
		wait;
	end process;

end architecture test;
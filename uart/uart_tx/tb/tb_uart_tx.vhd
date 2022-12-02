library ieee;
use ieee.std_logic_1164.all;

-- nei testbench l'entity non presenta segnali di I/O,
-- tuttavia e' comoda la possibilita' di utilizzare 
-- dei generics per parametrizzare anche la simulazione
-- 
-- TSYMB: tempo di simbolo inteso in cicli di clock
-- NFRAME: lunghezza in bit del frame totale
entity tb_uart_tx is
	generic(
		TSYMB : integer := 4;
		NFRAME : integer := 10
	);
end entity tb_uart_tx;

architecture test of tb_uart_tx is

	component uart_tx is

		generic(
			TSYMB : integer := 1042;
			N : integer := 8
		);
	
		port(		 
			din : in std_logic_vector(N-1 downto 0);
			wr, rst, clk : in std_logic;
			tx : out std_logic
		);
		
	end component uart_tx;

	signal tb_din : std_logic_vector(NFRAME-3 downto 0);
	signal tb_wr, tb_rst, tb_tx : std_logic;
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin

	-- il generic "N" della uart rappresenta la lunghezza
	-- in bit della word in ingresso e non del frame, dunque
	-- nel generic map si passa NFRAME-2
	DUT : uart_tx 
		generic map(TSYMB => TSYMB, N => NFRAME-2)
		port map(
			din => tb_din, 
			wr => tb_wr, 
			rst => tb_rst, 
			clk => tb_clk, 
			tx => tb_tx
		);

	-- process di generazione del clock, e' comoda la
	-- presenza del segnale end_sim per disattivare 
	-- a fini simulativi il funzionamento del clock
	clk_gen : process is
	begin
		tb_clk <= tb_clk nor end_sim;
		wait for tck/2;
	end process;

	-- process di generazione dei dati, tframe rappresenta
	-- il tempo di trasmissione dell'intero frame, espresso
	-- in cicli di clock
	data_gen : process is
		constant tframe: time := (NFRAME*TSYMB+1)*tck;
	begin
		tb_rst <= '0'; tb_wr <= '0';
		wait for tck/10;
		tb_rst <= '1';
		wait for tck/10*9;
		tb_wr <= '1'; tb_din <= "01011100";
		wait for tck;
		tb_wr <= '0';
		wait for tframe;
		tb_wr <= '1'; tb_din <= "00010110";
		wait for tck;
		tb_wr <= '0';
		wait for tframe;
		tb_wr <= '1'; tb_din <= "10001001";
		wait for tck;
		tb_wr <= '0';
		wait for tframe;
		end_sim <= '1';
		wait;
	end process;

end architecture test;
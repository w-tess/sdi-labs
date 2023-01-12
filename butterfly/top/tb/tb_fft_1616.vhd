library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.type_def.all;

-- testbench della fft_16x16
-- il testbench riceve i campioni relativi ad 8 funzioni
-- di test non casuali ma interpretabili (sinusoidi, onda
-- quadra, onda triangolare ...) e di cui si conosce bene
-- lo spettro; i campioni vengono quindi forniti alla fft
-- che genera lo spettro corrispondente.
-- i risultati ottenuti infine, sono scritti su un file e
-- confrontati con lo spettro generato da uno script MATLAB
entity tb_fft_1616 is
	generic(
		-- numero di funzioni di test
		NSAMPLES : integer := 8
	);
end entity tb_fft_1616;

architecture behavioral of tb_fft_1616 is
	
	component fft_1616 is
		generic(
			N : integer := 16
		);
		port(
			start, clk, reset_n : in std_logic;
			samples : in fft_t(0 to 15);
			results : out fft_t(0 to 15);
			done : out done_vect_t
		);
	end component fft_1616;

	signal tb_start, tb_reset_n : std_logic;
	signal tb_samples, tb_results : fft_t(0 to 15);
	signal tb_clk : std_logic := '1';
	signal tb_done : done_vect_t;
	signal end_sim : std_logic := '0';

	-- SF ripristina i campioni dello spettro generato
	-- moltiplicandoli per 32
	constant SF : integer := 2**5;
	constant tck : time := 10 ns;

begin
	
	-- processo di inizializzazione della fft_16x16
	initialize : process is
	begin
		tb_reset_n <= '0';
		wait for tck/10;
		tb_reset_n <= '1';
		wait;
	end process;

	-- processo di generazione del clock
	clock_gen : process
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;

		if end_sim = '1' then
			report "simulation completed succesfully.";
			wait;
		end if;
	end process;

	-- processo di generazione del segnale di start
	start_gen : process
	begin
		tb_start <= '1', '0' after tck;
		wait for 6*tck;

		if end_sim = '1' then wait; end if;
	end process;

	-- processo di lettura dei campioni e generazione 
	-- degli stimoli per la fft
	samples_gen : process
		file samplesfile : text;
		variable samplesline : line;
		variable samplesi : integer;
	begin
		-- apro il file con i campioni
		file_open(samplesfile, "fft_vectors.txt");

		-- loop in cui svolgo le operazioni di lettura
		while not endfile(samplesfile) loop
			wait until falling_edge(tb_start);
			-- lettura dei 16 campioni reali			
			readline(samplesfile, samplesline);
			for i in tb_samples'range loop
				read(samplesline, samplesi); 
				tb_samples(i) <= to_signed(samplesi, IOBITS);
			end loop;

			wait for tck;
			-- lettura dei 16 campioni immaginari
			readline(samplesfile, samplesline);
			for i in tb_samples'range loop
				read(samplesline, samplesi); 
				tb_samples(i) <= to_signed(samplesi, IOBITS);
			end loop;
		end loop;

		-- chiudo il file di lettura
		file_close(samplesfile);
		wait;
	end process;

	-- processo di lettura dei risultati e scrittura
	-- dei campioni su file
	results_gen : process
		file resultsfile : text;
		variable resultsline : line;
		variable resultsi : integer;
	begin
		file_open(resultsfile, "fft_results.txt", write_mode);

		for cnt in 0 to NSAMPLES-1 loop
			-- aspetto che la fft_16x16 termini l'esecuzione
			wait until falling_edge(tb_done(0));
			wait for tck/2;
			-- lettura dei campioni reali, dato che i risultati in
			-- uscita sono scalati di un fattore SF, moltiplico
			-- ciascuna uscita per SF per ottenere il dato corretto
			for i in tb_results'range loop
				resultsi := to_integer(tb_results(i));
				resultsi := resultsi * SF;
				write(resultsline, resultsi, right, 7);
				write(resultsline, ' ');
			end loop;
			writeline(resultsfile, resultsline);
			
			-- lettura dei campioni immaginari
			wait for tck;
			for i in tb_results'range loop
				resultsi := to_integer(tb_results(i));
				resultsi := resultsi * SF;
				write(resultsline, resultsi, right, 7);
				write(resultsline, ' ');
			end loop;
			writeline(resultsfile, resultsline);
		end loop;

		-- chiudo il file di scrittura
		file_close(resultsfile);
		end_sim <= '1';
		wait;
	end process;

	DUT : fft_1616 
		generic map(N => IOBITS)
		port map(
			start => tb_start,
			clk => tb_clk,
			reset_n => tb_reset_n,
			samples => tb_samples,
			results => tb_results,
			done => tb_done
		);
	
end architecture behavioral;
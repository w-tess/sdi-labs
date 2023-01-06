library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.type_def.all;

entity tb_fft_1616 is
	generic(
		NSAMPLES : integer := 8;
		N : integer := 16
	);
end entity tb_fft_1616;

architecture behavioral of tb_fft_1616 is
	
	component fft_1616 is
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
	signal end_sim : std_logic := '0';
	signal tb_done : done_vect_t;

	constant SF : integer := 2**5;
	constant tck : time := 10 ns;

begin
	
	initialize : process is
	begin
		tb_reset_n <= '0';
		wait for tck/10;
		tb_reset_n <= '1';
		wait;
	end process;

	clock_gen : process
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;

		if end_sim = '1' then
			report "simulation completed succesfully.";
			wait;
		end if;
	end process;

	start_gen : process
	begin
		tb_start <= '1', '0' after tck;
		wait for 6*tck;

		if end_sim = '1' then wait; end if;
	end process;

	samples_gen : process
		file samplesfile : text;
		variable samplesline : line;
		variable samplesi : integer;
	begin
		file_open(samplesfile, "fft_vectors.txt");

		while not endfile(samplesfile) loop
			wait until falling_edge(tb_start);
			readline(samplesfile, samplesline);
			for i in tb_samples'range loop
				read(samplesline, samplesi); 
				tb_samples(i) <= to_signed(samplesi, N);
			end loop;

			wait for tck;
			readline(samplesfile, samplesline);
			for i in tb_samples'range loop
				read(samplesline, samplesi); 
				tb_samples(i) <= to_signed(samplesi, N);
			end loop;
		end loop;

		file_close(samplesfile);
		wait;
	end process;

	results_gen : process
		file resultsfile : text;
		variable resultsline : line;
		variable resultsi : integer;
	begin
		file_open(resultsfile, "fft_results.txt", write_mode);

		for cnt in 0 to NSAMPLES-1 loop
			wait until falling_edge(tb_done(0));
			wait for tck/2;
			for i in tb_results'range loop
				resultsi := to_integer(tb_results(i));
				resultsi := resultsi * SF;
				write(resultsline, resultsi, right, 7);
				write(resultsline, ' ');
			end loop;
			writeline(resultsfile, resultsline);

			wait for tck;
			for i in tb_results'range loop
				resultsi := to_integer(tb_results(i));
				resultsi := resultsi * SF;
				write(resultsline, resultsi, right, 7);
				write(resultsline, ' ');
			end loop;
			writeline(resultsfile, resultsline);

			wait for tck;
		end loop;

		file_close(resultsfile);
		end_sim <= '1';
		wait;
	end process;

	DUT : fft_1616 
		port map(
			start => tb_start,
			clk => tb_clk,
			reset_n => tb_reset_n,
			samples => tb_samples,
			results => tb_results,
			done => tb_done
		);
	
end architecture behavioral;
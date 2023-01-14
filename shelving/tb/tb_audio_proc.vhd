library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_audio_proc is
end entity tb_audio_proc;

architecture test of tb_audio_proc is
	
	component audio_proc is
		port (
			clk : in std_logic;
			a1_L, a2_L, b0_L, b1_L, b2_L : in signed(11 downto 0);
			a1_H, a2_H, b0_H, b1_H, b2_H : in signed(11 downto 0);
			x_n : in signed(7 downto 0);
			sw : in std_logic_vector(1 downto 0);
			vin, rst_n : in std_logic;
			y_n : out signed(7 downto 0);
			vout : out std_logic
		);
	end component audio_proc;

	signal tb_a1_L, tb_a2_L, tb_b0_L : signed(11 downto 0);
	signal tb_b1_L, tb_b2_L, tb_a1_H : signed(11 downto 0);
	signal tb_a2_H, tb_b0_H, tb_b1_H, tb_b2_H : signed(11 downto 0);
	signal tb_x_n, tb_y_n : signed(7 downto 0);
	signal tb_sw : std_logic_vector(1 downto 0);
	signal tb_vin, tb_rst_n, tb_vout : std_logic;
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';

	-- SF ripristina i campioni forniti dal filtro shelving
	-- che sono stati scalati di 3 bit in uscita
	constant SF : integer := 2**3;
	constant tck : time := 10 ns;

begin
	
	DUT : audio_proc
		port map(
			clk   => tb_clk,
			a1_L  => tb_a1_L,
			a2_L  => tb_a2_L,
			b0_L  => tb_b0_L,
			b1_L  => tb_b1_L,
			b2_L  => tb_b2_L,
			a1_H  => tb_a1_H,
			a2_H  => tb_a2_H,
			b0_H  => tb_b0_H,
			b1_H  => tb_b1_H,
			b2_H  => tb_b2_H,
			x_n   => tb_x_n,
			sw    => tb_sw,
			vin   => tb_vin,
			rst_n => tb_rst_n,
			y_n   => tb_y_n,
			vout  => tb_vout
		);

	tb_rst_n <= '0', '1' after tck/10;

	-- processo di generazione del clock
	clock_gen : process is
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;
		
		if end_sim = '1' then
			report "simulation completed succesfully.";
			wait;
		end if;
	end process;

	-- processo di lettura dei coefficienti per i due 
	-- filtri shelving e del valore per l'ingresso sw
	coeff_gen : process is
		file coefffile : text;
		variable coeffline : line;
		variable coeffi : integer;
	begin
		file_open(coefffile, "shelving_coefficients.txt");

		wait for tck;

		-- leggo i coefficienti e genero gli stimoli
		readline(coefffile, coeffline);
		read(coeffline, coeffi); tb_a1_L <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_a2_L <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_b0_L <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_b1_L <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_b2_L <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_a1_H <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_a2_H <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_b0_H <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_b1_H <= to_signed(coeffi, 12);
		read(coeffline, coeffi); tb_b2_H <= to_signed(coeffi, 12);
		-- leggo il valore da assegnare all'ingresso sw
		readline(coefffile, coeffline);
		read(coeffline, coeffi);
		tb_sw <= std_logic_vector(to_signed(coeffi, 2));

		file_close(coefffile);
		wait;
	end process;

	-- processo di lettura da file dei campioni in ingresso e 
	-- di scrittura su file dei risultati in uscita
	data_gen : process
		file samplesfile, resultsfile : text;
		variable samplesline, resultsline : line;
		variable samplesi, resultsi : integer;
	begin
		-- apro il file con i campioni
		file_open(samplesfile, "shelving_samples.txt");
		-- apro il file in cui scrivere i risultati
		file_open(resultsfile, "shelving_results.txt", write_mode);

		wait for 3*tck;
		
		-- loop in cui svolgo le operazioni di lettura
		while not endfile(samplesfile) loop
			readline(samplesfile, samplesline);
			read(samplesline, samplesi); 
			tb_x_n <= to_signed(samplesi, 8);
			tb_vin <= '1', '0' after tck;

			wait for 3*tck;
			resultsi := to_integer(tb_y_n);
			write(resultsline, resultsi);
			writeline(resultsfile, resultsline);
		end loop;

		-- chiudo il file di lettura
		file_close(samplesfile);
		-- chiudo il file di scrittura
		file_close(resultsfile);
		end_sim <= '1';
		wait;
	end process;
	
end architecture test;
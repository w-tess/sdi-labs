library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- testbench della butterfly
-- il testbench e' realizzato leggendo dei vettori
-- di test da file e fornendoli alla butterfly da 
-- testare ed al modello di confronto ideale
-- i 4 dati in uscita dai due blocchi vengono 
-- confrontati a coppie e se non risultano identici
-- viene fornito un messaggio di errore in output
-- ed incrementato un contatore che indica il numero
-- di errori totali a fine simulazione
entity tb_butterfly is
	-- ESEC_SING = test in esecuzione singola/continua
	-- SF = fattore di scalamento
	-- N = parallelismo di I/O
	generic(
		ESEC_SING : boolean := True;
		SF : std_logic := '1';
		N : integer := 16
	);
end entity tb_butterfly;

architecture test of tb_butterfly is
	
	component butterfly is
		generic(
			N : integer := 16
		);
		port (
			clk, reset_n : in std_logic;
			sf_2h_1l, start : in std_logic;
			ina, inb : in signed(N-1 downto 0);
			wr, wi : in signed(N-1 downto 0);
			outa, outb : out signed(N-1 downto 0);
			done : out std_logic
		);
	end component butterfly;

	component butterfly_ideal is
		generic(
			N : integer := 16
		);
		port (
			sf_2h_1l : in std_logic;
			ar, ai, br, bi, wr, wi : in signed(N-1 downto 0);
			out_ar, out_ai : out signed(N-1 downto 0);
			out_br, out_bi : out signed(N-1 downto 0)
		);
	end component butterfly_ideal;

	signal tb_start, tb_done : std_logic := '0';
	signal tb_reset_n, tb_sf_2h_1l : std_logic := '0';
	signal tb_ina, tb_inb : signed (N-1 downto 0);
	signal tb_outa, tb_outb : signed(N-1 downto 0);
	signal tb_ar, tb_ai, tb_br : signed(N-1 downto 0);
	signal tb_bi, tb_wr, tb_wi : signed(N-1 downto 0);
	signal tb_out_ar, tb_out_ai : signed(N-1 downto 0);
	signal tb_out_br, tb_out_bi : signed(N-1 downto 0);
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	signal errors : integer := 0;
	constant tck : time := 10 ns;

begin
	
	-- processo di initializzazione della butterfly
	initialize : process is
	begin
		tb_reset_n <= '0'; tb_sf_2h_1l <= SF;
		wait for tck/10;
		tb_reset_n <= '1';
		wait;
	end process;

	-- processo di generazione del clock
	clock_control : process is
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;

		if end_sim = '1' then
			if errors /= 0 then
				report "simulation completed with " & 
						integer'image(errors) & " errors.";
			else
				report "simulation completed succesfully.";
			end if;
			wait;
		end if;
	end process;

	-- processo di lettura dei vettori di test e
	-- generazione degli stimoli
	input_control : process is
		file vectorsfile : text;
		variable vectorsline : line;
		variable ari, aii, bri, bii, wri, wii : integer;
		variable first_pass : boolean := True;
	begin
		wait for tck;
		-- apro il file con i vettori di test
		file_open(vectorsfile, "bfly_vectors.txt");
		-- loop in cui svolgo le operazioni di lettura
		while not endfile(vectorsfile) loop
			-- lettura line
			readline(vectorsfile, vectorsline);
			-- assegnazione dati 
			read(vectorsline, ari); tb_ar <= to_signed(ari, N);
			read(vectorsline, aii); tb_ai <= to_signed(aii, N);
			read(vectorsline, bri); tb_br <= to_signed(bri, N);
			read(vectorsline, bii); tb_bi <= to_signed(bii, N);
			if ESEC_SING or first_pass then
				read(vectorsline, wri); tb_wr <= to_signed(wri, N);
				read(vectorsline, wii); tb_wi <= to_signed(wii, N);
				first_pass := false;
			end if;

			-- sospendo il processo in modo da terminare il ciclo
			-- delta corrente ed aggiornare i segnali assegnati
			-- il processo riprende quando i dati sono cambiati
			-- ed assegna alla butterfly i nuovi valori
			wait on tb_ar, tb_ai, tb_br, tb_bi, tb_wr, tb_wi;
			tb_start <= '1', '0' after tck;
			tb_ina <= tb_ar after tck, tb_ai after 2*tck;
			tb_inb <= tb_br after tck, tb_bi after 2*tck;

			-- attendo che la butterfly termini l'esecuzione
			if ESEC_SING then
				wait for 10*tck;
			else
				wait for 6*tck;
			end if;
		end loop;
	
		-- in esecuzione continua ho bisogno di attendere ancora
		-- qualche ciclo per recuperare l'ultimo risultato
		if not ESEC_SING then
			wait for 4*tck;
		end if;

		file_close(vectorsfile);
		end_sim <= '1';
		wait;
	end process;

	-- processo di lettura delle uscite e confronto dei risultati
	results_control : process is
		variable act_ar, act_br : signed(N-1 downto 0);
		variable act_ai, act_bi : signed(N-1 downto 0);
		variable exp_ar, exp_br : signed(N-1 downto 0);
		variable exp_ai, exp_bi : signed(N-1 downto 0);
	begin
		-- recupero le uscite della butterfly ideale (totalmente
		-- combinatoria, quindi le uscite sono disponibili quasi
		-- subito)
		wait until falling_edge(tb_start);
		exp_ar := tb_out_ar; exp_br := tb_out_br;
		exp_ai := tb_out_ai; exp_bi := tb_out_bi;

		-- loop in cui svolgo le operazioni di confronto tra 
		-- i risultati ideali e quelli della butterfly 
		while end_sim = '0' loop
			-- aspetto che la butterfly termini un esecuzione
			-- quindi recupero le uscite fornite
			wait until falling_edge(tb_done);
			act_ar := tb_outa; act_br := tb_outb;
			wait for tck+tck/2;
			act_ai := tb_outa; act_bi := tb_outb;

			-- confronto le uscite a coppie: se ci sono discordanze
			-- stampo un errore in output indicando il vettore di test
			-- e i risultati ideali e attuali
			if act_ar /= exp_ar or act_ai /= exp_ai or
			   act_br /= exp_br or act_bi /= exp_bi then
				report LF & HT & "Error on test vector:" & LF &
					HT & "Ar=" & integer'image(to_integer(tb_ar)) &
					" Ai=" & integer'image(to_integer(tb_ai)) &
					" Br=" & integer'image(to_integer(tb_br)) &
					" Bi=" & integer'image(to_integer(tb_bi)) &
					" Wr=" & integer'image(to_integer(tb_wr)) &
					" Wi=" & integer'image(to_integer(tb_wi)) & 
					LF & HT & "Expected:" & LF & HT &
					"A'r=" & integer'image(to_integer(exp_ar)) &
					" A'i=" & integer'image(to_integer(exp_ai)) &
					" B'r=" & integer'image(to_integer(exp_br)) &
					" B'i=" & integer'image(to_integer(exp_bi)) &
					LF & HT & "Actual:" & LF & HT & 
					"A'r=" & integer'image(to_integer(act_ar)) &
					" A'i=" & integer'image(to_integer(act_ai)) &
					" B'r=" & integer'image(to_integer(act_br)) &
					" B'i=" & integer'image(to_integer(act_bi));
				errors <= errors + 1;
			end if;

			-- recupero le uscite ideali del prossimo vettore
			wait for tck;
			exp_ar := tb_out_ar; exp_br := tb_out_br;
			exp_ai := tb_out_ai; exp_bi := tb_out_bi;
		end loop;
		wait;
	end process;


	DUT : butterfly
		generic map(N => N)
		port map(
			clk => tb_clk,
			reset_n => tb_reset_n,
			sf_2h_1l => tb_sf_2h_1l,
			start => tb_start,
			ina => tb_ina,
			inb => tb_inb,
			wr => tb_wr,
			wi => tb_wi,
			outa => tb_outa,
			outb => tb_outb,
			done => tb_done
		);

	IDEAL_MODEL : butterfly_ideal
		generic map(N => N)
		port map(
			sf_2h_1l => tb_sf_2h_1l,
			ar => tb_ar,
			ai => tb_ai,
			br => tb_br,
			bi => tb_bi,
			wr => tb_wr,
			wi => tb_wi,
			out_ar => tb_out_ar,
			out_ai => tb_out_ai,
			out_br => tb_out_br,
			out_bi => tb_out_bi
		);

end architecture test;
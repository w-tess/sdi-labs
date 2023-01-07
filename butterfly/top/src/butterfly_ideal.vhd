library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

-- modello ideale della butterfly, realizzato a 
-- tramite le espressioni matematiche che 
-- implementano la FFT
-- il sistema e' totalmente combinatorio e sono
-- stati implementati gli stessi accorgimenti
-- (sign extension, rounding, scalamento) della
-- butterfly per garantire che i due blocchi
-- realizzati forniscano risultati identici se
-- correttamente progettati
entity butterfly_ideal is

	generic(
		N : integer := 16
	);

	port (
		sf_2h_1l : in std_logic;
		ar, ai, br, bi, wr, wi : in signed(N-1 downto 0);
		out_ar, out_ai : out signed(N-1 downto 0);
		out_br, out_bi : out signed(N-1 downto 0)
	);

end entity butterfly_ideal;

architecture behavioral of butterfly_ideal is

    component round is
		generic (
			N : integer := 33
		);
		port (
			ina : in signed(N-1 downto 0);
			outb: out signed(N-1 downto 0)
		);
	end component round;

    signal m1, m2, m3, m4, m5, m6 : signed(2*N downto 0);
	signal s1, s2, s3, s4, s5, s6  : signed(2*N downto 0);
    signal ar_ext, ai_ext : signed(2*N downto 0);
    signal round_ar, round_ai : signed(2*N downto 0);
    signal round_br, round_bi : signed(2*N downto 0);

begin
	-- estensione dei dati in ingresso
    ar_ext <= resize(ar, 2*N+1);
    ai_ext <= resize(ai, 2*N+1);

	-- definizione degli operatori intermedi
	-- questa parte descrive il modello ideale
    m1 <= resize(br * wr, 2*N+1);
    m2 <= resize(bi * wi, 2*N+1);
    m3 <= resize(br * wi, 2*N+1);
    m4 <= resize(bi * wr, 2*N+1);
    m5 <= shift_left(ar_ext, N);  --2*ar
    m6 <= shift_left(ai_ext, N);  --2*ai
    s1 <= shift_left(ar_ext, N-1) + m1;
    s2 <= s1 - m2;
    s3 <= shift_left(ai_ext, N-1) + m3;
    s4 <= s3 + m4;
    s5 <= m5 - s2;
    s6 <= m6 - s4;

	-- per l'arrotondamento si sfrutta il blocco
	-- di rounding implementato per la butterfly
    round0 : round
		generic map(N => 2*N+1)
		port map(ina => s2, outb => round_ar);
    round1 : round
		generic map(N => 2*N+1)
		port map(ina => s4, outb => round_ai);
    round2 : round
		generic map(N => 2*N+1)
		port map(ina => s5, outb => round_br);
    round3 : round
		generic map(N => 2*N+1)
		port map(ina => s6, outb => round_bi);

	-- scalamento dei dati in uscita
	sf_proc: process(
		round_ar, round_ai, round_br, round_bi, sf_2h_1l
	) begin
		if sf_2h_1l = '0' then
			out_ar <= round_ar(2*N-1 downto N);
			out_ai <= round_ai(2*N-1 downto N);
			out_br <= round_br(2*N-1 downto N);
			out_bi <= round_bi(2*N-1 downto N);
		else
			out_ar <= round_ar(2*N downto N+1);
			out_ai <= round_ai(2*N downto N+1);
			out_br <= round_br(2*N downto N+1);
			out_bi <= round_bi(2*N downto N+1);
		end if;
	end process;

end architecture behavioral;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity butterfly_ideal is

	generic(
		N : integer := 16;
        M : integer := 33
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
    ar_ext <= resize(ar, M);
    ai_ext <= resize(ai, M);

	-- definizione degli operatori intermedi
	-- questa parte descrive il modello ideale
    m1 <= resize(br * wr, M);
    m2 <= resize(bi * wi, M);
    m3 <= resize(br * wi, M);
    m4 <= resize(bi * wr, M);
    m5 <= shift_left(ar_ext, 16);  --2*ar
    m6 <= shift_left(ai_ext, 16);  --2*ai
    s1 <= shift_left(ar_ext, 15) + m1;
    s2 <= s1 - m2;
    s3 <= shift_left(ai_ext, 15) + m3;
    s4 <= s3 + m4;
    s5 <= m5 - s2;
    s6 <= m6 - s4;

	-- per l'arrotondamento si sfrutta il blocco 
	-- di rounding implementato per la butterfly
    round0 : round
		generic map(N => M)
		port map(ina => s2, outb => round_ar);
    round1 : round
		generic map(N => M)
		port map(ina => s4, outb => round_ai);
    round2 : round
		generic map(N => M)
		port map(ina => s5, outb => round_br);
    round3 : round
		generic map(N => M)
		port map(ina => s6, outb => round_bi);

	-- scalamento dei dati in uscita
	sf_proc: process(
		round_ar, round_ai, round_br, round_bi, sf_2h_1l
	) begin
		if sf_2h_1l = '0' then
			out_ar <= round_ar(M-2 downto M-N-1);
			out_ai <= round_ai(M-2 downto M-N-1);
			out_br <= round_br(M-2 downto M-N-1);
			out_bi <= round_bi(M-2 downto M-N-1);
		else
			out_ar <= round_ar(M-1 downto M-N);
			out_ai <= round_ai(M-1 downto M-N);
			out_br <= round_br(M-1 downto M-N);
			out_bi <= round_bi(M-1 downto M-N);
		end if;
	end process;

end architecture behavioral;
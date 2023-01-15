library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package type_def is

	-- costante che definisce il parallelismo di I/O
	-- per i dati nella FFT
	constant IOBITS : integer := 16;

	type fft_t is array(Natural range <>) of signed(IOBITS-1 downto 0);

	type done_vect_t is array(0 to 7) of std_logic;

	-- i tipi user-defined sono basati su un record
	-- che permette di definire dei campi interni,
	-- ciascuno con il proprio tipo: questo migliora
	-- la leggibilita' sia durante la definizione delle
	-- word nelle locazioni della uROM (nonostante 
	-- l'assegnazione di tipo posizionale), sia durante 
	-- il passaggio dei comandi dalla CU alla EU, in 
	-- quanto e' sufficiente specificare il campo del 
	-- record che si vuole assegnare
	type rom_t is
		record
			cc : std_logic;
			next_state : std_logic_vector(3 downto 0);
			rom_sel_in : std_logic;
			rom_sel_int : std_logic_vector(0 to 2);
			rom_sel_out : std_logic;
			rom_le : std_logic_vector(0 to 9);
			rom_sel_mux01 : std_logic;
			rom_sel_mux2 : std_logic;
			rom_sel_mux3 : std_logic_vector(0 to 1);
			rom_sub_add_n : std_logic_vector(0 to 1);
			rom_done : std_logic;
		end record;

	type commands_t is
		record
			sel_in : std_logic;
			sel_int : std_logic_vector(0 to 2);
			sel_out : std_logic;
			le : std_logic_vector(0 to 9);
			sel_mux01 : std_logic;
			sel_mux2 : std_logic;
			sel_mux3 : std_logic_vector(0 to 1);
			sub_add_n : std_logic_vector(0 to 1);
			done : std_logic;
		end record;

end package type_def;

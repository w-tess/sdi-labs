library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity urom is
	
	-- uROM
	-- addr riceve i tre MSB dello stato futuro, che e' composto 
	-- da 4 bit; even_out e odd_out sono le due uscite della rom,
	-- che vanno al mux per la selezione dello stato tramite 
	-- l'LSB dello stato futuro
	port(
		addr : in std_logic_vector(2 downto 0);
		even_out : out rom_t;
		odd_out : out rom_t
	);

end entity urom;

architecture behavioral of urom is

	-- dato che l'indirizzo e' su tre bit, uROM e' costituita da
	-- otto locazioni, ciascuna locazione fornisce due uscite 
	type rom_arr is array(0 to 7) of rom_t;
	
	constant even_rom : rom_arr := (
		-- RDY_IM
		0 => ('1', "0000", '0', "000", '1', "0000000011", '0', '0', "00", "00", '0'),
		-- LD_IM
		1 => ('0', "0011", '0', "000", '0', "0000010100", '0', '0', "00", "00", '0'),
		-- SUM_S3
		2 => ('0', "0101", '1', "111", '1', "0010000000", '0', '0', "00", "00", '0'),
		-- SUM_S4_S5
		3 => ('1', "1000", '0', "000", '0', "1000000000", '1', '1', "00", "01", '0'),
		-- SUM_S6
		4 => ('0', "1010", '1', "100", '0', "0110000000", '1', '0', "01", "01", '0'),
		-- RND_BI
		5 => ('0', "1100", '0', "000", '0', "0001000000", '0', '0', "01", "00", '1'),
		-- RDY_RE
		6 => ('0', "0000", '0', "000", '0', "0010000000", '0', '0', "10", "00", '0'),
		-- UNUSED
		7 => ('0', "0000", '0', "000", '0', "0000000000", '0', '0', "00", "00", '0')
	);

	constant odd_rom : rom_arr := (
		-- LD_RE
		0 => ('0', "0010", '0', "000", '0', "0000101000", '0', '0', "00", "00", '0'),
		-- SUM_S1
		1 => ('0', "0100", '0', "001", '0', "0010000000", '0', '0', "10", "00", '0'),
		-- SUM_S2
		2 => ('0', "0110", '1', "010", '0', "0010000000", '0', '1', "00", "10", '0'),
		-- UNUSED
		3 => ('0', "0000", '0', "000", '0', "0000000000", '0', '0', "00", "00", '0'),
		-- SUM_S6_LD_RE
		4 => ('0', "1011", '1', "100", '0', "0110101000", '1', '0', "01", "01", '0'),
		-- RND_BI_LD_IM
		5 => ('0', "0011", '0', "000", '0', "0001010100", '0', '0', "01", "00", '1'),
		-- UNUSED
		6 => ('0', "0000", '0', "000", '0', "0000000000", '0', '0', "00", "00", '0'),
		-- UNUSED
		7 => ('0', "0000", '0', "000", '0', "0000000000", '0', '0', "00", "00", '0')
	);
	
begin

	-- tramite addr, leggo la stessa locazione in entrambe le rom,
	-- le word lette vengono fornite alle rispettive uscite
	even_out <= even_rom(to_integer(unsigned(addr)));
	odd_out <= odd_rom(to_integer(unsigned(addr)));

end architecture behavioral;
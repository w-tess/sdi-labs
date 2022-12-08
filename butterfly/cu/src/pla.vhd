library ieee;
use ieee.std_logic_1164.all;

entity pla is

	-- PLA, cc e' formato da 1 bit, chiamato "S"
	-- S=0 -> fornisco LSB in uscita
	-- S=1 -> fornisco START in uscita
	port(
		start_in : in std_logic;
		lsb_in : in std_logic;
		cc_in : in std_logic;
		pla_out : out std_logic
	);
	
end entity pla;

architecture behavioral of pla is

begin
	
	-- la PLA puo' essere implementata come 
	-- un semplice multiplexer con cc selettore
	pla_out <= lsb_in when cc_in = '0' else start_in;

end architecture behavioral;
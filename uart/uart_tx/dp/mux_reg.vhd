library ieee;
use ieee.std_logic_1164.all;

entity mux_reg is

	port(
		s_in, p_in, clk : in std_logic;
		le, se : in std_logic;
		r_out : out std_logic
	);
				 
end entity mux_reg;

architecture behavioral of mux_reg is

	signal mux_out : std_logic;

begin
	
	-- mux_out rappresenta l'uscita del mux,
	-- il selettore e' "le" e sceglie l'ingresso
	-- parallelo (p_in) o seriale (s_in)
	mux_out <= p_in when le = '1' else s_in;

	-- flip-flop che prende in ingresso mux_out,
	-- cioe' l'uscita del mux e la propaga in 
	-- uscita (r_out)
	ff : process(clk) is
	begin
		if(clk'event and clk = '1') then
			if(se = '1') then
				r_out <= mux_out;
			end if;
		end if;
	end process;

end architecture behavioral;
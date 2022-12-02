library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_mux_reg is
end entity tb_mux_reg;

architecture test of tb_mux_reg is

	component mux_reg is

		port(
			s_in, p_in, clk : in std_logic;
			le, se : in std_logic;
			r_out : out std_logic
		);
					 
	end component mux_reg;

	signal tb_s_in, tb_p_in : std_logic;
	signal tb_le, tb_se : std_logic;
	signal tb_r_out : std_logic; 
	signal end_sim : std_logic := '0';
	signal tb_clk : std_logic := '1';
	constant tck : time := 10 ns;

begin

	DUT : mux_reg
		port map(
			s_in => tb_s_in,
			p_in => tb_p_in,
			clk => tb_clk,
			le => tb_le,
			se => tb_se,
			r_out => tb_r_out
		);

	clk_gen : process is
	begin
		tb_clk <= tb_clk nor end_sim;
		wait for tck/2;
	end process;

	-- processo di generazione dei dati, per una simulazione
	-- completa si utilizza stimuli come un contatore che
	-- mano a mano assegna ai 4 segnali di ingresso, tutte le
	-- possibili configurazioni
	data_gen : process is
		variable stimuli : unsigned(0 to 3) := "0000";
	begin
		while end_sim = '0' loop
			tb_s_in <= stimuli(0); tb_p_in <= stimuli(1);
			tb_se <= stimuli(2); tb_le <= stimuli(3);
			wait for tck;
			if stimuli = "1111" then
				end_sim <= '1';
			end if;
			stimuli := stimuli + 1;
		end loop;
	end process;

end architecture test;
library ieee;
use ieee.std_logic_1164.all;

entity tb_piso_n is
end entity tb_piso_n;

architecture test of tb_piso_n is

	component piso_n is

		generic(
			N : integer := 8
		);
	
		port(				  		 
			pi : in std_logic_vector(N-1 downto 0);
			si : in std_logic;
			le, se, clk, rst : in std_logic;
			po : out std_logic_vector(N downto 0);
			so : out std_logic
		);
		
	end component piso_n;

	signal tb_pi : std_logic_vector(7 downto 0);
	signal tb_si : std_logic;
	signal tb_le, tb_se : std_logic;
	signal tb_po : std_logic_vector(8 downto 0);
	signal tb_so : std_logic; 
	signal tb_rst : std_logic;
	signal tb_clk : std_logic := '1';
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin

	DUT : piso_n 
		generic map(N => 8)
		port map(
			clk => tb_clk,
			rst => tb_rst,
			pi => tb_pi,
			si => tb_si,
			le => tb_le,
			se => tb_se,
			po => tb_po,
			so => tb_so
		);

	-- processo di generazione del clock, 
	-- end_sim disattiva il clock terminando 
	-- cosi' la simulazione
	clk_gen : process is
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;
		
		if end_sim = '1' then
			assert false 
			report "simulation completed succesfully." 
			severity note;
			wait;
		end if;
	end process;

	-- processo di generazione dei dati
	data_gen : process is
	begin
		tb_pi <= "10001110"; tb_si <= '0';
		tb_le <= '0'; tb_se <= '0';
		tb_rst <= '1';
		wait for tck;
		tb_se <= '1'; tb_le <= '1';
		tb_rst <= '0';
		wait for 2*tck;
		tb_le <= '0'; 
		wait;
	end process;

	-- processo di termine simulazione, end_sim
	-- viene attivato quando la piso ha fornito 
	-- in uscita tutti i dati caricati in parallelo
	proc_end : process(tb_po) is
		variable tmp : std_logic := '0';
	begin
		for i in tb_po'range loop
			tmp := tmp or tb_po(i);
		end loop;
		tmp := not tmp;
		if tmp = '1' then
			end_sim <= '1';
		end if;
	end process;

end architecture test;
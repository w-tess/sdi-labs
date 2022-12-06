library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is

	-- TSYMB=tempo di simbolo inteso in cicli di clock
	-- N=parallelismo di uscita

	generic (
		TSYMB : integer := 1042;
		N : integer := 8
	);

	port (
		rx, clk, rst : in std_logic;
		done : out std_logic;
		dout : out std_logic_vector(N-1 downto 0)
	);
	                                                                             
end entity uart_rx;

architecture behavioral of uart_rx is

	component sipo_n is

		generic(N : integer := 8);
	
		port(
			si, sipo_rst : in std_logic;
			sipo_se, clk : in std_logic;
			po : buffer std_logic_vector(N-1 downto 0)
		);
		
	end component sipo_n;
	
	component control_unit_rx is
	
		port(
			cu_clk, cu_rst, cu_start_rx, cu_stop : in std_logic;
			cu_end_rx, cu_tc_sipo0, cu_tc_sipo1 : in std_logic;
			cu_sipo_rst, cu_sipo0_se, cu_sipo1_se : out std_logic;
			cu_cnt0_rst, cu_cnt0_le, cu_cnt1_rst: out std_logic;
			cu_cnt1_le, cu_done : out std_logic
		);
									  
	end component control_unit_rx;
	
	component tcnt is

		generic(
			tcount : integer := 7
		);
		
		port(
			le, clk, rst : in std_logic;
			tc : out std_logic
		);
								 
	end component tcnt;
	
	component voter is

		port(
			din : in std_logic_vector(2 downto 0);
			dout : out std_logic
		);
		
	end component voter;
	
	signal sipo0_se, sipo1_se, sipo_rst : std_logic;
	signal cnt0_rst, cnt0_le, cnt1_rst, cnt1_le : std_logic;
	signal start_rx, stop, end_rx : std_logic;
	signal tc_sipo0, tc_sipo1: std_logic;
	signal sipo0_po : std_logic_vector(7 downto 0);
	signal sipo1_po : std_logic_vector(N downto 0);

begin

	sipo_0 : sipo_n
		port map (
			si => rx, 
			sipo_rst => sipo_rst, 
			sipo_se => sipo0_se, 
			clk => clk, 
			po => sipo0_po
		);
	
	sipo_1 : sipo_n
		generic map (N => N + 1)
		port map (
			si => stop, 
			sipo_rst => sipo_rst, 
			sipo_se => sipo1_se, 
			clk => clk, 
			po => sipo1_po
		);
	
	control_unit_0 : control_unit_rx 
		port map (
			cu_clk => clk, 
			cu_rst => rst, 
			cu_start_rx => start_rx, 
			cu_stop => stop, 
			cu_end_rx => end_rx,
			cu_tc_sipo0 => tc_sipo0, 
			cu_tc_sipo1 => tc_sipo1,  
			cu_sipo_rst => sipo_rst,
			cu_sipo0_se => sipo0_se, 
			cu_sipo1_se => sipo1_se, 
			cu_cnt0_rst => cnt0_rst, 
			cu_cnt0_le => cnt0_le, 
			cu_cnt1_rst => cnt1_rst, 
			cu_cnt1_le => cnt1_le,  
			cu_done => done
		);

	cnt_0 : tcnt 
		generic map (tcount => TSYMB/8 - 2) 
		port map (
			le => cnt0_le, 
			clk => clk, 
			rst => cnt0_rst, 
			tc => tc_sipo0
		);
	
	cnt_1 : tcnt 
		generic map (tcount => TSYMB/8*8 - 2) 
		port map (
			le => cnt1_le, 
			clk => clk, 
			rst => cnt1_rst, 
			tc => tc_sipo1
		);
	
	voter_0 : voter 
		port map (
			din => sipo0_po(7 downto 5),
			dout => stop
		);

	-- il comparatore per il rilevamento dello start e'
	-- sintetizzato attraverso un assegnazione condizionale

	cmp_0 : start_rx <= '1' when sipo0_po = x"0F" else '0';
	
	-- il segnale di stato end_rx non e' altro che l'uscita
	-- negata dell'ultimo D_FF di SIPO1

	end_rx <= not sipo1_po(0);

	-- dout e' costituita dalle uscite degli ultimi 8
	-- D_FF di SIPO1

	dout <= sipo1_po(N-1 downto 0);

end architecture behavioral;
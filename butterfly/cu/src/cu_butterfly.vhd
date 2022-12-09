library ieee;
use ieee.std_logic_1164.all;
use work.type_def.all;

entity cu_butterfly is
	port(
		cu_reset : in std_logic;
		cu_clk : in std_logic;
		cu_start : in std_logic;
		cu_commands : out commands_t
	);
end entity cu_butterfly;

architecture behavioral of cu_butterfly is

	component cu_reg_n is
		generic (
			N : integer := 8;
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);
		port (
			d : in std_logic_vector(N-1 downto 0);
			rst, clk, le : in std_logic;
			q : out std_logic_vector(N-1 downto 0)
		);		
	end component cu_reg_n;

	component uir is
		generic (
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);
		
		port (
			d : in rom_t;
			rst, clk, le : in std_logic;
			q : out rom_t;
		);	
	end component uir;

	component pla is
		port(
			start_in : in std_logic;
			lsb_in : in std_logic;
			cc_in : in std_logic;
			pla_out : out std_logic
		);
	end component pla;

	component urom is
		port(
			addr : in std_logic_vector(2 downto 0);
			even_out : out rom_t;
			odd_out : out rom_t;
		);
	end component urom;

	signal urom_even_out, urom_odd_out : rom_t;
	signal urom_mux_out : rom_t;
	signal uir_out : rom_t;
	signal pla_out : std_logic;
	signal uar_out : std_logic_vector(3 downto 0);
	signal ls_mux_out : std_logic;

begin
	
	-- istanziazione dei componenti, le label utilizzate
	-- fanno fede ai nomi sullo schematico della CU
	uAR0 : cu_reg_n
		generic map(
			N => 4,
			RST_V => 0, -- uAR possiede reset attivo basso
			CLK_V => 0  -- uAR campiona su fronte di discesa
		)
		port map(
			d => uir_out.next_state(3 downto 1) & pla_out,
			rst => cu_reset,
			clk => cu_clk,
			le => '1',
			q => uar_out
		);

	uIR0 : uir
		generic map(
			RST_V => 0 -- uIR possiede reset attivo basso
			CLK_V => 1 -- uIR campiona su fronte di salita
		)
		port map(
			d => urom_mux_out
			rst => cu_reset,
			clk => cu_clk,
			le => '1',
			q => uir_out
		);

	PLA0 : pla
		port map(
			start_in => cu_start,
			lsb_in => uir_out.next_state(0),
			cc_in => uir_out.cc,
			pla_out => pla_out
		);

	uROM0 : urom
		port map(
			addr => uar_out(3 downto 1),
			even_out => urom_even_out,
			odd_out => urom_odd_out
		);

	LS_MUX0 : ls_mux_out <= 
		uar_out(0) when uir_out.cc = '0' else pla_out;

	uROM_MUX0 : urom_mux_out <= 
		urom_even_out when ls_mux_out = '0' else urom_odd_out;

	-- assegno infine i restanti campi di uIR ai campi 
	-- corrispondenti in cu_commands
	cu_commands.sel_in <= uir_out.rom_sel_in;
	cu_commands.sel_int <= uir_out.rom_sel_int;
	cu_commands.sel_out <= uir_out.rom_sel_out;
	cu_commands.le <= uir_out.rom_le;
	cu_commands.sel_mux01 <= uir_out.rom_sel_mux01;
	cu_commands.sel_mux2 <= uir_out.rom_sel_mux2;
	cu_commands.sel_mux3 <= uir_out.rom_sel_mux3;
	cu_commands.done <= uir_out.rom_done;
	
end architecture behavioral;
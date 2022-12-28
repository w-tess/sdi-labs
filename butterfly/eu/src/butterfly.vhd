library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity butterfly is

	generic(
		N : integer := 16;
		M : integer := 33
	);

	port (
		clk, reset_n : in std_logic;
		sf_2h_1l, start : in std_logic;
		ina, inb : in signed(N-1 downto 0);
		wr, wi : in signed(N-1 downto 0);
		outa, outb : out signed(N-1 downto 0)
	);

end entity butterfly;

architecture behavioral of butterfly is
	
	component eu_butterfly is
		generic (
			N : integer := 16;
			M : integer := 33
		);
		port (
			ina, inb, wr, wi : in signed(N-1 downto 0);
			clk, sf_2h_1l : in std_logic;
			le : in std_logic_vector(9 downto 0);
			sel_in, sel_out, sel_mux01, sel_mux2 : in std_logic;
			sel_int : in std_logic_vector(2 downto 0);
			sub_add_n, sel_mux3 : in std_logic_vector(1 downto 0);
			outa, outb : out signed(N-1 downto 0)
		);
	end component eu_butterfly;

	component cu_butterfly is
		port(
			cu_reset : in std_logic;
			cu_clk : in std_logic;
			cu_start : in std_logic;
			cu_commands : out commands_t
		);
	end component cu_butterfly;

	signal commands : commands_t;

begin
	
	execution_unit : eu_butterfly 
		generic map(N => N, M => M)
		port map(
			clk => clk,
			sf_2h_1l => sf_2h_1l,
			ina => ina,
			inb => inb,
			wr => wr,
			wi => wi,
			outa => outa,
			outb => outb,
			le => commands.le,
			sel_in => commands.sel_in,
			sel_int => commands.sel_int,
			sel_out => commands.sel_out,
			sel_mux01 => commands.sel_mux01,
			sel_mux2 => commands.sel_mux2,
			sel_mux3 => commands.sel_mux3,
			sub_add_n => commands.sub_add_n
		);

	control_unit : cu_butterfly
		port map(
			cu_clk => clk,
			cu_reset => reset_n,
			cu_start => start,
			cu_commands => commands
		);
	
end architecture behavioral;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_regfile is
	generic(N : integer := 33);
end entity tb_regfile;

architecture test of tb_regfile is
	
	component regfile is
		generic (
			N : integer := 33
		);
		
		port (
			-- ingressi per i comandi
			clk : in std_logic;
			le : in std_logic_vector(9 downto 0);
			sel_int : in std_logic_vector(2 downto 0);
			sel_in, sel_out : in std_logic;
			-- ingressi per i dati
			ina_ext, inb_ext : in signed(N-1 downto 0);
			wr_ext, wi_ext : in signed(N-1 downto 0);
			add0_outc, round0_outb : in signed(N-1 downto 0);
			-- uscite per i dati
			r2_q : out signed(N-1 downto 0);
			rmux0_out, rmux1_out : out signed(N-1 downto 0);
			rmux2_out, rmux3_out : out signed(N-1 downto 0);
			rmux4_out : out signed(N-1 downto 0)
		);
	end component regfile;

	signal tb_clk : std_logic := '1';
	signal tb_le : std_logic_vector(9 downto 0);
	signal tb_sel_int : std_logic_vector(2 downto 0);
	signal tb_sel_in, tb_sel_out : std_logic;
	signal tb_ina_ext, tb_inb_ext : signed(N-1 downto 0);
	signal tb_wr_ext, tb_wi_ext : signed(N-1 downto 0);
	signal tb_add0_outc, tb_round0_outb : signed(N-1 downto 0);
	signal tb_r2_q : signed(N-1 downto 0);
	signal tb_rmux0_out, tb_rmux1_out : signed(N-1 downto 0);
	signal tb_rmux2_out, tb_rmux3_out : signed(N-1 downto 0);
	signal tb_rmux4_out : signed(N-1 downto 0);
	signal end_sim : std_logic := '0';
	constant tck : time := 10 ns;

begin

	DUT : regfile port map(

	);

	clk_gen : process is
		tb_clk <= not tb_clk;
		wait for tck/2;
	end process;

	data_gen_1 : process is
	end process;

	data_gen_2 : process is
		tb_add0_outc <= to_signed(100000000, 33);
		tb_round0_outb <= to_signed(011111111, 33);
		tb_le <= "0000000000";
		tb_sel_in <= '0';
		tb_sel_out <= '0';
		wait for tck/2;
		tb_le(0) <= '1';
		tb_le(2) <= '1';
		tb_sel_in <= '0';
		tb_sel_out <= '1';
		wait for tck;
		tb_le(1) <= '1';
		tb_le(3) <= '1';
		tb_sel_in <= '1';
		tb_sel_out <= '0';
		wait for tck;
		tb_le(1) <= '0';
		tb_le(3) <= '1';
		tb_sel_in <= '0';
		tb_sel_out <= '1';
		wait for tck;
		tb_le(1) <= '1';
		tb_le(3) <= '0';
		tb_sel_in <= '1';
		tb_sel_out <= '1';

	end process;
	
end architecture test;
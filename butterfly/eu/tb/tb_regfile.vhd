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
	signal end_sim0, end_sim1 : std_logic := '0';
	constant tck : time := 10 ns;

begin

	DUT : regfile port map(
		clk => tb_clk,
		le	=> tb_le,
		sel_int => tb_sel_int,
		sel_in => tb_sel_in,
		sel_out => tb_sel_out,
		ina_ext => tb_ina_ext,
		inb_ext => tb_inb_ext,
		wr_ext => tb_wr_ext,
		wi_ext => tb_wi_ext,
		add0_outc => tb_add0_outc,
		round0_outb => tb_round0_outb,
		r2_q => tb_r2_q,
		rmux0_out => tb_rmux0_out,
		rmux1_out => tb_rmux1_out,
		rmux2_out => tb_rmux2_out,
		rmux3_out => tb_rmux3_out,
		rmux4_out => tb_rmux4_out
	);

	clk_gen : process is
	begin
		tb_clk <= not tb_clk;
		wait for tck/2;

		if end_sim0='1' and end_sim1='1' then
			assert false 
			report "simulation completed succesfully." 
			severity note;
			wait;
		end if;
	end process;

	data_gen_1 : process is
	begin
		tb_le(9 downto 4) <= (others => '0');
		tb_sel_int <= "000";
		tb_ina_ext <= to_signed(100, N);
		tb_inb_ext <= to_signed(200, N);
		tb_wr_ext <= to_signed(300, N);
		tb_wi_ext <= to_signed(400, N);
		tb_le(4) <= '1'; tb_le(6) <= '1';
		tb_le(8) <= '1'; tb_le(9) <= '1';
		wait for tck;
		tb_le(9 downto 4) <= (others => '0');
		tb_ina_ext <= to_signed(500, N);
		tb_inb_ext <= to_signed(600, N);
		wait for tck;
		tb_le(5) <= '1'; tb_le(7) <= '1';
		wait for tck;
		tb_sel_int <= "111";
		end_sim0 <= '1';
		wait;
	end process;

	data_gen_2 : process is
	begin
		tb_le(3 downto 0) <= "0000";
		tb_add0_outc <= to_signed(100000000, 33);
		tb_round0_outb <= to_signed(011111111, 33);
		tb_sel_in <= '0';
		tb_sel_out <= '0';
		wait for tck;
		tb_le(3 downto 0) <= "1111";
		wait for tck;
		tb_le(3 downto 0) <= "0100";
		tb_sel_in <= '1';
		tb_sel_out <= '1';
		wait for tck;
		tb_le(2) <= '0';
		end_sim1 <= '1';
		wait;
	end process;
	
end architecture test;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shelving_filter is
	port (
		din : in signed(11 downto 0);
		a1, a2 : in signed(11 downto 0);
		b0, b1, b2 : in signed(11 downto 0);
		clk, le1, le2, le3, rst : in std_logic;
		dout : out signed(11 downto 0)
	);
end entity shelving_filter;

architecture behavioral of shelving_filter is

	component s_adder_n is
		generic (
			N : integer := 12
		);
		port (
			ina, inb: in signed(N-1 downto 0);
			outc: out signed(N-1 downto 0)
		);
	end component s_adder_n;

	component s_multiplier_n is
		generic (
			N : integer := 12
		);
		port (
			ina, inb : in signed(N-1 downto 0);
			outc : out signed(N-1 downto 0)
		);
	end component s_multiplier_n;

	component s_reg_n is  
		generic (
			N : integer := 12;
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);
		port (
			d_in : in signed(N-1 downto 0);
			rst, clk, en : in std_logic;   
			d_out : out signed(N-1 downto 0)
		);		
	end component s_reg_n; 

	type mpy_t is array(0 to 4) of signed(11 downto 0);
	-- uscite dei moltiplicatori
	signal mpy : mpy_t;
	-- segnali rappresentanti i coefficienti del filtro
	signal coeff : mpy_t;
	
	signal add0, add1, add2 : signed(11 downto 0);
	signal add3, tmp_add2 : signed(11 downto 0);
	signal rin, r0, r1 : signed(11 downto 0);

begin
	
	-- istanziazione dei componenti
	add0_inst : s_adder_n 
		port map(ina => rin, inb => add2, outc => add0);
	add1_inst : s_adder_n 
		port map(ina => mpy(0), inb => add3, outc => add1);
	add2_inst : s_adder_n 
		port map(ina => mpy(1), inb => mpy(3), outc => tmp_add2);
	add3_inst : s_adder_n 
		port map(ina => mpy(2), inb => mpy(4), outc => add3);

	mpy0_inst : s_multiplier_n 
		port map(ina => coeff(0), inb => add0, outc => mpy(0));
	mpy1_inst : s_multiplier_n
		port map(ina => coeff(1), inb => r0, outc => mpy(1));
	mpy2_inst : s_multiplier_n
		port map(ina => coeff(2), inb => r0, outc => mpy(2));
	mpy3_inst : s_multiplier_n
		port map(ina => coeff(3), inb => r1, outc => mpy(3));
	mpy4_inst : s_multiplier_n
		port map(ina => coeff(4), inb => r1, outc => mpy(4));
	
	rin_inst : s_reg_n
		port map(d_in => din, rst => rst, 
				 clk => clk, en => le1, d_out => rin);
	rout_inst : s_reg_n
		port map(d_in => add1, rst => rst, 
				 clk => clk, en => le2, d_out => dout);
	r0_inst : s_reg_n
		port map(d_in => add0, rst => rst, 
				 clk => clk, en => le2, d_out => r0);
	r1_inst : s_reg_n
		port map(d_in => r0, rst => rst, 
				 clk => clk, en => le2, d_out => r1);
	rb0_inst : s_reg_n
		port map(d_in => b0, rst => rst, 
				 clk => clk, en => le3, d_out => coeff(0));
	ra1_inst : s_reg_n	
		port map(d_in => a1, rst => rst, 
				 clk => clk, en => le3, d_out => coeff(1));
	rb1_inst : s_reg_n
		port map(d_in => b1, rst => rst, 
				 clk => clk, en => le3, d_out => coeff(2));
	ra2_inst : s_reg_n
		port map(d_in => a2, rst => rst, 
				 clk => clk, en => le3, d_out => coeff(3));
	rb2_inst : s_reg_n
		port map(d_in => b2, rst => rst, 
				 clk => clk, en => le3, d_out => coeff(4));

	-- dato che i coefficienti a1 e a2 nel feedback sono invertiti 
	-- (abbiamo bisogno di "-a1" e "-a2"), l'uscita di ADD2 e' a sua
	-- volta invertita; per rendere il filtro funzionante bisogna 
	-- invertire nuovamente l'uscita di ADD2
	add2 <= -tmp_add2; 

end architecture behavioral;
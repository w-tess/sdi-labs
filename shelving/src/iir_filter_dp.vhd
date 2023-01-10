library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_filter_dp is
	generic (
		NB : integer := 9; -- NB=filter bit-width
		SHAMT : integer := 11 -- SHAMT=number of bits discarded after multiplication
	);

	port (
		din : in signed(NB-1 downto 0);
		a1, a2 : in signed(NB-1 downto 0);
		b0, b1, b2 : in signed(NB-1 downto 0);
		clk, le1, le2, le3 : in std_logic;
		rstn, done : in std_logic;
		vout : out std_logic;
		dout : out signed(NB-1 downto 0)
	);
end entity iir_filter_dp;

architecture behavioral of iir_filter_dp is
	
	component dff is

		generic(
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);	
	
		port(
			d_in, clk : in std_logic;
			rst, en : in std_logic;
			d_out : out std_logic
		);
	
	end component dff;

	component s_reg_n is  

		generic (
			N : integer := 8;
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);
		
		port (
			d_in : in signed(N-1 downto 0);
			rst, clk, en : in std_logic;   
			d_out : out signed(N-1 downto 0)
		);
				
	end component s_reg_n; 

	component s_adder_n is

		generic (
			N : integer := 8
		);
	
		port (
			ina, inb: in signed(N-1 downto 0);
			outc: out signed(N-1 downto 0)
		);
	
	end component s_adder_n;

	component s_multiplier_n is

		generic (
			N : integer := 8
		);
	
		port (
			ina, inb : in signed(N-1 downto 0);
			outc : out signed(2*N-1 downto 0)
		);
	
	end component s_multiplier_n;

	type tmp_mpy_t is array(0 to 4) of signed(2*NB-1 downto 0);
	type mpy_t is array(0 to 4) of signed(NB-1 downto 0);

	-- output signal for all the internal
	-- multipliers, before shift operation
	-- es. tmp_mpy(1) corresponds to "mpy1" output
	-- es. tmp_mpy(2) corresponds to "mpy2" output
	signal tmp_mpy : tmp_mpy_t;
	
	-- output signal for all the internal 
	-- multipliers, after shift operation
	-- es. mpy(3) corresponds to "mpy3" output
	signal mpy : mpy_t;
	
	-- internal signals for all the coefficients
	signal coeff : mpy_t;
	
	-- output signals for all the internal components
	-- es. rin corresponds to register "rin" output
	-- es. add0 corresponds to adder "add0" output
	signal rin, add0 : signed(NB-1 downto 0);
	signal add1, add2 : signed(NB-1 downto 0);
	signal add3 : signed(NB-1 downto 0);
	signal tmp_add2 : signed(NB-1 downto 0);
	signal r0, r1 : signed(NB-1 downto 0);

begin
	
	-- component instances, name for every component is
	-- matched with the one inside the datapath scheme

	add0_inst : s_adder_n 
		generic map(N => NB)
		port map(ina => rin, inb => add2, outc => add0);
	add1_inst : s_adder_n 
		generic map(N => NB)
		port map(ina => mpy(0), inb => add3, outc => add1);
	add2_inst : s_adder_n 
		generic map(N => NB)
		port map(ina => mpy(1), inb => mpy(3), outc => tmp_add2);
	add3_inst : s_adder_n 
		generic map(N => NB)
		port map(ina => mpy(2), inb => mpy(4), outc => add3);

	mpy0_inst : s_multiplier_n 
		generic map(N => NB)
		port map(ina => coeff(0), inb => add0, outc => tmp_mpy(0)); 
	mpy1_inst : s_multiplier_n
		generic map(N => NB)
		port map(ina => coeff(1), inb => r0, outc => tmp_mpy(1)); 
	mpy2_inst : s_multiplier_n
		generic map(N => NB)
		port map(ina => coeff(2), inb => r0, outc => tmp_mpy(2)); 
	mpy3_inst : s_multiplier_n
		generic map(N => NB)
		port map(ina => coeff(3), inb => r1, outc => tmp_mpy(3)); 
	mpy4_inst : s_multiplier_n
		generic map(N => NB)
		port map(ina => coeff(4), inb => r1, outc => tmp_mpy(4)); 
	
	rin_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => din, rst => rstn, 
				 clk => clk, en => le1, d_out => rin);
	rout_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => add1, rst => rstn, 
				 clk => clk, en => le2, d_out => dout);
	r0_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => add0, rst => rstn, 
				 clk => clk, en => le2, d_out => r0);
	r1_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => r0, rst => rstn, 
				 clk => clk, en => le2, d_out => r1);
	rb0_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => b0, rst => '1', 
				 clk => clk, en => le3, d_out => coeff(0));
	ra1_inst : s_reg_n	
		generic map(N => NB, RST_V => '0')
		port map(d_in => a1, rst => '1', 
				 clk => clk, en => le3, d_out => coeff(1));
	rb1_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => b1, rst => '1', 
				 clk => clk, en => le3, d_out => coeff(2));
	ra2_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => a2, rst => '1', 
				 clk => clk, en => le3, d_out => coeff(3));
	rb2_inst : s_reg_n
		generic map(N => NB, RST_V => '0')
		port map(d_in => b2, rst => '1', 
				 clk => clk, en => le3, d_out => coeff(4));

	-- D-type flip flop used to provide valid-out "vout" on output
	dff_inst : dff
		generic map(RST_V => '0')
		port map(d_in => done, clk => clk,
				 rst => rstn, en => le1, d_out => vout);

	-- shift operation on the output of every
	-- multiplier is performed by this process
	shift_op : process (tmp_mpy) is
		variable tmp_shift : signed(2*NB-1 downto 0);
	begin
		for i in tmp_mpy'range loop
			tmp_shift := tmp_mpy(i);
			tmp_shift := shift_right(tmp_shift, SHAMT);
			tmp_shift := shift_left(tmp_shift, SHAMT-NB+1);
			mpy(i) <= tmp_shift(NB-1 downto 0);
		end loop;
	end process;

	-- since a1 and a2 coefficients are inverted (we need "-a1" and "-a2")
	-- the sum result is inverted as well (tmp_add2), hence we invert 
	-- again "tmp_add2" to compute the required value (add2)
	add2 <= -tmp_add2;

end architecture behavioral;
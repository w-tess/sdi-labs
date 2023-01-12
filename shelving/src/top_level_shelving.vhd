library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;


entity top_level_shelving is

	generic(
		N : integer := 8,
        M : integer := 12
	);

	port (
        clk : in std_logic;
        x_n, a1, a2, b0, b1, b2 : in signed(N-1 downto 0);
        H0/2 : in signed(1 downto 0);  --signed?
        SW : in std_logic_vector(1 downto 0); --std_logic?
        LE1, LE2, LE3, RSTn, DONE : in std_logic;
        VIN, RST_n : in std_logic;
        y_n : out signed(N-1 downto 0);
        VOUT : out std_logic;
	);

end entity top_level_shelving;

architecture behavioral of top_level_shelving is
	
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

    component Az is
        generic (
            
        );
    
        port (
            
        );
    end component Az;

	component s_multiplier_n is
		generic (
            N : integer := 8
        );
    
        port (
            ina, inb : in signed(N-1 downto 0);
            outc : out signed(2*N-1 downto 0)
        );
	end component s_multiplier_n;

    component s_adder_n is
		generic (
            N : integer := 8
        );
    
        port (
            ina, inb: in signed(N-1 downto 0);
            outc: out signed(N-1 downto 0)
        );
	end component s_adder_n;

    component saturation_block is
		generic (
           
        );
    
        port (


        );
	end component saturation_block;

    component d_ff is
		generic (
           
        );
    
        port (
            

        );
	end component d_ff;

    component cu is
		port (
            clk : in std_logic;
            RST_n : in std_logic;
            VIN : in std_logic;
            LE1 : out std_logic;
            LE2 : out std_logic;
            LE3 : out std_logic;
            RSTn : out std_logic;
            DONE : out std_logic
        );
	end component cu;

	signal RIN_out, RH0_out, SAT_out, MUX0_out : signed(N-1 downto 0);
    signal RIN_out_ext, RH0_out_ext, Az_out, Az_out_n, mux_sum_sub_out, sum_sub_out, mult_out, add_out : signed(M-1 downto 0);
    signal mult_out_ext : signed(2*M-1 downto 0);
    signal mult_out_scaled : signed(2*N-1 downto 0);
    signal RSW_out : std_logic_vector(1 downto 0);
   
begin
	
	CU : cu
		port map(
			clk => clk;
            RST_n => RST_n;
            VIN => VIN;
            LE1 => LE1;
            LE2 => LE2;
            LE3 => LE3;
            RSTn => RSTn;
            DONE => DONE
		);
	;

	RIN : s_reg_n 
		generic map(N => N)
            port map(
                d_in => x_n;   
                rst => RSTn;
                clk => clk;
                en => LE1;   
                d_out => RIN_out
            );
    ;

    RIN_out_ext <= resize(RIN_out, M);        
	
    RSW : s_reg_n 
		generic map(N => 2)
            port map(
                d_in => SW;   
                rst => RSTn;
                clk => clk;
                en => LE3;   
                d_out => RSW_out
            );
    ;

    RH0 : s_reg_n 
		generic map(N => 2)
            port map(
                d_in => H0/2;   
                rst => RSTn;
                clk => clk;
                en => LE3;   
                d_out => RH0_out
            );
    ;

    RH0_out_ext <= resize(RH0_out, M);
    
    ROUT : s_reg_n 
		generic map(N => N)
            port map(
                d_in => MUX0_out;   
                rst => RSTn;
                clk => clk;
                en => LE2;   
                d_out => y_n
            );
    ;

	A_z : Az
		port map(
			
		);

	;

    --sum_sub component

    Az_out_n <= -Az_out;

    MUX_sum_sub : mux_sum_sub_out <= Az_out when RSW_out(1) = '0' else Az_out_n;

    SUM_sum_sub : s_adder_n
        generic map(N => 12)
            port map(
                ina => mux_sum_sub_out;   
                inb => RIN_out_ext;  
                outc => sum_sub_out
            );
    ;

    ------------------

    Multiplier : s_multiplier_n
        generic map(N => 12)
            port map(
                ina => sum_sub_out;   
                inb => RH0_out_ext;  
                outc => mult_out_ext
            );
    ;

	mult_out_scaled <= shift_right(mult_out_ext, N);
    mult_out <= mult_out_scaled(11 downto 0);    
    
    ADDER : s_adder_n
        generic map(N => 12)
            port map(
                ina => mult_out;   
                inb => RIN_out_ext;  
                outc => add_out
            );
    ;

    SAT : saturation_block
        generic map(N => 12)
            port map(

            );
    ;

    MUX0 : MUX0_out <= SAT_out when RSW_out(0) = '0' else RIN_out;

end architecture behavioral;
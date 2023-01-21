library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_proc is

	port (
        clk : in std_logic;
        a1_L, a2_L, b0_L, b1_L, b2_L : in signed(11 downto 0);
        a1_H, a2_H, b0_H, b1_H, b2_H : in signed(11 downto 0);
        x_n : in signed(7 downto 0);
        sw : in std_logic_vector(1 downto 0);
        vin, rst_n : in std_logic;
        y_n : out signed(7 downto 0);
        vout : out std_logic
	);

end entity audio_proc;

architecture behavioral of audio_proc is

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

    component shelv_d_ff is
        generic(
            RST_V : std_logic := '1';
            CLK_V : std_logic := '1'
        );	
        port(
            d_in, clk : in std_logic;
            rst, en : in std_logic;
            d_out : out std_logic
        );
    end component shelv_d_ff;

    component round is
        generic(
            N : integer := 12
        );
        port (
            ina : in signed(N-1 downto 0);
            outb : out signed(N-1 downto 0)
        );
    end component round;

    component sat is
        generic (
            N : integer := 12;
            MAX : integer := 2**10-1
        );
        port (
            ina : in signed(N-1 downto 0);
            outa : out signed(N-1 downto 0)
        );
    end component sat;

    component shelving_filter is
        port (
            din : in signed(11 downto 0);
            a1, a2 : in signed(11 downto 0);
            b0, b1, b2 : in signed(11 downto 0);
            clk, le1, le2, le3, rst : in std_logic;
            dout : out signed(11 downto 0)
        );
    end component shelving_filter;

    component cu_audio_proc is
		port (
			clk : in std_logic;
			rst_n : in std_logic;
			vin : in std_logic;
			le1 : out std_logic;
			le2 : out std_logic;
			le3 : out std_logic;
			rst : out std_logic;
			done : out std_logic
		);
	end component cu_audio_proc;

    signal round0_out, sat0_out, mux0_out : signed(11 downto 0);
    signal low_shelv_out, high_shelv_out : signed(11 downto 0);
    signal x_n_ext, x_n_scaled, reg0_out : signed(11 downto 0);
    signal le1, le2, le3, rst, done : std_logic;
   
begin
    
    -- estendo il dato su 12 bit
    x_n_ext <= resize(x_n, 12);
    -- scalo verso sinistra il dato nel caso di loop-back,
    -- in questo modo lo scalamento verso destra in uscita
    -- mi fornisce lo stesso dato ricevuto 
    x_n_scaled <= shift_left(x_n_ext, 3);

    reg0 : s_reg_n
        port map(
            d_in => x_n_scaled,
            rst => rst,
            clk => clk,
            en => le1,
            d_out => reg0_out
        );

    low_shelv : shelving_filter
        port map(
            din => x_n_ext,
            a1 => a1_L,
            a2 => a2_L,
            b0 => b0_L,
            b1 => b1_L,
            b2 => b2_L,
            clk => clk,
            le1 => le1,
            le2 => le2,
            le3 => le3,
            rst => rst,
            dout => low_shelv_out
        );

    high_shelv : shelving_filter
        port map(
            din => x_n_ext,
            a1  => a1_H,
            a2  => a2_H,
            b0  => b0_H,
            b1  => b1_H,
            b2  => b2_H,
            clk => clk,
            le1 => le1,
            le2 => le2,
            le3 => le3,
            rst => rst,
            dout => high_shelv_out
        );

    -- mux per la selezione della modalita'
    -- se sw(0)=0: loop-back
    -- altrimenti,
    -- se sw(1)=0: low-shelving
    -- se sw(1)=1: high-shelving
    mux0 : mux0_out <= reg0_out       when sw = "00" else
                       reg0_out       when sw = "01" else
                       low_shelv_out  when sw = "10" else
                       high_shelv_out when sw = "11" else
                       reg0_out;

    round0 : round
        port map(
            ina => mux0_out,
            outb => round0_out
        );

    sat0 : sat
        port map(
            ina => round0_out,
            outa => sat0_out
        );
    
    -- scalo di tre bit verso destra all'uscita,
    -- la precisione si riduce ma in questo modo
    -- posso verificare il comportamento filtrante
    -- con guadagno maggiore di '1', dato che i 3 
    -- MSB sono relativi alla parte intera
    y_n <= sat0_out(10 downto 3);

    dff0 : shelv_d_ff
    port map(
        d_in => done,
        clk => clk,
        rst => rst,
        en => '1',
        d_out => vout
    );

    cu_inst : cu_audio_proc
    port map(
        clk => clk,
        rst_n => rst_n,
        vin => vin,
        le1 => le1,
        le2 => le2,
        le3 => le3,
        rst => rst,
        done => done
    );

end architecture behavioral;
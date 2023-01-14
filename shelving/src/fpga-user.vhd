library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity user is
	port
	(
		-- Main clock inputs
		mainClk	: in std_logic;
		slowClk	: in std_logic;
		-- Main reset input
		reset		: in std_logic;
		-- MCU interface (UART, I2C)
		mcuUartTx	: in std_logic;
		mcuUartRx	: out std_logic;
		mcuI2cScl	: in std_logic;
		mcuI2cSda	: inout std_logic;
		-- Logic state analyzer/stimulator
		lsasBus	: inout std_logic_vector( 31 downto 0 );
		-- Dip switches
		switches	: in std_logic_vector( 7 downto 0 );
		-- LEDs
		leds		: out std_logic_vector( 3 downto 0 )
	);
end user;

architecture behavioural of user is

	signal clk: std_logic;
	signal pllLock: std_logic;

	signal lsasBusIn: std_logic_vector( 31 downto 0 );
	signal lsasBusOut: std_logic_vector( 31 downto 0 );
	signal lsasBusEn: std_logic_vector( 31 downto 0 ) := ( others => '0' );

	signal mcuI2cDIn: std_logic;
	signal mcuI2CDOut: std_logic;
	signal mcuI2cEn: std_logic := '0';	

	component myAltPll
		PORT
		(
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC ;
			locked		: OUT STD_LOGIC 
		);
	end component;
	
	-- UART TX component declaration
	
	component uart_tx is

		generic(
			TSYMB : integer := 1042;
			N : integer := 8
		);

		port(		 
			din : in std_logic_vector(7 downto 0);
			wr, rst, clk : in std_logic;
			tx : out std_logic
		);
	
	end component uart_tx;
	
	-- UART RX component declaration
	
	component uart_rx is

		generic (
			TSYMB : integer := 1042;
			N : integer := 8
		);

		port (
			rx, clk, rst : in std_logic;
			done : out std_logic;
			dout : out std_logic_vector(N-1 downto 0)
		);
	                                                                             
	end component uart_rx;

	-- AUDIO_PROC component declaration

	component audio_proc is

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
	
	end component audio_proc;
	
	-- internal signals to transfer data between UART/AUDIO_PROC 
	signal data_tx, data_rx : std_logic_vector(7 downto 0);
	signal s_data_tx, s_data_rx : signed(7 downto 0);
	signal valid_rx, done_tx : std_logic;
	-- constant signals representing the coefficients for the
	-- two shelving filters
	constant a1_L : signed(11 downto 0) := to_signed(-267, 12);
	constant a2_L : signed(11 downto 0) := to_signed(122, 12);
	constant b0_L : signed(11 downto 0) := to_signed(311, 12);
	constant b1_L : signed(11 downto 0) := to_signed(-212, 12);
	constant b2_L : signed(11 downto 0) := to_signed(122, 12);
	constant a1_H : signed(11 downto 0) := to_signed(-267, 12);
	constant a2_H : signed(11 downto 0) := to_signed(122, 12);
	constant b0_H : signed(11 downto 0) := to_signed(445, 12);
	constant b1_H : signed(11 downto 0) := to_signed(-590, 12);
	constant b2_H : signed(11 downto 0) := to_signed(256, 12);
	
begin

--**********************************************************
--* Main clock PLL
--**********************************************************

	myAltPll_inst : myAltPll PORT MAP (
		areset	 => reset,
		inclk0	 => mainClk,
		c0	 => clk,
		locked	 => pllLock
	);

--**********************************************************
--* LEDs
--**********************************************************

	leds <= switches( 3 downto 0 );
	
--**********************************************************
--* 		lsasBus	: inout std_logic_vector( 31 downto 0 )
--**********************************************************

	lsasBusIn <= lsasBus;
	
	lsasBusEn(22) <= '1';

	lsasBus_tristate:
	process( lsasBusEn, lsasBusOut ) is
	begin
		for index in 0 to 31 loop
			if lsasBusEn( index ) = '1'  then
				lsasBus( index ) <= lsasBusOut ( index );
			else
				lsasBus( index ) <= 'Z';
			end if;
		end loop;
	end process;
	
--**********************************************************
--* UART TX instantiation
--**********************************************************
	
	uart_tx_inst : uart_tx 
		port map(
			din => data_tx,
			wr => done_tx,
			rst => reset,
			clk => mainClk,
			tx => lsasBusOut(22)
		);
	data_tx <= std_logic_vector(s_data_tx);
		
--**********************************************************
--* UART RX instantiation
--**********************************************************

	uart_rx_inst : uart_rx 
		port map(
			rx => lsasBusIn(21),
			clk => mainClk,
			rst => reset,
			done => valid_rx,
			dout => data_rx
		);
	s_data_rx <= signed(data_rx);

--**********************************************************
--* AUDIO_PROC instantiation
--**********************************************************

	audio_proc_inst : audio_proc
		port map(
			clk   => mainClk,
			a1_L  => a1_L,
			a2_L  => a2_L,
			b0_L  => b0_L,
			b1_L  => b1_L,
			b2_L  => b2_L,
			a1_H  => a1_H,
			a2_H  => a2_H,
			b0_H  => b0_H,
			b1_H  => b1_H,
			b2_H  => b2_H,
			x_n   => s_data_rx,
			sw    => switches(1 downto 0),
			vin   => valid_rx,
			rst_n => reset,
			y_n   => s_data_tx,
			vout  => done_tx
		);
	
end behavioural;

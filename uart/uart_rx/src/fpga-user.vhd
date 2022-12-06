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
	
	-- UART internal signals to transfer data from RX to TX
	
	signal data : std_logic_vector(7 downto 0);
	signal done : std_logic;
	
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
			din => data,
			wr => done,
			rst => reset,
			clk => mainClk,
			tx => lsasBusOut(22)
		);
		
--**********************************************************
--* UART RX instantiation
--**********************************************************

	uart_rx_inst : uart_rx 
		port map(
			rx => lsasBusIn(21),
			clk => mainClk,
			rst => reset,
			done => done,
			dout => data
		);
	
end behavioural;

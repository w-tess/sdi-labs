library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is

	generic(
		TSYMB : integer := 1042;
		N : integer := 8
	);

	port(		 
		din : in std_logic_vector(N-1 downto 0);
		wr, rst, clk : in std_logic;
		tx : out std_logic
	);
	
end entity uart_tx;

architecture behavioral of uart_tx is

	component reg_n is  
	
		generic (
			N : integer := 8;
			EDGE : std_logic := '1'
		);
		
		port (
			d : in std_logic_vector(N-1 downto 0);   
			clk, le : in std_logic;   
			q : out std_logic_vector(N-1 downto 0)
		);
				
	end component reg_n; 

	component tcnt is

		generic(tcount : integer := 7);
		
		port(
			le, clk, rst : in std_logic;
			tc : out std_logic
		);
								 
	end component tcnt;
	
	component control_unit_tx is 
	
		port(
			clk, cu_rst : in std_logic;
			cu_wr, cu_tc, cu_stop : in std_logic;
			cu_reg_le, cu_piso_le, cu_piso_se : out std_logic;
			cu_piso_rst, cu_cnt_rst, cu_cnt_le : out std_logic
		);
	
	end component control_unit_tx;
	
	component piso_n is

		generic(N : integer := 8);
	
		port(				  		 
			pi : in std_logic_vector(N-1 downto 0);
			si : in std_logic;
			le, se, clk, rst : in std_logic;
			po : out std_logic_vector(N downto 0);
			so : out std_logic
		);
		
	end component piso_n;
	
	signal tc, stop : std_logic;
	signal reg_le, piso_le, piso_se : std_logic;
	signal piso_rst, cnt_le, cnt_rst : std_logic;
	signal piso_pi : std_logic_vector(N-1 downto 0);
	signal nor_in : std_logic_vector(N downto 0);
	
begin

	reg_0 : reg_n
		generic map(N => N)
		port map(
			d => din, 
			clk => clk, 
			le => reg_le, 
			q => piso_pi
		);
	
	CU_0 : control_unit_tx 
		port map(
			clk => clk, 
			cu_rst => rst, 
			cu_wr => wr, 
			cu_tc => tc, 
			cu_stop => stop, 
			cu_reg_le => reg_le,
			cu_piso_le => piso_le, 
			cu_piso_se => piso_se, 
			cu_piso_rst => piso_rst,
			cu_cnt_rst => cnt_rst, 
			cu_cnt_le => cnt_le
		);
	
	piso_0 : piso_n 
		generic map(N => N)
		port map(
			pi => piso_pi,
			si => '0',
			le => piso_le, 
			se => piso_se, 
			clk => clk, 
			rst => piso_rst,
			so => tx, 
			po => nor_in
		);
	
	tcnt_0 : tcnt
		generic map(tcount => TSYMB-2)
		port map(
			le => cnt_le, 
			clk => clk, 
			rst => cnt_rst, 
			tc => tc
		);

	-- processo combinatorio che fa la NOR di tutti i bit di nor_in, 
	-- cioe' dei 9 bit presenti all'interno della piso: se sono tutti
	-- '0', allora lo stop bit e' stato trasmesso e 'stop' e' pari ad '1'
	stop_detect : process(nor_in) is
		variable tmp : std_logic;
	begin
		tmp := '0';
		for i in 0 to N loop
			tmp := tmp or nor_in(i);
		end loop;
		stop <= not tmp;
	end process;

end architecture behavioral;
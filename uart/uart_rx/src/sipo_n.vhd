library ieee;
use ieee.std_logic_1164.all;

entity sipo_n is

	generic(N : integer := 8);

	port(
		si, sipo_rst : in std_logic;
		sipo_se, clk : in std_logic;
		po : buffer std_logic_vector(N-1 downto 0)
	);
	
end entity sipo_n;

architecture behavioral of sipo_n is

	component d_ff is

		generic(
			RST_V : std_logic := '1';
			CLK_V : std_logic := '1'
		);	
	
		port(
			d_in, clk : in std_logic;
			rst, en : in std_logic;
			d_out : out std_logic
		);
	
	end component d_ff;
	
begin

	-- istanzio i nove D_FF che compongono la SIPO attraverso 
	-- il costrutto generate, il primo FF a differenza degli 
	-- altri ha un port map differente e quindi e' necessario 
	-- un generate di tipo condizionale

	sipo0 : for i in N-1 downto 0 generate

		dff0_gen : if i = N-1 generate
			dff0 : d_ff 
				port map(
					d_in => si, 
					clk => clk, 
					rst => sipo_rst, 
					en => sipo_se, 
					d_out => po(N-1)
				);
		end generate dff0_gen;

		dffi_gen : if i < N-1 generate 
			dffi : d_ff
				port map (
					d_in => po(i+1), 
					clk => clk, 
					rst => sipo_rst, 
					en => sipo_se, 
					d_out => po(i)
				);
		end generate dffi_gen;
			
	end generate sipo0;

end architecture behavioral;
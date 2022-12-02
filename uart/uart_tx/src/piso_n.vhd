library ieee;
use ieee.std_logic_1164.all;

entity piso_n is

	generic(N : integer := 8);

	port(				  		 
		pi : in std_logic_vector(N-1 downto 0);
		si : in std_logic;
		le, se, clk, rst : in std_logic;
		po : out std_logic_vector(N downto 0);
		so : out std_logic
	);
	
end entity piso_n;

architecture behavioral of piso_n is

	component mux_reg is

		port(
			s_in, p_in, clk : in std_logic;
			le, se : in std_logic;
			r_out : out std_logic
		);
					 
	end component mux_reg;
	
	-- segnali interni, sh_int collega l'uscita di un 
	-- registro all'ingresso del successivo
	signal sh_int : std_logic_vector(N downto 0);
	signal mux_int : std_logic;

begin

	-- ultimo mux_reg (prende in ingresso lo stop bit)
	mux_reg_last : mux_reg 
		port map(
			s_in => si, 
			p_in => '1', 
			clk => clk, 
			le => le, 
			se => se, 
			r_out => sh_int(N)
		);

	-- generazione degli 8 mux_reg intermedi, i quali
	-- caricheranno in parallelo la word da trasmettere
	piso_gen : for i in N-1 downto 0 generate
		mux_reg_gen : mux_reg 
			port map(
				s_in => sh_int(i+1), 
				p_in => pi(i), 
				clk => clk, 
				le => le, 
				se => se, 
				r_out => sh_int(i)
			);
	end generate;
	
	-- primo mux_reg (prende in ingresso lo start bit)
	mux_int <= '0' when le = '1' else sh_int(0);
	ff : process(clk) is
	begin
		if(clk'event and clk = '1') then
			if(rst = '1') then
				so <= '1';
			elsif(se = '1') then
				so <= mux_int;
			end if;
		end if;
	end process;

	-- po rappresenta l'uscita della piso_n che va
	-- in ingresso alla porta NOR, per rilevare
	-- il termine della trasmissione
	po <= sh_int;

end architecture behavioral;
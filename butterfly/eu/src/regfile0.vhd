library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile0 is  
	
	-- N = I/O bit-width
	-- EDGE = clock value during sample
	generic (
		N : integer := 33;
		EDGE : std_logic := '1'
	);
	
	port (
		ina_ext, inb_ext, wr_ext, wi_ext : in signed(N-1 downto 0);   
		clk : in std_logic; 
		le : in std_logic_vector(9 downto 0);
		sel_in, sel_out : in std_logic;
		sel_int : in std_logic_vector(2 downto 0); 
		outa_ext, outb_ext : out signed(N-1 downto 0);
		add0_outc, round0_outb : in signed(N-1 downto 0);
		r2 : buffer signed(N-1 downto 0);;
		ar_ai, br_bi, wr_wi : out signed(N-1 downto 0);
	);
			
end entity regfile0;

architecture behavioral of regfile0 is

	component reg_n is  
	
		generic (
			N : integer := 33;
			EDGE : std_logic := '1'
		);
		
		port (
			d : in signed(N-1 downto 0);   
			clk, le : in std_logic;   
			q : out signed(N-1 downto 0)
		);
				
	end component reg_n;


	signal ri_d : signed(9 downto 0);
	signal ri_q : signed(9 downto 0);


begin

	reg_chain : for i in 9 downto 0 generate
		reg_i : reg_n 
			port map(
				d => ri_d(i), 
				clk => clk, 
				le => le(i),  
				q => ri_q(i)
			);
	end generate;

	rmux0 : ar_ai <= ri_q(4) when sel_int(0) = '0' else ri_q(5);

    rmux1 : br_bi <= ri_q(6) when sel_int(1) = '0' else ri_q(7);

    rmux2 : wr_wi <= ri_q(8) when sel_int(2) = '0' else ri_q(9);

    rmux3 : outb_ext <= ri_q(1) when sel_out = '0' else ri_q(3);

    rmux4 : outa_ext <= ri_q(0) when sel_out = '0' else ri_q(2);

    rmux5 : ri_d(2) <= round0_outb when sel_in = '0' else add0_outc;


      ri_d(0) <= round0_outb;
	  ri_d(1) <= round0_outb;
      ri_d(3) <= round0_outb;
      ri_d(4) <= ina_ext;
      ri_d(5) <= ina_ext;
      ri_d(6) <= inb_ext;
      ri_d(7) <= inb_ext;
      ri_d(8) <= wr_ext;
      ri_d(9) <= wi_ext;
	  r2 <= ri_q(2);
      

end architecture behavioral;
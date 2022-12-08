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
		ina, inb, wr, wi : in std_logic_vector(N-1 downto 0);   
		clk : in std_logic; 
		le : in std_logic_vector(9 downto 0);
		sel_in, sel_out : in std_logic;
		sel_int : in std_logic_vector(2 downto 0); 
		outa, outb : out std_logic_vector(N-1 downto 0);
		add0_outc, round0_outb : in std_logic_vector(N-1 downto 0);
		r2 : buffer std_logic_vector(N-1 downto 0);;
		ar_ai, br_bi, wr_wi : out std_logic_vector(N-1 downto 0);
	);
			
end entity regfile0;

architecture behavioral of regfile0 is

	component reg_n is  
	
		generic (
			N : integer := 33;
			EDGE : std_logic := '1'
		);
		
		port (
			d : in std_logic_vector(N-1 downto 0);   
			clk, le : in std_logic;   
			q : out std_logic_vector(N-1 downto 0)
		);
				
	end component reg_n;


	signal ri_d : std_logic_vector(9 downto 0);
	signal ri_q : std_logic_vector(9 downto 0);


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

	rmux0 : process(sel_int(0))
	begin
  		case sel_int(0) is
    			when "0" =>
      		   ar_ai <= ri_q(4) ;
    			when others =>
     		  	   ar_ai <= ri_q(5);
  		end case ;
	end process rmux0;

	rmux1 : process(sel_int(1))
	begin
  		case sel_int(1) is
    			when "0" =>
      		   br_bi <= ri_q(6) ;
    			when others =>
     		  	   br_bi <= ri_q(7);
  		end case ;
	end process rmux1;

	rmux2 : process(sel_int(2))
	begin
  		case sel_int(2) is
    			when "0" =>
      		   wr_wi <= ri_q(8) ;
    			when others =>
     		  	   wr_wi <= ri_q(9);
  		end case ;
	end process rmux2;

	rmux3 : process(sel_out)
	begin
  		case sel_out is
    			when "0" =>
      		   outb <= ri_q(1);
    			when others =>
     		  	   outb <= ri_q(3);
  		end case ;
	end process rmux3;

	rmux4 : process(sel_out)
	begin
  		case sel_out is
    			when "0" =>
      		   outa <= ri_q(0) ;
    			when others =>
     		  	   outa <= ri_q(2);
  		end case ;
	end process rmux4;

	rmux5 : process(sel_in)
	begin
  		case sel_in is
    			when "0" =>
      		   ri_d(2) <= round0_outb;
    			when others =>
     		  	   ri_d(2) <= add0_outc;
  		end case;
	end process rmux5;

      ri_d(0) <= round0_outb;
	ri_d(1) <= round0_outb;
      ri_d(3) <= round0_outb;
      ri_d(4) <= ina;
      ri_d(5) <= ina;
      ri_d(6) <= inb;
      ri_d(7) <= inb;
      ri_d(8) <= wr;
      ri_d(9) <= wi;
	r2 <= ri_q(2);
      

end architecture behavioral;
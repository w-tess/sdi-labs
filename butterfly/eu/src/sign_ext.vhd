library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sing_ext is  
	
	-- N = I/O bit-width before sign extention
	-- M = I/O bit-width after sign extention
	generic (
		N : integer := 16;
		M : integer := 33;
	);
	
	port (
        ina, inb, wr, wi : in signed(N-1 downto 0);
		ina_ext, inb_ext, wr_ext, wi_ext : out signed(M-1 downto 0);
	);
			
end entity sing_ext;

architecture behavioral of sign_ext is

begin

    ina_ext <= resize(ina, M-1);
    inb_ext <= resize(inb, M-1);
    wr_ext <= resize(wr, M-1);
    wi_ext <= resize(wi, M-1);

end architecture behavioral;
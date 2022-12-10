library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity tb_urom is
end entity tb_urom;

architecture test of tb_urom is
	
	component urom is
		port(
			addr : in std_logic_vector(2 downto 0);
			even_out : out rom_t;
			odd_out : out rom_t
		);
	end component urom;

	signal tb_addr : std_logic_vector(2 downto 0);
	signal tb_even_out : rom_t;
	signal tb_odd_out : rom_t;
	constant tck : time := 10 ns;

begin
	
	DUT : urom 
		port map(
			addr => tb_addr,
			even_out => tb_even_out,
			odd_out => tb_odd_out
		);

	addr_gen : process is
		variable cnt : integer range 0 to 7 := 0;
	begin
		tb_addr <= std_logic_vector(to_unsigned(cnt, 3));
		wait for tck;

		if cnt = 7 then
			assert false 
			report "simulation completed succesfully."
			severity note;
			wait;
		end if;

		cnt := cnt + 1;
	end process;
	
end architecture test;
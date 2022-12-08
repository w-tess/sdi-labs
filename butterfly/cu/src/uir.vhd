library ieee;
use ieee.std_logic_1164.all;
use work.type_def.all;

-- micro_instruction register, il comportamento
-- e' analogo a quello del registro implementato
-- in "reg_n.vhd" tuttavia dato che questo registro
-- lavora con i dati forniti da uROM, che sono di
-- tipo "rom_t", era più comodo realizzare una 
-- soluzione specifica che convertire tutto dal 
-- tipo "rom_t" a std_logic_vector
entity uir is
	
	-- RST_V = reset value to reset
	-- CLK_V = clock value to sample
	generic (
		RST_V : std_logic := '1';
		CLK_V : std_logic := '1'
	);
	
	port (
		d_in : in rom_t;
		rst, clk, en : in std_logic;
		d_out : out rom_t;
	);
			
end entity uir;
 
architecture behavioral of uir is
	constant rst_word : rom_t := (
		cc => '0',
		next_state => "0000",
		rom_sel_in => '0',
		rom_sel_int => "000",
		rom_sel_out => '0',
		rom_le => (others => '0'),
		rom_sel_mux01 => '0'
		rom_sel_mux2 => '0'
		rom_sel_mux3 => "00"
		rom_done => '0'
	); 
begin 

	process (clk) is
	begin  
		if (clk'event and clk = CLK_V) then
			if (rst = RST_V) then
				d_out <= rst_word;
			elsif (en = '1') then
				d_out <= d_in;
			end if;
		end if;
	end process; 
	
end architecture behavioral;
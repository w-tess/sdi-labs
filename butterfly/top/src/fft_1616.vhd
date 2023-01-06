library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity fft_1616 is

	generic(
		N : integer := 16
	);
	
	port(
		start, clk, reset_n : in std_logic;
		samples : in fft_t(0 to 15);
		results : out fft_t(0 to 15);
		done : out done_vect_t
	);

end entity fft_1616;

architecture behavioral of fft_1616 is

	component butterfly is
		generic(
			N : integer := 16
		);
		port (
			clk, reset_n : in std_logic;
			sf_2h_1l, start : in std_logic;
			ina, inb : in signed(N-1 downto 0);
			wr, wi : in signed(N-1 downto 0);
			outa, outb : out signed(N-1 downto 0);
			done : out std_logic
		);
	end component butterfly;

	signal first_level, second_level : fft_t(0 to 15);
	signal third_level, tmp_level : fft_t(0 to 15);
	signal first_done, second_done, third_done : done_vect_t;

	type pos_t is array(Natural range <>) of integer;
	constant twiddle_index : pos_t(0 to 7) := (0,4,2,6,1,5,3,7);
	constant reverse_index : pos_t(0 to 15) := (0,8,4,12,2,10,6,14,
												1,9,5,13,3,11,7,15);

	constant wr : fft_t(0 to 7) := (
		0  => to_signed(32767, N),  1 => to_signed(30273, N),
		2  => to_signed(23170, N),  3 => to_signed(12539, N),
		4  => to_signed(0, N),		 5 => to_signed(-12539, N),
		6  => to_signed(-23170, N), 7 => to_signed(-30273, N)
	);
	constant wi : fft_t(0 to 7) := (
		0  => to_signed(0, N), 	 1 => to_signed(-12539, N),
		2  => to_signed(-23170, N), 3 => to_signed(-30273, N),
		4  => to_signed(-32767, N), 5 => to_signed(-30273, N),
		6  => to_signed(-23170, N), 7 => to_signed(-12539, N)
	);
	constant sf_2h_1l : std_logic_vector(0 to 3) := "1000";

begin

---------------------- PRIMO  LIVELLO ---------------------

	G1_0 : 
	for i in 0 to 7 generate
		first_chain : butterfly
			generic map(N => N)
			port map(
				clk => clk,
				reset_n => reset_n,
				sf_2h_1l => sf_2h_1l(0),
				start => start,
				ina => samples(i),
				inb => samples(i+8),
				wr => wr(0),
				wi => wi(0),
				outa => first_level(i),
				outb => first_level(i+8),
				done => first_done(i)
			);
	end generate;

--------------------- SECONDO LIVELLO ---------------------

	G2_0 : 
	for i in 0 to 1 generate
		G2_1 :
		for j in 0 to 3 generate
			second_chain : butterfly
			generic map(N => N)
			port map(
				clk => clk,
				reset_n => reset_n,
				sf_2h_1l => sf_2h_1l(1),
				start => first_done(4*i+j),
				ina => first_level(8*i+j),
				inb => first_level(8*i+j+4),
				wr => wr(twiddle_index(i)),
				wi => wi(twiddle_index(i)),
				outa => second_level(8*i+j),
				outb => second_level(8*i+j+4),
				done => second_done(4*i+j)
			);
		end generate;
	end generate;

--------------------- TERZO   LIVELLO ---------------------

	G3_0 : 
	for i in 0 to 3 generate
		G3_1 :
		for j in 0 to 1 generate
			third_chain : butterfly
			generic map(N => N)
			port map(
				clk => clk,
				reset_n => reset_n,
				sf_2h_1l => sf_2h_1l(2),
				start => second_done(2*i+j),
				ina => second_level(4*i+j),
				inb => second_level(4*i+j+2),
				wr => wr(twiddle_index(i)),
				wi => wi(twiddle_index(i)),
				outa => third_level(4*i+j),
				outb => third_level(4*i+j+2),
				done => third_done(2*i+j)
			);
		end generate;
	end generate;

--------------------- QUARTO  LIVELLO ---------------------

	G4_0 : 
	for i in 0 to 7 generate
		fourth_chain : butterfly
		generic map(N => N)
		port map(
			clk => clk,
			reset_n => reset_n,
			sf_2h_1l => sf_2h_1l(3),
			start => third_done(i),
			ina => third_level(2*i),
			inb => third_level(2*i+1),
			wr => wr(twiddle_index(i)),
			wi => wi(twiddle_index(i)),
			outa => tmp_level(2*i),
			outb => tmp_level(2*i+1),
			done => done(i)
		);
	end generate;

----------------- BIT-REVERSAL REORDERING -----------------

	fifth_level_proc : process(tmp_level) is
	begin
		for i in tmp_level'range loop
			results(i) <= tmp_level(reverse_index(i));
		end loop;
	end process;
	
end architecture behavioral;
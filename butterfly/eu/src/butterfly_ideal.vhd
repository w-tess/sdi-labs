library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity butterfly_ideal is

	generic(
		N : integer := 33
	)

	port (
		ar, ai, br, bi, wr, wi : in signed(N-1 downto 0);
		outa_r, outa_i, outb_r, outb_i : out signed(N-1 downto 0);
	);

end entity butterfly_ideal;

architecture behavioral of butterfly_ideal is

    signal m1, m2, m3, m4, m5, m6 : signed(N-1 downto 0);
	signal s1, s2, s3, s4, s5, s6  : signed(N-1 downto 0);

begin

    m1 <= br * wr;
    m2 <= bi * wi;
    m3 <= br * wi;
    m4 <= bi * wr;
    m5 <= shift_left(ar, 1);  --2*ar
    m6 <= shift_left(ai, 1);  --2*ai
    s1 <= shift_left(ar, 15) + m1;
    s2 <= s1 - m2;
    s3 <= shift_left(ai, 15) + m3;
    s4 <= s3 + m4;
    s5 <= m5 - s2;
    s6 <= m6 - s4;

    outa_r <= s2;
    outa_i <= s4;
    outb_r <= s5;
    outb_i <= s6;



end architecture behavioral;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_arith.all;

ENTITY print_debug IS
	--GENERIC();
	PORT(
		txt		: IN STRING(1 TO 4);
		ssd0_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		ssd1_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		ssd2_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		ssd3_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE print_debug OF print_debug IS
	TYPE int_array IS ARRAY (INTEGER RANGE<>) OF INTEGER;
	SIGNAL char	: int_array(1 TO 4);
	
	TYPE charMap IS ARRAY (INTEGER RANGE<>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	CONSTANT ssdCode : charMap(0 TO 38) :=
	(
	"11000000",  -- '0'
	"11111001",  -- '1'
	"10100100",  -- '2'
	"10110000",  -- '3'
	"10011001",  -- '4' 
	"10010010",  -- '5'
	"10000010",  -- '6'
	"11111000",  -- '7'
	"10000000",  -- '8'
	"10010000",  -- '9'
	"10001000", -- 'A'
	"10000011", -- 'b'
	"11000110", -- 'C'
	"10100001", -- 'd'
	"10000110", -- 'E'
	"10001110",	-- 'F'
	"10010000", -- 'g'
	"10001011", -- 'h'
	"11111001", -- 'I'
	"11100001", -- 'J'
	"10001001", -- 'K'
	"11000111", -- 'L'
	"10101010", -- 'M'
	"10101011", -- 'n'
	"10100011", -- 'o'
	"10001100", -- 'P'
	"10011000", -- 'q'
	"10101111", -- 'r'
	"10010010", -- 's'
	"10000111", -- 't'
	"11000001", -- 'u'
	"11100011", -- 'v'
	"10010101", -- 'W'
	"10001001", -- 'x'
	"10011001", -- 'y'
	"10100100", -- 'z'
	"01111111", -- '.'
	"10111111", -- '-'
	"11111111" -- ' '
	);
	
BEGIN
	G_1: FOR I IN 1 TO 4 GENERATE
		char(5-I) <= 	CHARACTER'POS(txt(I))-48 WHEN (CHARACTER'POS(txt(I)) < 59) AND (CHARACTER'POS(txt(I)) > 48) ELSE
							CHARACTER'POS(txt(I))-55 WHEN (CHARACTER'POS(txt(I)) < 92) AND (CHARACTER'POS(txt(I)) > 65) ELSE
							CHARACTER'POS(txt(I))-87 WHEN (CHARACTER'POS(txt(I)) < 124) AND (CHARACTER'POS(txt(I)) > 97) ELSE
							37 WHEN CHARACTER'POS(txt(I)) = 45 ELSE
							36 WHEN CHARACTER'POS(txt(I)) = 46 ELSE
							38;
	END GENERATE;
	
	ssd0_d <= STD_LOGIC_VECTOR(ssdCode(char(1)));
	ssd1_d <= STD_LOGIC_VECTOR(ssdCode(char(2)));
	ssd2_d <= STD_LOGIC_VECTOR(ssdCode(char(3)));
	ssd3_d <= STD_LOGIC_VECTOR(ssdCode(char(4)));
	
END ARCHITECTURE;
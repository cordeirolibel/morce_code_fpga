LIBRARY ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;
--use work.pacote.all;

ENTITY TabelaMorseChar IS

	
	generic (
				n : integer := 4
				);
	port 
	(
		clk : in std_logic;
		entrada : in String(1 to n);
		saida	: out character
		 
	);

end entity;

architecture TabelaMorseChar OF TabelaMorseChar IS
--		. = 00		- = 01
begin

	saida <=
		'A'	when	entrada	=	".-  "	ELSE
		'B'	when	entrada	=	"-..."	ELSE
		'C'	when	entrada	=	"-.-."	ELSE
		'D'	when	entrada	=	"-.. "	ELSE
		'E'	when	entrada	=	".   "	ELSE
		'F'	when	entrada	=	"..-."	ELSE
		'G'	when	entrada	=	"--. "	ELSE
		'H'	when	entrada	=	"...."	ELSE
		'I'	when	entrada	=	"..  "	ELSE
		'J'	when	entrada	=	".---"	ELSE
		'K'	when	entrada	=	"-.- "	ELSE
		'L'	when	entrada	=	".-.."	ELSE
		'M'	when	entrada	=	"--  "	ELSE
		'N'	when	entrada	=	"-.  "	ELSE
		'O'	when	entrada	=	"--- "	ELSE
		'P'	when	entrada	=	".--."	ELSE
		'Q'	when	entrada	=	"--.-"	ELSE
		'R'	when	entrada	=	".-. "	ELSE
		'S'	when	entrada	=	"... "	ELSE
		'T'	when	entrada	=	"-   "	ELSE
		'U'	when	entrada	=	"..- "	ELSE
		'V'	when	entrada	=	"...-"	ELSE
		'W'	when	entrada	=	".-- "	ELSE
		'X'	when	entrada	=	"-..-"	ELSE
		'Y'	when	entrada	=	"-.--"	ELSE
		'Z'	when	entrada	=	"--.."	ELSE
		' ';
end architecture;
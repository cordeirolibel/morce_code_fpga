LIBRARY ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

ENTITY ConversorSinal IS

	
	generic (
				n : integer := 2
				);
	port 
	(
		clk : in std_logic;
		entrada : in std_logic_vector(n-1 downto 0);
		saida	: out character
		 
	);

end entity;

architecture ConversorSinal OF ConversorSinal IS
--		. = 00		- = 01
begin

	saida <= '.' when entrada = "00" ELSE
			 '-' when entrada = "01" ELSE
			 ' ';
end ConversorSinal;
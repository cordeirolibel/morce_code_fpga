library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mensagem.all;

entity ConversorMorse is

	generic(	MAX_STR : integer := 20;
				MAX_LETRA : integer := 4;
				MAX_ENT: integer := 39
	);
  	port (
		arrayEntrada : in char_array;
		saida : out String(1 to MAX_STR);
		clk: in std_logic
  	);
end entity;

architecture ConversorMorse of ConversorMorse is
	
	component TabelaMorseChar
		port (
			clk: in std_logic;			
			entrada : in String(1 to MAX_LETRA);
			saida	: out character
			);
	end component;
	
	component ConversorSinal
		port (
			clk: in std_logic;
			entrada : in std_logic_vector(1 downto 0);
			saida : out character
			
		);
	end component;
	
	-- sinais
	signal entradaTabela1: String(1 to MAX_LETRA);
	signal entradaTabela2: String(1 to MAX_LETRA);
	signal entradaTabela3: String(1 to MAX_LETRA);
	signal entradaTabela4: String(1 to MAX_LETRA);
	signal entradaConversor1 : std_logic_vector(1 downto 0);
	signal entradaConversor2 : std_logic_vector(1 downto 0);
	signal entradaConversor3 : std_logic_vector(1 downto 0);
	signal entradaConversor4 : std_logic_vector(1 downto 0);
	signal saidaTabela1 : character;
	signal saidaTabela2 : character;
	signal saidaTabela3 : character;
	signal saidaTabela4 : character;
	signal saidaConversor1 : character;
	signal saidaConversor2 : character;
	signal saidaConversor3 : character;
	signal saidaConversor4 : character;

	
	signal str_saida : string(1 to MAX_STR) := (OTHERS => ' ');
	signal inter: integer := 0; 

begin
	
	tabelaMorse1: TabelaMorseChar port map(clk, entradaTabela1, saidaTabela1);
	tabelaMorse2: TabelaMorseChar port map(clk, entradaTabela2, saidaTabela2);
	tabelaMorse3: TabelaMorseChar port map(clk, entradaTabela3, saidaTabela3);
	tabelaMorse4: TabelaMorseChar port map(clk, entradaTabela4, saidaTabela4);
	conversor1 : ConversorSinal port map(clk, entradaConversor1, saidaConversor1);
	conversor2 : ConversorSinal port map(clk, entradaConversor2, saidaConversor2);
	conversor3 : ConversorSinal port map(clk, entradaConversor3, saidaConversor3);
	conversor4 : ConversorSinal port map(clk, entradaConversor4, saidaConversor4);
	
	process(clk)
		-- iterador de leitura do vetor entrada
		
		variable inter_str: integer := 1;
		variable flag_fim: std_logic := '0';
		variable t_count: integer := 0;
		begin
			if(rising_edge(clk)) then
				--------------------------
				--fim da string
				if (inter_str > MAX_STR) then
					inter_str := 0; 
					inter <= 0;
					flag_fim := '0';

				--------------------------
				--fim da mensagem, so coloca espacos na string
				elsif 	((inter+5) >= MAX_ENT) 		 OR  	-- Maximo do buffer
						(arrayEntrada(inter) = "10") OR 	-- Recebeu 2 espacos
						flag_fim = '1' 				 then 	-- Recebeu 2 espacos em outro momento

					str_saida(inter_str) <= ' ';
					flag_fim := '1';

				--------------------------
				-- espaco
				elsif (arrayEntrada(inter) = "11") then
					str_saida(inter_str) <= ' ';
					inter <= inter+1;  --proximo caractere

				--------------------------
				-- tamanho 1
				elsif(arrayEntrada(1+inter) = "10") then

					--ajusta caractere de tamanho 1
					str_saida(inter_str) <= saidaTabela1;
					inter <= inter + 2; --proximo caractere

				--------------------------
				-- tamanho 2
				elsif(arrayEntrada(2+inter) = "10") then

					--ajusta caractere de tamanho 2
					str_saida(inter_str) <= saidaTabela2;
					inter <= inter + 3; --proximo caractere

				--------------------------
				-- tamanho 3
				elsif(arrayEntrada(3+inter) = "10") then

					--ajusta caractere de tamanho 3
					str_saida(inter_str) <= saidaTabela3;
					inter <= inter + 4; --proximo caractere

				--------------------------
				-- tamanho 4
				elsif(arrayEntrada(4+inter) = "10") then

					--ajusta caractere de tamanho 4
					str_saida(inter_str) <= saidaTabela4;
					inter <= inter + 5; --proximo caractere

				--------------------------
				-- erro
				else
					--se esse caractere '_' esta aparecendo entao 
					--arrayEntrada nao esta certo
					str_saida(inter_str) <= '_';
				end if;

				inter_str := inter_str+1;
			end if;
		end process;	

		entradaConversor1 <= arrayEntrada(0+inter);
		entradaConversor2 <= arrayEntrada(1+inter);
		entradaConversor3 <= arrayEntrada(2+inter);
		entradaConversor4 <= arrayEntrada(3+inter);

		entradaTabela4(1) <= saidaConversor1;
		entradaTabela4(2) <= saidaConversor2;
		entradaTabela4(3) <= saidaConversor3;
		entradaTabela4(4) <= saidaConversor4;

		entradaTabela3(1) <= saidaConversor1;
		entradaTabela3(2) <= saidaConversor2;
		entradaTabela3(3) <= saidaConversor3;
		entradaTabela3(4) <= ' ';

		entradaTabela2(1) <= saidaConversor1;
		entradaTabela2(2) <= saidaConversor2;
		entradaTabela2(3) <= ' ';
		entradaTabela2(4) <= ' ';

		entradaTabela1(1) <= saidaConversor1;
		entradaTabela1(2) <= ' ';
		entradaTabela1(3) <= ' ';
		entradaTabela1(4) <= ' ';
		
		saida <= str_saida;
	
end architecture;
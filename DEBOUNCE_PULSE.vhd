-----------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE std.textio.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;
-----------------------------------------------
ENTITY DEBOUNCE_PULSE IS
	GENERIC (TEMPO_DEBOUNCE: INTEGER:=50; --tempo de debounce em ms
				FREQ_HZ: INTEGER:=50000000); --frequencia do processador
	PORT (
			clk: IN std_logic;				 --sinal de clock
			button: IN std_logic;			 --botao no qual se deseja aplicar o debounce
			output_debounce: OUT std_logic);--saida tratada apos debounce da entrada
END ENTITY;
------------------------------------------------
ARCHITECTURE tratamento OF DEBOUNCE_PULSE IS																		    
SIGNAL cont_up: integer:=0;						--variavel de contagem do tempo de transicao 0-1
SIGNAL cont_down: integer:=0;						--variavel de contagem do tempo de transicao 1-0
SIGNAL aux: std_logic_vector (2 DOWNTO 0):="000";	--variavel auxiliar que registra as transicoes
BEGIN	
	PROCESS(clk)
	BEGIN
	aux(0) <= NOT (button);
	output_debounce <= aux(2);
	IF rising_edge(clk) THEN
		IF	(aux(0) = '1' AND aux(1) = '0') THEN						
			aux(1) <= aux (0);
			aux(2) <= '1';
			cont_down <= 0;
		ELSIF (aux(1) = '1') THEN
			aux(2) <= '0';
			cont_down <= cont_down + 1;
		END IF;
		IF (cont_down = (FREQ_HZ/1000)*TEMPO_DEBOUNCE) THEN
			IF(aux(0) = '0') THEN
				aux(1) <= '0';
			END IF;
			cont_down <= 0;
		END IF;		
	END IF;
	END PROCESS;
END tratamento;
------------------------------------------------
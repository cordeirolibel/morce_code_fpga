-----------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-----------------------------------------------
ENTITY DEBOUNCE IS
	GENERIC (TEMPO_DEBOUNCE: INTEGER:=50; 	--tempo de debounce em ms
				FREQ_HZ: INTEGER:=50000000); 	--frequencia de clock
	PORT (
			clk: IN std_logic;				 		--sinal de clock
			button: IN std_logic;			 		--botao no qual se deseja aplicar o debounce
			output_debounce: OUT std_logic);		--led de saida
END ENTITY;
------------------------------------------------
ARCHITECTURE debounce OF DEBOUNCE IS																		    
SIGNAL cont_up: integer:=0;						--variavel de contagem do tempo de transicao 0-1
SIGNAL cont_down: integer:=0;						--variavel de contagem do tempo de transicao 1-0
SIGNAL aux: std_logic_vector (1 DOWNTO 0);	--variavel auxiliar que registra as transicoes
BEGIN
	PROCESS(clk)
	BEGIN
	IF rising_edge(clk) THEN						--a cada ciclo de clock, a entrada eh aquisitada e
		aux(0) <= button; 							--em caso de transicao, conta-se o tempo em que a entrada permanece
		output_debounce <= aux(1);					--em um estado diferente do de saida
		IF (aux(0) = '1' AND aux(1) = '0') THEN
			cont_up <= cont_up + 1;					--contagem de tempo para transicao 0-1
		END IF;
		IF (aux(0) = '0' AND aux(1) = '0') THEN
			cont_up <= 0;								--caso o botao seja pressionado por um tempo menor que o de debounce, a contagem eh resetada
		END IF;
		IF (cont_up=(FREQ_HZ/1000)*TEMPO_DEBOUNCE) THEN
			aux(1) <= aux(0);							--caso o tempo de transicao 0-1 seja atingido, a saida passa para "1" e a contagem eh resetada
			cont_up <= 0;
		END IF;
		IF (aux(1) = '1' AND aux(0) = '0') THEN
			cont_down <= cont_down + 1;			--caso a transicao ja tenha ocorrido, e o botao tenha sido liberado, inicia-se a contagem para
		END IF;											--a transicao 1-0
		IF (aux(1) = '1' AND aux(0) = '1') THEN
			cont_down <= 0;							--se o botao voltar a ser pressionado durante a contagem "1->0", esta eh reiniciada
		END IF;
		IF (cont_down=(FREQ_HZ/1000)*TEMPO_DEBOUNCE) THEN
			aux(1) <= '0';								--caso o tempo de transicao 1-0 seja atingido, a saida passa para "0" e a contagem eh resetada
			cont_down <= 0;
		END IF;
	END IF;
	END PROCESS;
END debounce;
------------------------------------------------
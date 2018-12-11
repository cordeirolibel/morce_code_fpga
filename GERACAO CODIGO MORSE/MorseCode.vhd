LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

USE work.meupacote.all;
USE work.mensagem.all;
------------------------------------------------------

ENTITY MorseCode IS
	GENERIC(
		FCLK		: NATURAL := 50_000_000;
		tam_vet	: NATURAL := 39);
	PORT(
		clk		: IN 	STD_LOGIC;
		rst		: IN 	STD_LOGIC;
		TX_STATE, COM_STATE, LOOP_STATE	: IN STD_LOGIC;				--switches
		RX, R		: IN 	STD_LOGIC;								--fio IN
		msg		: IN char_array;
		msg_out	: OUT char_array;
		TX, S		: OUT STD_LOGIC;								--fio OUT
		ssd0		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ssd1		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ssd2		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ssd3		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
END ENTITY;

------------------------------------------------------

ARCHITECTURE MorseCode OF MorseCode IS	

	

	---------- MAQUINA DE ESTADOS -------------------
	TYPE state IS (idle, communication, transmit_hs, transmiting, comm_request, recieving,  tx_dot, tx_dash, btw_char, btw_symb, btw_word);
	SIGNAL pr_state, nx_state: state;
	--------------------------------------------------
	
	
	----------- TEMPOS DE ATIVACAO -----------------
	--CONSTANT TDOT	: NATURAL	:= FCLK * 3;	-- TEMPO DE PONTO (3s)
	CONSTANT TDOT	: NATURAL	:= FCLK;				-- TEMPO DE PONTO (1s)
	--CONSTANT TDOT	: NATURAL	:= FCLK / 100;	-- TEMPO DE PONTO (10ms)
	CONSTANT TDASH	: NATURAL	:= TDOT * 3;	-- TEMPO DE TRACO
	CONSTANT TSYM	: NATURAL	:= TDOT;			-- TEMPO ENTRE PONTO E TRACO
	CONSTANT TCHAR	: NATURAL	:= TDOT * 3;	-- TEMPO ENTRE LETRA
	CONSTANT TWORD	: NATURAL	:= TDOT * 7;	-- TEMPO ENTRE PALAVRAS
	CONSTANT TMAX	: NATURAL	:= TDOT * 10;	-- TEMPO MAX
	CONSTANT TBUFF	: NATURAL 	:= TDOT / 5;	-- TEMPO DE CONFIABILIDADE DE RECEBIMENTO DE SIMBOLO 
	
	SIGNAL t: NATURAL RANGE 0 TO TMAX;
	--------------------------------------------------
	
	
	---------- VETOR COM MENSAGEM -------------------
	--TYPE symbols IS (dot, dash, char_break, word_break);
	--TYPE symbols_array IS ARRAY (INTEGER RANGE <>) OF symbols;
	--SIGNAL msg: symbols_array (0 TO tam_vet-1);
	-------------------------------------------------
	
	
	---------- PRINTADOR DE LINHAS ------------------
	SIGNAL texto: STRING(1 TO 4);
	COMPONENT print_debug IS
	PORT(	txt		: IN	STRING(1 TO 4);
			ssd0_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			ssd1_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			ssd2_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			ssd3_d	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
	-------------------------------------------------

	SIGNAL I: INTEGER RANGE 0 TO tam_vet;
	
BEGIN
	
	RecivedMsg: entity work.MORSE_GEN port map (clk=>clk, rst=>rst, button=>RX, msg_out=>msg_out );
	texto_comp : print_debug PORT MAP (txt => texto, ssd0_d => ssd0, ssd1_d => ssd1, ssd2_d => ssd2, ssd3_d => ssd3);

	-- TIMER ------------------------
	PROCESS(clk, rst)
	BEGIN
		IF rst = '0' THEN
			t <= 0;
		ELSIF rising_edge(clk) THEN
			IF pr_state /= nx_state THEN 
				t <= 0;
			ELSIF t /= TMAX THEN
				t <= t + 1;
			END IF;
		END IF;
	END PROCESS;

	-- FSM LOWER --------------------
	PROCESS(clk, rst)
	BEGIN
		IF rst = '0' THEN
			pr_state <= idle;	
		ELSIF rising_edge(clk) THEN
			pr_state <= nx_state;
		END IF;
	END PROCESS;
	
	-- CONTADOR MSG -----------
PROCESS(clk, rst)
BEGIN
	IF rst = '0' THEN
		I <= 0;	
	ELSIF rising_edge(clk) THEN
		IF pr_state = IDLE THEN 
			I <= 0;
		ELSIF pr_state = TRANSMITING THEN
			I <= I + 1;
		ELSE
			I <= I;
		END IF;
	END IF;
END PROCESS;

	-- FSM UPPER --------------------
	PROCESS(all)
		VARIABLE flag: STD_LOGIC;
	BEGIN
		CASE pr_state IS
			WHEN idle =>
				S 	<= '1';			--SINAL DE SEND PARA IDLE
				TX <= '0';			--SINAL DO CANAL DE TRANSMISSAO ZERADO
				texto <= "idle";
				
				IF COM_STATE = '1' THEN
					nx_state <= communication;
				ELSE
					nx_state <= idle;
				END IF;
				
			WHEN communication =>
				S 	<= '1';			
				TX <= '0';						
				texto <= "comm";
				
				IF COM_STATE = '0' THEN
					nx_state <= idle;
				ELSIF TX_STATE = '1' THEN
					nx_state <= transmit_hs;
				ELSIF LOOP_STATE = '1' THEN
					nx_state <= transmit_hs;
				ELSIF R = '0' THEN
					nx_state <= comm_request;
				ELSE
					nx_state <= communication;
				END IF;
				
			WHEN comm_request =>
				S 	<= '0';			
				TX <= '0';		
				
				IF COM_STATE = '0' THEN
					nx_state <= idle;
				ELSIF RX = '1' THEN
					nx_state <= recieving;
				ELSE
					nx_state <= comm_request;
				END IF;
			
			WHEN recieving =>
				S 	<= '0';			
				TX <= '0';		
				
				IF COM_STATE = '0' THEN
					nx_state <= idle;
				ELSIF R = '1' THEN
					nx_state <= idle;
				ELSE
					nx_state <= recieving;
				END IF;
			
			WHEN transmit_hs =>
				S  <= '0';			--SINAL DE SEND PARA TRANSMITIR
				TX <= '0';			
				texto <= "txhs";
				
				IF R = '0' THEN
					nx_state <= transmiting;
				ELSIF COM_STATE = '0' THEN
					nx_state <= idle;
				ELSIF TX_STATE = '0' THEN
					nx_state <= communication;
				ELSE
					nx_state <= transmit_hs;
				END IF;
			
			WHEN transmiting =>
				S  <= '0';	
				texto <= "txtx";
				
				IF COM_STATE = '0' THEN
					nx_state <= idle;
				ELSIF (LOOP_STATE = '0' AND I > tam_vet) THEN
						nx_state <= idle;
				ELSIF I >= msg'length			THEN
					nx_state <= IDLE;
				ELSIF msg(I) = "00" 			THEN	--dot
					nx_state <= tx_dot;
				ELSIF msg(I) = "01" 			THEN 	--dash
					nx_state <= tx_dash;
				ELSIF msg(I) = "10" 	THEN	--btw char
					nx_state <= btw_char;
				ELSIF msg(I) = "11" 	THEN	--btw word
					nx_state <= btw_word;
				ELSE
					nx_state <= transmiting;
				END IF;
			
			WHEN tx_dot =>
				S  <= '0';
				TX	<= '1';
				texto <= "....";
				
				IF t >= TDOT-1 THEN	
					nx_state <= btw_symb;
				ELSE
					nx_state <= tx_dot;
				END IF;
				
			WHEN tx_dash =>
				S  <= '0';
				TX	<= '1';
				texto <= "----";
				
				IF t >= TDASH-1 THEN	
					nx_state <= btw_symb;
				ELSE
					nx_state <= tx_dash;
				END IF;
				
			WHEN btw_char =>
				S  <= '0';
				TX	<= '0';
				texto <= "bt c";
				
				IF t >= (TCHAR-TSYM-1) THEN
					nx_state <= transmiting;
				ELSE
					nx_state <= btw_char;
				END IF;
			
			WHEN btw_word =>
				S  <= '0';
				TX	<= '0';
				texto <= "bt w";

				IF t >= (TWORD-TSYM-1) THEN
					nx_state <= transmiting;
				ELSE
					nx_state <= btw_word;
				END IF;
				
			WHEN btw_symb =>
				S  <= '0';
				TX	<= '0';
				texto <= "bt s";
				
				IF t >= TSYM-1 THEN
					nx_state <= transmiting;
				ELSE
					nx_state <= btw_symb;
				END IF;
				
				
		END CASE;
	END PROCESS;
END ARCHITECTURE;
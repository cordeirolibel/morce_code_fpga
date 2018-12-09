LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;

USE work.mensagem.all;
----------------------------
ENTITY APS IS
GENERIC (MAX: INTEGER:=39);													--tamanho do buffer de caracteres							

PORT (clk, rst, button: 	IN STD_LOGIC;			   					--sinais de clock, reset e o botao de transmissao
		states: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);						--leds para indicacao de estado
		sw_tx, sw_comm, sw_loop_state : IN STD_LOGIC;											-- switches para modo de transmissao e mode de comunicacao
		rx, r: IN STD_LOGIC;														-- pinos para receber mensagem e pino para handshake
		tx, s: OUT STD_LOGIC;
		--LED		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		ssd0		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ssd1		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ssd2		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ssd3		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		buzzer: OUT STD_LOGIC);													--buzzer de sinalizacao de ponto-traco
END APS;
----------------------------
ARCHITECTURE MORSE_GENERATOR OF APS IS
	
	--TYPE char_array IS ARRAY (MAX-1 DOWNTO 0) OF std_logic_vector (1 DOWNTO 0); --vetor para bufferizacao dos pontos e tracos
	SIGNAL char: char_array;	
	
	TYPE state IS (												--estados da maquina conforme diagrama de estados
	idleInput,												
	processChar,												
	processSpace,												
	buttonPress,												
	processDash,
	processDot,
	msgFull,
	communication);														
	
	SIGNAL pr_state,nx_state: state; 
	SIGNAL button_db: std_logic;									--sinal para debounce do botao de insercao de caractere
	SIGNAL pointer: integer:=0;									--ponteiro para preenchimento do vetor de caracteres
	SIGNAL rst_db: std_logic;									   --botão de reset

	CONSTANT   tChar: NATURAL := 150000000;					--constante de tempo para caractere, 3s
	CONSTANT  tSpace: NATURAL := 250000000;					--constante de tempo para espaco entre palavas, 5s
	CONSTANT    tDot: NATURAL := 50000000;						--constante de tempo para ponto, 1s
	CONSTANT   tDash: NATURAL := 150000000;					--constante de tempo para traco, 3s
	CONSTANT tBuzzer: NATURAL := 250000000;					--constante de tempo para animacao do buzzer, 5s
	CONSTANT    tmax: NATURAL := 500000000;					--constante de tempo máximo, 10s
	SIGNAL t: NATURAL RANGE 0 TO tmax;
	
BEGIN
---circuito de debounce dos botoes e reset ------------------
db_button: entity work.DEBOUNCE port map(clk=>clk, button=>button, output_debounce=>button_db);
db_rst: entity work.DEBOUNCE_PULSE port map(clk=>clk, button=>rst, output_debounce=>rst_db);
RxTx: entity work.MorseCode port map (clk=>clk, rst=>rst, TX_STATE=>sw_tx, COM_STATE=>sw_comm, loop_state=>sw_loop_state, RX=>rx, R=>r, msg=>char, TX=>tx, S=>s, 
																			 ssd0=>ssd0, ssd1=>ssd1, ssd2=>ssd2, ssd3=>ssd3);

-----------------TIMER-----------------------------------------
	PROCESS (rst_db, clk)	
	BEGIN
		IF (rst_db = '1') THEN
			t <= 0;
		ELSIF (rising_edge(clk)) THEN
			IF pr_state /= nx_state THEN
				t <= 0;
			ELSIF t/= tmax THEN
				t <= t+1;
			END IF;
		END IF;
	END PROCESS;
-----------------INCREMENTO DO PONTEIRO---------------------
	PROCESS (rst_db, clk, pr_state)	
	BEGIN
		IF (rst_db = '1') THEN
			pointer <= 0;
		ELSIF (rising_edge(clk)) THEN
			IF (pr_state = processChar OR pr_state = processDash OR pr_state = processDot OR pr_state = processSpace) THEN
				pointer <= pointer + 1;
			END IF;
		END IF;
	END PROCESS;
----------------------- Lower section -----------------------
	PROCESS (rst_db, clk)
	BEGIN
		IF (rst_db='1') THEN
			pr_state <= idleInput;
			FOR i IN 0 TO MAX LOOP
				char(i) <= NULL;
			END LOOP;
		ELSIF (rising_edge(clk)) THEN
			pr_state <= nx_state;
		END IF;
	END PROCESS;
---------------------- Upper section ------------------------
	PROCESS (pr_state)
	BEGIN
		CASE pr_state IS
		
		 WHEN idleInput =>									
			buzzer <= '0';
			states <= "0001";
			IF (button_db = '1' AND t < tChar AND pointer < MAX - 1) THEN
				nx_state <= buttonPress;
			ELSIF (button_db = '1' AND tChar < t AND tSpace > t AND pointer < MAX - 1) THEN
				nx_state <= processChar;
			ELSIF (button_db = '1' AND tSpace < t AND pointer < MAX - 1) THEN
				nx_state <= processSpace;
			ELSIF (button_db = '1' AND pointer >= MAX - 1) THEN
				nx_state <= msgFull;
			ELSIF (sw_comm = '1') THEN
				nx_state <= communication;
			ELSE nx_state <= idleInput;
			END IF;

		 WHEN buttonPress =>						
			buzzer <= button_db;
			states <= "0010";
			buzzer <= '1';
			IF (button_db = '0' AND t>tDot) THEN
				nx_state <= processDash;
			ELSIF (button_db = '0' AND t<tDot) THEN
				nx_state <= processDot;
			ELSE nx_state <= buttonPress;
			END IF;
			
		 WHEN processDash =>
			buzzer <= '0';
			states <= "0011";
			nx_state <= idleInput;
			char(pointer) <= "01";
			
	    WHEN processDot =>
			buzzer <= '0';
			states <= "0100";
			nx_state <= idleInput;
			char(pointer) <= "00";
			
		 WHEN processChar =>
			states <= "0101";
			buzzer <= '0';
			nx_state <= buttonPress;
			char(pointer) <= "10";

		 WHEN processSpace =>
			states <= "0110";
			buzzer <= '0';
			nx_state <= buttonPress;
			char(pointer) <= "11";
		
		 WHEN msgFull =>
			states <= "0111";
			buzzer <= '1';
			IF (t > tBuzzer) THEN
			nx_state <= idleInput;
			ELSE nx_state <= msgFull;
			END IF;
			
		WHEN communication =>
			states <= "1000";
			IF (sw_comm /= '1') THEN
				nx_state <= idleInput;
			ELSE nx_state <= communication;
			END IF;
			
		END CASE;
	END PROCESS;

END MORSE_GENERATOR;
-----------------------------------------
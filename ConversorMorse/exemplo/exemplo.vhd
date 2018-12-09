

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.pacote.all;

ENTITY exemplo IS
	GENERIC( 
			MAX_MSG : INTEGER := 20;--tamanho maximo de mensagem
			MAX_ENT : INTEGER := 40
		);
	PORT (
			--vga
			CLK, RST  		: IN STD_LOGIC; 
			HSYNC, VSYNC    : OUT STD_LOGIC; 
			R, G, B         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
END ENTITY;

ARCHITECTURE exemplo OF exemplo IS
----------------------------------------------------------
---------- LIGACOES
----------------------------------------------------------

	CONSTANT MSG_REC    : STRING(1 TO MAX_MSG) 	:= "VHDL EH LEGAL       "; -- recebida
	--CONSTANT MSG_ENV    : STRING(1 TO MAX_MSG) 	:= "UTFPR TESTE         "; -- enviada
	CONSTANT MSG_EXT    : STRING(1 TO MAX_MSG) 	:= ".-...-...-.         "; -- extra


	SIGNAL msg_env : STRING(1 TO MAX_MSG);
	SIGNAL arrayEntrada : char_array;

BEGIN
----------------------------------------------------------
---------- COMPONENTES
----------------------------------------------------------

	-----------------------
	----- VGA

	vga: ENTITY WORK.VGA	GENERIC MAP (TAM_REC => MAX_MSG,
										TAM_ENV => MAX_MSG,
										TAM_EXT => MAX_MSG)
								PORT MAP(CLK_50MHZ => CLK,
										RST => RST,
										MSG_RECEBIDA => MSG_REC,
										MSG_ENVIADA => msg_env, 
										MSG_EXTRA => MSG_EXT,
										HSYNC => HSYNC, 
										VSYNC => VSYNC,    
										R=>R , G=>G, B=>B);       

	cm: ENTITY WORK.ConversorMorse 	GENERIC MAP (MAX_STR => MAX_MSG,
												MAX_ENT => MAX_ENT)
								  		PORT MAP(
										arrayEntrada => arrayEntrada,
										saida => msg_env,
										clk => CLK);
----------------------------------------------------------
---------- PROCESSOS
----------------------------------------------------------
	PROCESS(ALL)

	BEGIN

	END PROCESS;

----------------------------------------------------------
---------- Circuitos
----------------------------------------------------------

	-- "UT TESTE" = ..- - / - . ... - .
	--colocado em ordem contraria
arrayEntrada(39 DOWNTO 0) <= (
		"11","11","11","11","11",
		"11","11","11","11","11",
		"11","11","11","11","11",
		"11","11","11","11","11",
		"11",					-- \FIM
		"10","00", 				-- E
		"10","01", 				-- T
		"10","00","00","00",	-- S
		"10","00", 				-- E
		"10","01", 				-- T
		"11",	 				-- " "
		"10","01", 			  	-- T
		"10","01","00","00"); 	-- U

END ARCHITECTURE;

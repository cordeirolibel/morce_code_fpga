

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY exemplo_VGA IS
	GENERIC( 
			MAX_MSG : INTEGER := 13--tamanho maximo de mensagem
		);
	PORT (
			--vga
			CLK, RST  : IN STD_LOGIC; 
			HSYNC, VSYNC    : OUT STD_LOGIC; 
			R, G, B         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
END ENTITY;

ARCHITECTURE exemplo_VGA OF exemplo_VGA IS
----------------------------------------------------------
---------- LIGACOES
----------------------------------------------------------
	
	CONSTANT MSG_REC    : STRING(1 TO MAX_MSG) 	:= "VHDL EH LEGAL"; -- recebida
	CONSTANT MSG_ENV    : STRING(1 TO MAX_MSG) 	:= "UTFPR TESTE  "; -- enviada
	CONSTANT MSG_EXT    : STRING(1 TO MAX_MSG) 	:= ".-...-...-.  "; -- extra

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
										MSG_ENVIADA => MSG_ENV, 
										MSG_EXTRA => MSG_EXT,
										HSYNC => HSYNC, 
										VSYNC => VSYNC,    
										R=>R , G=>G, B=>B);       

----------------------------------------------------------
---------- PROCESSOS
----------------------------------------------------------
	PROCESS(CLK,RST)

	BEGIN
		
	END PROCESS;

----------------------------------------------------------
---------- Circuitos
----------------------------------------------------------
	
	
	
END ARCHITECTURE;



















-- 
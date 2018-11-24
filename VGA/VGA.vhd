

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

LIBRARY work;
USE work.VGA_LIBRERIA.ALL;
USE work.commonPak.ALL;

ENTITY VGA IS
	PORT (
			CLK_50MHz, RST  : IN STD_LOGIC; 
			HSYNC, VSYNC    : OUT STD_LOGIC; 
			R, G, B         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
END VGA;

ARCHITECTURE VGA OF VGA IS
----------------------------------------------------------
---------- LIGACOES
----------------------------------------------------------
	CONSTANT MSG_TOP    : STRING(1 TO 10) := "Morse Code";
	CONSTANT MSG_REC    : STRING(1 TO 10) := "RECEBIDO: ";
	CONSTANT MSG_ENV    : STRING(1 TO 10) := "ENVIADO:  ";
	CONSTANT MSG_EXT    : STRING(1 TO 10) := ". . ... . ";
	CONSTANT MSG_BOTTOM : STRING(1 TO 34) := "UTFPR 2018 - LOGICA RECONFIGURAVEL";

	SIGNAL HCOUNT : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL VCOUNT : STD_LOGIC_VECTOR(9 DOWNTO 0)  := "0000000000";
	SIGNAL V_SYNC : STD_LOGIC := '0'; 
	SIGNAL H_SYNC : STD_LOGIC := '0'; 
	SIGNAL VIDEO_ON : STD_LOGIC := '0';
	
	
	SIGNAL FALLING_BLOCK_I: INTEGER := 0;
	SIGNAL FALLING_BLOCK_F: INTEGER := 0;
		
	SIGNAL CLK_25MHZ : STD_LOGIC := '0';
	

	CONSTANT NUM_TEXT_ELEMENTS: integer := 5;
	SIGNAL inArbiterPortArray: type_inArbiterPortArray(0 TO NUM_TEXT_ELEMENTS-1) := (OTHERS => init_type_inArbiterPort);
	SIGNAL outArbiterPortArray: type_outArbiterPortArray(0 TO NUM_TEXT_ELEMENTS-1) := (OTHERS => init_type_outArbiterPort);
	
	SIGNAL drawElementArray: type_drawElementArray(0 TO NUM_TEXT_ELEMENTS-1) := (OTHERS => init_type_drawElement);

BEGIN
----------------------------------------------------------
---------- COMPONENTES
----------------------------------------------------------

	-----------------------
	----- VGA

	vs1: ENTITY WORK.VGA_SYNC PORT MAP (CLK_25Mhz => CLK_25MHZ, 
										RST => RST,
										H_SYNC => H_SYNC,
										V_SYNC => V_SYNC,
										VIDEO_ON => VIDEO_ON,
										HCOUNT => HCOUNT,
										VCOUNT => VCOUNT);

	fq1: ENTITY WORK.FQDIVIDER PORT MAP (CLK_IN => CLK_50MHZ, 
										RST => RST,
										CLK_OUT => CLK_25MHZ);

	ba1: ENTITY WORK.blockRamArbiter GENERIC MAP(numPorts => NUM_TEXT_ELEMENTS)
									 PORT MAP(clk => CLK_50MHZ,
											reset => RST,
											inPortArray => inArbiterPortArray,
											outPortArray => outArbiterPortArray);

	-----------------------
	----- TEXTOS

	tl0: ENTITY WORK.text_line	GENERIC MAP (textpassagelength => MSG_TOP'LENGTH)
								PORT MAP(clk => CLK_50MHZ,
										reset => RST,
										textPassage => MSG_TOP,
										position => (200, 75), -- 640x480
										colorMap => (MSG_TOP'LENGTH-1 DOWNTO 0 => WHITE),
										inArbiterPort => inArbiterPortArray(0),
										outArbiterPort => outArbiterPortArray(0),
										hCount => CONV_INTEGER(UNSIGNED(HCOUNT)),
										vCount => CONV_INTEGER(UNSIGNED(VCOUNT)),
										drawElement => drawElementArray(0));

	tl1: ENTITY WORK.text_line	GENERIC MAP (textpassagelength => MSG_REC'LENGTH)
								PORT MAP(clk => CLK_50MHZ,
										reset => RST,
										textPassage => MSG_REC,
										position => (100, 150),-- 640x480
										colorMap => (MSG_REC'LENGTH-1 DOWNTO 0 => WHITE),
										inArbiterPort => inArbiterPortArray(1),
										outArbiterPort => outArbiterPortArray(1),
										hCount => CONV_INTEGER(UNSIGNED(HCOUNT)),
										vCount => CONV_INTEGER(UNSIGNED(VCOUNT)),
										drawElement => drawElementArray(1));
										
	tl2: ENTITY WORK.text_line	GENERIC MAP (textpassagelength => MSG_ENV'LENGTH)
								PORT MAP(clk => CLK_50MHZ,
										reset => RST,
										textPassage => MSG_ENV,
										position => (100, 200),-- 640x480
										colorMap => (MSG_ENV'LENGTH-1 DOWNTO 0 => WHITE),
										inArbiterPort => inArbiterPortArray(2),
										outArbiterPort => outArbiterPortArray(2),
										hCount => CONV_INTEGER(UNSIGNED(HCOUNT)),
										vCount => CONV_INTEGER(UNSIGNED(VCOUNT)),
										drawElement => drawElementArray(2));
	
	tl3: ENTITY WORK.text_line	GENERIC MAP (textpassagelength => MSG_EXT'LENGTH)
								PORT MAP(clk => CLK_50MHZ,
										reset => RST,
										textPassage => MSG_EXT,
										position => (100, 250),-- 640x480
										colorMap => (MSG_EXT'LENGTH-1 DOWNTO 0 => WHITE),
										inArbiterPort => inArbiterPortArray(3),
										outArbiterPort => outArbiterPortArray(3),
										hCount => CONV_INTEGER(UNSIGNED(HCOUNT)),
										vCount => CONV_INTEGER(UNSIGNED(VCOUNT)),
										drawElement => drawElementArray(3));				

	tl4: ENTITY WORK.text_line	GENERIC MAP (textpassagelength => MSG_BOTTOM'LENGTH)
								PORT MAP(clk => CLK_50MHZ,
										reset => RST,
										textPassage => MSG_BOTTOM,
										position => (100, 400),
										colorMap => (MSG_BOTTOM'LENGTH-1 DOWNTO 0 => WHITE),
										inArbiterPort => inArbiterPortArray(4),
										outArbiterPort => outArbiterPortArray(4),
										hCount => CONV_INTEGER(UNSIGNED(HCOUNT)),
										vCount => CONV_INTEGER(UNSIGNED(VCOUNT)),
										drawElement => drawElementArray(4));
----------------------------------------------------------
---------- PROCESSOS
----------------------------------------------------------
	PROCESS(CLK_25MHZ,RST)
		VARIABLE COUNTER : INTEGER := 0; 
		VARIABLE rgbDrawColor : std_logic_vector(7 DOWNTO 0) := BLACK;
		VARIABLE text_draw : STD_LOGIC := '0';
	BEGIN
		IF RISING_EDGE(CLK_25MHZ) THEN 
			--------------------------
			-- verfica todos os textos 
			text_draw := '0';
			FOR i IN drawElementArray'range loop		
				IF drawElementArray(i).pixelOn THEN
					rgbDrawColor := drawElementArray(i).rgb;
					text_draw := '1';
				END IF;
			END LOOP;
			
			--------------------------
			-- print texto
			IF text_draw = '1' THEN
				text_draw := '0';
				
			--------------------------
			-- rentangulos
			ELSIF VCOUNT > 450 AND VCOUNT < 470 AND HCOUNT> 20 AND HCOUNT <620 THEN
				rgbDrawColor := GRAY;
			
			ELSE
				rgbDrawColor := BLACK;
			END IF;

			R <=  rgbDrawColor(7 DOWNTO 5)&'0';
			G <=  rgbDrawColor(4 DOWNTO 2)&'0';
			B <=  rgbDrawColor(1 DOWNTO 0)&"00";
		END IF;
	END PROCESS;		
	
----------------------------------------------------------
---------- Circuitos
----------------------------------------------------------
	VSYNC <= V_SYNC;
	HSYNC <= H_SYNC;
END ARCHITECTURE;



















--


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

	SIGNAL HCOUNT : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL VCOUNT : STD_LOGIC_VECTOR(9 DOWNTO 0)  := "0000000000";
	SIGNAL V_SYNC : STD_LOGIC := '0'; 
	SIGNAL H_SYNC : STD_LOGIC := '0'; 
	SIGNAL VIDEO_ON : STD_LOGIC := '0';
	
	
	SIGNAL FALLING_BLOCK_I: INTEGER := 0;
	SIGNAL FALLING_BLOCK_F: INTEGER := 0;
		
	SIGNAL CLK_25MHZ : STD_LOGIC := '0';
	

	CONSTANT NUM_TEXT_ELEMENTS: integer := 1;
	SIGNAL inArbiterPortArray: type_inArbiterPortArray(0 TO NUM_TEXT_ELEMENTS-1) := (OTHERS => init_type_inArbiterPort);
	SIGNAL outArbiterPortArray: type_outArbiterPortArray(0 TO NUM_TEXT_ELEMENTS-1) := (OTHERS => init_type_outArbiterPort);
	
	SIGNAL drawElementArray: type_drawElementArray(0 TO NUM_TEXT_ELEMENTS-1) := (OTHERS => init_type_drawElement);

BEGIN
----------------------------------------------------------
---------- COMPONENTES
----------------------------------------------------------
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

	tl1: ENTITY WORK.text_line	GENERIC MAP (textpassagelength => 11)
								PORT MAP(clk => CLK_50MHZ,
										reset => RST,
										textPassage => "Hello World",
										position => (50, 50),
										colorMap => (10 downto 0 => "111" & "111" & "11"),
										inArbiterPort => inArbiterPortArray(0),
										outArbiterPort => outArbiterPortArray(0),
										hCount => CONV_INTEGER(UNSIGNED(HCOUNT)),
										vCount => CONV_INTEGER(UNSIGNED(VCOUNT)),
										drawElement => drawElementArray(0));
----------------------------------------------------------
---------- PROCESSOS
----------------------------------------------------------
	PROCESS(CLK_25MHZ,RST)
		VARIABLE COUNTER : INTEGER := 0; 
		VARIABLE rgbDrawColor : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		IF RISING_EDGE(CLK_25MHZ) THEN 
			
			IF drawElementArray(0).pixelOn THEN
				rgbDrawColor := drawElementArray(0).rgb;
				R <=  rgbDrawColor(7 DOWNTO 5)&'0';
				G <=  rgbDrawColor(4 DOWNTO 2)&'0';
				B <=  rgbDrawColor(1 DOWNTO 0)&"00";
				
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND  HCOUNT >1 AND HCOUNT <79  THEN
				R<= (OTHERS => '0'); G <= (OTHERS => '0'); B <= (OTHERS => '1'); --blue  001
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND HCOUNT > 81 AND HCOUNT <159 THEN
				R<= (OTHERS => '0'); G <= (OTHERS => '1'); B <= (OTHERS => '0'); --GREEN  010
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND HCOUNT> 161 AND HCOUNT <239  THEN
				R<= (OTHERS => '0'); G <= (OTHERS => '0'); B <= (OTHERS => '1'); --blue 
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND HCOUNT> 241 AND HCOUNT <319  THEN
				R<= (OTHERS => '0'); G <= (OTHERS => '1'); B <= (OTHERS => '0'); --GREEN  010
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND HCOUNT> 321 AND HCOUNT <399  THEN
				R<= (OTHERS => '0'); G <= (OTHERS => '0'); B <= (OTHERS => '1'); --blue 
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND HCOUNT> 401 AND HCOUNT <479  THEN
				R<= (OTHERS => '0'); G <= (OTHERS => '1'); B <= (OTHERS => '0'); --GREEN  010
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND HCOUNT> 481 AND HCOUNT <559  THEN
				R<= (OTHERS => '0'); G <= (OTHERS => '0'); B <= (OTHERS => '1'); --blue 
			ELSIF VCOUNT > 355 AND VCOUNT < 480 AND HCOUNT> 561 AND HCOUNT <649 THEN
				R <= (OTHERS => '0'); G <= (OTHERS => '1'); B <= (OTHERS => '0'); --GREEN  010
			
			ELSE
				R <= (OTHERS => '0'); G <= (OTHERS => '0'); B <= (OTHERS => '0');
			END IF;

			IF COUNTER = 781250  THEN
				COUNTER:=0;		
				IF  FALLING_BLOCK_F < 130  THEN
					FALLING_BLOCK_F <= FALLING_BLOCK_F + 5;
				ELSIF FALLING_BLOCK_F >= 130 AND FALLING_BLOCK_F < 350  THEN
					FALLING_BLOCK_I <= FALLING_BLOCK_I + 5;
					FALLING_BLOCK_F <= FALLING_BLOCK_F + 5; 
				ELSIF FALLING_BLOCK_I  <= 350 THEN
					FALLING_BLOCK_I <= FALLING_BLOCK_I + 5;
				ELSIF FALLING_BLOCK_I > 350 THEN
					FALLING_BLOCK_I <= 0;
					FALLING_BLOCK_F <= 0;
				END IF;
			ELSE
				COUNTER := COUNTER + 1;		
			END IF;	


			
			--
		END IF;
	END PROCESS;		
	
----------------------------------------------------------
---------- Circuitos
----------------------------------------------------------
	VSYNC <= V_SYNC;
	HSYNC <= H_SYNC;
END ARCHITECTURE;



















--
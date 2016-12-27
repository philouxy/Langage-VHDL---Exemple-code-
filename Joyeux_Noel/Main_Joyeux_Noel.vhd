-----------------------------------------------------------------------------------//
-- Nom du projet 		    : JOYEUX NOEL
-- Nom du fichier 		    : Main_Joyeux_Noel.vhd
-- Date de création 	    : 13.12.2016
-- Date de modification     : xx.xx.2016
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  électronique créée par l'ETML-ES, 
--							  réalisation / simulation d'un message défilant à 
--							  l'aide deux affichage 7 segments à disposition.
--
--							  1) Venir lire un tableau contenant un message et
--                               le faire afficher sur les deux affichage A & B   
--								 La valeur du segment B se déplacera sur le segment 
--								 A, la valeur sur le segment disparaitra  
--								 le déplacement du message sera de 500ms (2Hz) 
--							      
--
-- Remarques 			    : lien
-- 							  1) https://fr.wikibooks.org/wiki/TD3_VHDL_Compteurs_et_registres
----------------------------------------------------------------------------------//

-- déclaration standart des librairies standart pour le VHDL -- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;  
use ieee.numeric_std.all; 								-- pour les opérations mathématiques et convertion 


-- déclaration de l'entité (Entrées / Sorties) --
entity JOYEUX_NOEL is
	port(
		------------
		-- entrée --
		------------ 
		-- logique -- 
		CLK_1_8MHZ 	: in std_logic; 						-- horloge a 1.8432 MHz 
		--SW_9		: in std_logic; 						-- switch S9
		-- bus --
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		SEGMENTS_1 : out std_logic_vector(0 to 6); 		-- Affichage 7Seg -> ABCDEFG 
		SEGMENTS_2 : out std_logic_vector(0 to 6); 		-- Affichage 7Seg -> ABCDEFG
		
		----------------------------------------------------
		-- Elément uniquement utiliser pour la simulation --
		----------------------------------------------------
		clk_10Hz_SIM : out std_logic 
		
	); 
END JOYEUX_NOEL;

architecture COMP_JOYEUX_NOEL of JOYEUX_NOEL is 
	----------------------
	-- signaux internes -- 
	----------------------
	-- types -- 
	type TB_MESSAGES is array (0 to 10) of std_logic_vector(0 to 6); 	-- tableau de 11 cases 
	
	-- constante --                        --ABCDEFG--
	constant MESSAGE_NOEL : TB_MESSAGES := ("0000011", 					-- représente le message a afficher 
	                                        "1100010",                  -- sur les deux afficheurs 7 Segments
	                                        "1001100",
	                                        "0110000",
	                                        "1100011",
	                                        "1001000", 
	                                        "1111111",
	                                        "1101010",
	                                        "1100010",
	                                        "0110000",
	                                        "1110001");  
	
	constant VAL_MAX_COMPTEUR_10HZ 		: std_logic_vector(0 to 19) := X"E0FFF";   -- Valeur réel : 184320 - 1 -> 2CFFF (19) / Valeur de simulation : 18432 -> 4800 (15) 
	constant VAL_MAX_COMPTEUR_10HZ_DIV2 : std_logic_vector(0 to 19) := X"707FF";    -- Valeur réel : 92160 - 1  -> 23C7 (15) / Valeur de simulation : 9216  -> 2400 (15)
	
	-- signaux -- 
	-- logique --
	signal clock_10Hz : std_logic;
	signal compteur_num_p, compteur_num_f : std_logic_vector(0 to 19);
	signal compteur_indice : integer range 0 to 12; 

	-- commencement programme -- 
	begin 

	----------------------------------
	-- compteur tic horloge systeme -- 
	----------------------------------	
	CMPT_ETAT_FUTUR_2HZ : process(compteur_num_p)
		begin 
			if (compteur_num_p >= VAL_MAX_COMPTEUR_10HZ) then
				compteur_num_f <= (others => '0');
			else 
				compteur_num_f <= compteur_num_p + 1;  
			end if; 
	end process; 
	
	CMPT_ETAT_PRESENT_2HZ : process(CLK_1_8MHZ)
		begin 
			if ((CLK_1_8MHZ'event) and (CLK_1_8MHZ = '1')) then 
				compteur_num_p <= compteur_num_f;
			end if; 
	end process; 
		
	-----------------------------------------
	-- Horloge 2Hz rapport cyclique de 50% -- 
	-----------------------------------------
	CLK_2HZ_50P : process (compteur_num_p) 
		begin 
			if rising_edge (CLK_1_8MHZ) then 
				if (compteur_num_f <= VAL_MAX_COMPTEUR_10HZ_DIV2) then
					clock_10Hz <= '0';
				else 
					clock_10Hz <= '1'; 
				end if;
			end if; 
	end process; 
		-- horloge de sortie -- 
	clk_10Hz_SIM <= clock_10Hz;
	
	-----------------------------
	-- compteur indice tableau -- 
	-----------------------------
	CMPT_INDICE : process(clock_10Hz)
		begin 
			if falling_edge(clock_10Hz) then 
				if compteur_indice >= 10 then 
					compteur_indice <= 0;
				else 
					compteur_indice <= compteur_indice + 1;
				end if; 
			end if; 
	end process; 

	----------------------------------
	-- gestion affichage SEG 1 et 2 -- 
	----------------------------------
	GEST_SEG_A_B : process(compteur_indice)
		begin 
			SEGMENTS_1 <= MESSAGE_NOEL(compteur_indice); 
			if compteur_indice = 10 then
				SEGMENTS_2 <= MESSAGE_NOEL(0); 
			else 
				
				SEGMENTS_2 <= MESSAGE_NOEL(compteur_indice + 1); 
			end if;  
	end process; 


end COMP_JOYEUX_NOEL; 

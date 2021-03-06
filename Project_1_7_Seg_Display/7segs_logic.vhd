-----------------------------------------------------------------------------------//
-- Nom du projet 		    : 7 SEGMENT DISPLAY
-- Nom du fichier 		    : 7segs_logic.vhd
-- Date de création 	    : 26.07.2016
-- Date de modification     : 27.07.2016
--
-- Auteur 				    : Ph. Bovey
--
-- Description              :  A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--                             électronique créée par l'ETML-ES, réalisation d'un 
--                             schéma logique concernant l'affichage 7 segments 
--                             (de 0 à F) sous Quartus et ensuite réaliser le code 
--                             en VHDL.
--
-- Remarques 			    :  
----------------------------------------------------------------------------------//

-- déclaration standart des librairies standart pour le VHDL -- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- déclaration de l'entité (Entrées / Sorties) --
entity DISPLAY_7SEGS_LOGIC is
	port(
		------------
		-- entrée --
		------------ 
		-- logique -- 		
		SW_5 	: in std_logic;									-- SW_5 => A  
		SW_6 	: in std_logic;									-- SW_6 => B 
		SW_7 	: in std_logic;									-- SW_7 => C 		
		SW_8 	: in std_logic;									-- SW_8 => D 
		-- bus --
		
		------------
		-- sortie --
		------------
		-- logique -- 
		
		-- bus --
		DISPLAY_7SEG_B : out std_logic_vector(6 downto 0)		-- 6 = segment G et 0 = segment A => --GFEDCBA--
		
	);
END DISPLAY_7SEGS_LOGIC;

-- déclaration de l'architecture --
architecture COMPORTEMENT_7SEGS_LOGIC of DISPLAY_7SEGS_LOGIC is
	
	-- composants -- 
	
	
	
	begin 	

	--------------------------------------
	-- equation selon table de Karnaugh -- 
	--------------------------------------
	-- segment A -- 
	DISPLAY_7SEG_B(0) <= (SW_5 and not (SW_6) and SW_7 and SW_8) or 
						 (SW_5 and not (SW_6) and not (SW_7) and not (SW_8)) or 
						 (not (SW_5) and not (SW_6) and SW_7 and not (SW_8)) or 
						 (SW_5 and SW_6 and not (SW_7) and SW_8);   
	
	-- segment B --
	DISPLAY_7SEG_B(1) <= (SW_5 and not (SW_6) and SW_7 and not (SW_8)) or 
						 (not (SW_5) and SW_6 and SW_7) or 
						 (SW_5 and SW_6 and SW_8) or 
						 (not (SW_5) and SW_7 and SW_8);
	
	-- segment C --
	DISPLAY_7SEG_B(2) <= (not (SW_5) and SW_6 and not (SW_7) and not (SW_8)) or 
						 (SW_6 and SW_7 and SW_8) or 
						 (not (SW_5) and SW_7 and SW_8);  

	-- segment D --
	DISPLAY_7SEG_B(3) <= (not (SW_5) and not (SW_6) and SW_7 and not (SW_8)) or 
						 (SW_5 and SW_6 and SW_7) or 
						 (not (SW_5) and SW_6 and not (SW_7) and SW_8) or
						 (SW_5 and not (SW_6) and not (SW_7) and not (SW_8));
	
	-- segment E --	
	DISPLAY_7SEG_B(4) <= (SW_5 and not (SW_8)) or 
						 (not (SW_6) and SW_7 and not (SW_8)) or 
						 (SW_5 and not (SW_6) and not (SW_7));
	
	-- segment F --
	DISPLAY_7SEG_B(5) <= (SW_5 and not (SW_6) and SW_7 and SW_8) or 
						 (SW_5 and not (SW_7) and not (SW_8)) or 
						 (SW_6 and not (SW_7) and not (SW_8)) or 
						 (SW_5 and SW_6 and not (SW_8));
	
	-- segment G --
	DISPLAY_7SEG_B(6) <= (not (SW_5) and not (SW_6) and SW_7 and SW_8) or 
						 (SW_5 and SW_6 and SW_7 and not (SW_8)) or 
						 (not (SW_6) and not (SW_7) and not (SW_8));

	

end COMPORTEMENT_7SEGS_LOGIC; 


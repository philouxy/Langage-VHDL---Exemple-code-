-----------------------------------------------------------------------------------//
-- Nom du projet 		    : Additionneur
-- Nom du fichier 		    : Affichage_7_seg.vhd
-- Date de création 	    : 16.03.2016
-- Date de modification     : 16.06.2016
--
-- Auteur 				    : Ph. Bovey
--
-- Description              : Reçoit une valeur entire pour l'afficher sur 
--							  affichage 7seg 
--
-- Remarques 			    :  
-- 
-- lien 					: 
----------------------------------------------------------------------------------//
---------------------------------------------------------------
-- déclaration standart des librairies standart pour le VHDL --
--------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 					-- pour les opérations mathématiques  

-------------------------------------------------
-- déclaration de l'entité (Entrées / Sorties) --
-------------------------------------------------
entity AFF_7_SEG is
	port(
		------------
		-- entrée --
		------------ 
		-- entrée simple -- 
		
		-- entrée bus -- 
		VAL_AFF : in integer;			-- pour le sens de la lecture des switches (droite LSB Gauche MSB) 
		
		------------
		-- sortie --
		------------
		-- sortie simple --  
		SEGMENTS_A_TO_G : out std_logic_vector(6 downto 0)  
		
		-- sortie bus -- 

	);
END AFF_7_SEG;

architecture COMPORTEMENT_AFF_7S of AFF_7_SEG is
	
	--------------------------------------------
	-- déclaration de signaux, variables, etc --
	--------------------------------------------	
	begin
	
	with VAL_AFF select 
						  --GFEDCBA--
		SEGMENTS_A_TO_G <= "1000000" when 0,		-- 0
					       "1111001" when 1,		
					       "0100100" when 2,        
					       "0110000" when 3,
					       "0011001" when 4,
					       "0010010" when 5,
					       "0000010" when 6,
					       "1111000" when 7,
					       "0000000" when 8,
					       "0010000" when 9,	
						   "0111111" when others; 	-- 
						   
end COMPORTEMENT_AFF_7S; 
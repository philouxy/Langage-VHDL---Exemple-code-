-----------------------------------------------------------------------------------//
-- Nom du projet 		    : xxx
-- Nom du fichier 		    : aff_num_7seg.vhd
-- Date de création 	            : 16.03.2016
-- Date de modification             : 11.05.2016
--
-- Auteur 			    : Ph. Bovey
--
-- Description                      : convertit une bus std_logic_vector en integer  
--
-- Remarques 			    :  
-- 
-- lien 			    : conversion 
-- http://www.synthworks.com/papers/vhdl_math_tricks_mapld_2003.pdf
----------------------------------------------------------------------------------//
---------------------------------------------------------------
-- déclaration standart des librairies standart pour le VHDL --
--------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 					-- pour les opérations mathématiques  

-- déclaration standart des librairies standart pour le VHDL 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- déclaration de l'entite (Entrées / Sorties) 
entity AFF_NUM_7SEG is
	port(
			
		num_val : in integer range 0 to 15;
		
		aff_valeurs_7seg : out std_logic_vector(6 downto 0)  
	);
END AFF_NUM_7SEG;

Architecture Comportement_Aff_Num_7Seg of AFF_NUM_7SEG is 	
	begin

	aff_valeurs_7seg <= "1000000" when num_val = 0 else      -- doit afficher la valeur 0
	                    "1111001" when num_val = 1 else      -- doit afficher la valeur 1
	                    "0100100" when num_val = 2 else		 -- doit afficher la valeur 2
	                    "0110000" when num_val = 3 else		 -- doit afficher la valeur 3
	                    "0011001" when num_val = 4 else		 -- doit afficher la valeur 4
	                    "0010010" when num_val = 5 else		 -- doit afficher la valeur 5
	                    "0000010" when num_val = 6 else		 -- doit afficher la valeur 6
	                    "1111000" when num_val = 7 else		 -- doit afficher la valeur 7
	                    "0000000" when num_val = 8 else		 -- doit afficher la valeur 8
	                    "0011000" when num_val = 9 else		 -- doit afficher la valeur 9
	                    "0001000" when num_val = 10 else		 -- doit afficher la valeur A
	                    "0000011" when num_val = 11 else		 -- doit afficher la valeur b
	                    "0100111" when num_val = 12 else		 -- doit afficher la valeur c
	                    "0100001" when num_val = 13 else		 -- doit afficher la valeur d
	                    "0000110" when num_val = 14 else		 -- doit afficher la valeur E
	                    "0001110" when num_val = 15; 			 -- doit afficher la valeur F 
end Comportement_Aff_Num_7Seg; 

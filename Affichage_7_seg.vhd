-----------------------------------------------------------------------------------//
-- Nom du projet 		    : Additionneur
-- Nom du fichier 		    : conversion_log_num.vhd
-- Date de création 	    : 16.03.2016
-- Date de modification     : xx.xx.2016
--
-- Auteur 				    : Ph. Bovey
--
-- Description              : convertit une bus std_logic_vector en integer  
--
-- Remarques 			    :  
-- 
-- lien 					: conversion 
-- http://www.synthworks.com/papers/vhdl_math_tricks_mapld_2003.pdf
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
		VAL_AFF : in integer range 0 to 100;			-- pour le sens de la lecture des switches (droite LSB Gauche MSB) 
		
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
	-- constante -- 
	constant MAX_VALUE_CALCUL 	: integer := 100;
	
	begin
	
	with VAL_AFF select 
						  --GFEDCBA--
		SEGMENTS_A_TO_G <= "1000000" when 0,		-- 0
						   "1111100" when 1,		
						   "0010100" when 2,        
						   "0110000" when 3,
						   "0101001" when 4,
						   "0100010" when 5,
						   "0000010" when 6,
						   "1111000" when 7,
						   "0000000" when 8,
						   "0100000" when 9,	
						   "0010001" when 100,  	-- d comme dépassé 
						   "0111111" when others; 	-- -
	--with select
	
	

end COMPORTEMENT_AFF_7S; 
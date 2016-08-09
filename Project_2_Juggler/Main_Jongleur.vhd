-----------------------------------------------------------------------------------//
-- Nom du projet 		    : JONGLEUR
-- Nom du fichier 		    : Main_Jongleur.vhd
-- Date de création 	    : 09.08.2016
-- Date de modification     : xx.xx.2016
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  électronique créée par l'ETML-ES, 
--							  réalisation / simulation d'un jongleur à l'aide des 
--							  deux affichage 7 segments à disposition.
--
--							  1A) faire tourner dles segments dans le sens des 
--							      aiguilles d'une montre à 0.5s (soit 2Hz) 
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
entity JONGLEUR is
	port(
		------------
		-- entrée --
		------------ 
		-- logique -- 
		CLK_1_8MHZ : in std_logic; 						-- horloge a 1.8432 MHz 
		
		-- bus --
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		SEGMENTS_1 : out std_logic_vector(6 downto 0); 		-- Affichage 7Seg 
		SEGMENTS_2 : out std_logic_vector(6 downto 0)		-- Affichage 7Seg 
	); 
END JONGLEUR; 

-- déclaration de l'architecture --
architecture COMPORTEMENT_GENERAL_JONGLEUR of JONGLEUR is

	----------------
	-- composants -- 
	----------------
	
	----------------------
	-- signaux internes -- 
	----------------------
	-- constante -- 
	constant VAL_MAX_COMPTEUR_2HZ : integer := 921600;	-- valeur max de tic  
	
	-- signal -- 
	signal compteur_num : integer := 0;
	
	signal clk_2Hz 		: std_logic; 
	
	signal etat_segment : std_logic_vector(2 downto 0);   
	
	   
	begin 	

	--------------
	-- compteur -- 
	--------------	
	CMPT_2Hz: process (CLK_1_8MHZ)
		begin 
		-- détection d'évenement sur flanc montant -- 
		if(CLK_1_8MHZ'event and CLK_1_8MHZ = '1') then
			if (compteur_num < VAL_MAX_COMPTEUR_2HZ) then   
				compteur_num <= compteur_num + 1;
			else 
				compteur_num <= 0; 
			end if;   
		end if; 
	end process; 
	
	-----------------
	-- Horloge 2Hz -- 
	-----------------
	clk_2Hz <= '1' when compteur_num >= (VAL_MAX_COMPTEUR_2HZ/2) else 
               '0';  
               
    --------------------------
	-- Gestion des Segments -- 
	--------------------------
	ETAT_SEG : process (clk_2Hz)
		begin 
			-- détection d'évenement sur flanc montant -- 
			if (clk_2Hz'event and clk_2Hz = '1') then
				-- si plus petit que '6' -- 
				if etat_segment < "110" then 
					etat_segment <= etat_segment + 1; 
				else 
					etat_segment <= "000"; 
				end if; 
			end if; 
	end process; 
	
	------------------------------------
	-- Assignation final des Segments -- 
	------------------------------------
	with etat_segment select 
					 --GFEDCBA-- 
		SEGMENTS_1 <= "1101111" when "000",   		  		-- segment E allumé en 0
					  "1011111" when "001",   		  		-- segment F allumé en 1
					  "1111110" when "010",   		  		-- segment A allumé en 2
		              "1111111" when others; 
	
    with etat_segment select 
					 --GFEDCBA-- 
		SEGMENTS_2 <= "1111110" when "011",   		  		-- segment A allumé en 3
					  "1111101" when "100",   		  		-- segment B allumé en 4
					  "1111011" when "101",   		  		-- segment C allumé en 5
		              "1111111" when others;           
	
end COMPORTEMENT_GENERAL_JONGLEUR; 
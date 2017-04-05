-----------------------------------------------------------------------------------//
-- Nom du projet 		    : MIROIR 
-- Nom du fichier 		    : affichage.vhd
-- Date de création 	    : 01.03.2017
-- Date de modification     : xx.xx.2017
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  électronique créée par l'ETML-ES, 
--							  réalisation / simulation d'un message défilant de type 
--							  A, b, c, d sur le premier segment à une fréquence 20Hz.  
--
--							  Selon la configuration des switches S10 et S11, 
--							  le deuxième segment sera le miroire soit horizontal, soit 
--							  vertical du segment 1
--
--							  configuration SW10 et SW11
--							  S10 = 0 / S11 = 0 => il n'y a que le segment 1 qui est allumé 
--							  S10 = 0 / S11 = 1 => Segment 2 est le miroire horizontal du Segment 1  
--           				  S10 = 1 / S11 = 0 => Segment 2 est le miroire vertical du Segment 1 
--							  S10 = 1 / S11 = 1 => Segment 1 et 2 affiche le meme valeur  
--
--							      
-- Remarques 			    : lien
-- 							  1) https://fr.wikibooks.org/wiki/TD3_VHDL_Compteurs_et_registres
----------------------------------------------------------------------------------//
-- déclaration standart des librairies standart pour le VHDL -- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;  
use ieee.numeric_std.all; 								-- pour les opérations mathématiques et convertion 

-- déclaration de l'entité (Entrées / Sorties) --
entity AFF_7SEG is
	port(
		------------
		-- entrée --
		------------ 
		-- logique -- 

		-- bus --
		INFO_ETAT		 	: in std_logic_vector(0 to 1); 		-- défini quel tableau lire 
		INFO_CMPT			: in std_logic_vector(0 to 1); 		-- défini quel segment d'un tableau lire
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		VAL_SEG : out std_logic_vector(0 to 6) 		-- Affichage 7Seg -> ABCDEFG 
		
		----------------------------------------------------
		-- Elément uniquement utiliser pour la simulation --
		----------------------------------------------------
	); 
END AFF_7SEG;

architecture COMP_AFF_7SEG of AFF_7SEG is 
	----------------------
	-- signaux internes -- 
	----------------------
	-- type -- 
	type TB_MSG_A_A_D is array (0 to 3) of std_logic_vector(0 to 6); 	-- tableau de 4 cases 
	
	-- constante --                        		--ABCDEFG--
	constant AFF_A_A_D_NORMAL : TB_MSG_A_A_D := ("0001000", 	-- A 		-- représente le message a afficher 
	                                             "1100000", 	-- b        -- sur un afficheur 7 Segments 
	                                             "1110010", 	-- c
	                                             "1000010");  	-- d
	
												  --ABCDEFG--
	constant AFF_A_A_D_MIROIR_H : TB_MSG_A_A_D := ("1000000", 	--  		-- représente le message a afficher 
	                                               "0011000", 	--          -- sur un afficheur 7 Segments 
	                                               "0111100", 	-- 
	                                               "0001100");  -- 
	
											      --ABCDEFG--
	constant AFF_A_A_D_MIROIR_V : TB_MSG_A_A_D := ("0001000", 	--  		-- représente le message a afficher 
	                                               "1000010", 	--          -- sur un afficheur 7 Segments 
	                                               "1100110", 	-- 
	                                               "1100000");  -- 
	
	-- signal -- 
	-- bus -- 
	--signal cmpt_4x : std_logic_vector(0 to 1); 
	
	-- entier -- 
	signal val_cmpt 	: integer range 0 to 4; 
	signal val_etat 	: integer range 0 to 4; 
	
	---------------------
	-- début programme --
	---------------------
	begin 
	
	--------------------------------------------
	-- conversion std_logic_vector => integer -- 
	--------------------------------------------
	val_cmpt <= to_integer(unsigned(INFO_CMPT)); 
	val_etat  <= to_integer(unsigned(INFO_ETAT));
	
	-----------------------
	-- affichage SEGMENT -- 
	-----------------------
	AFF_7SEG : process(val_cmpt) 
		begin 
			case val_cmpt is 
				when 0 => 
					-- Etat Eteint --
					if (val_etat = 0) then 
						VAL_SEG <= "1111111";
					-- Etat miroire horizontal --
					elsif (val_etat = 1) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_H(val_cmpt); 
					-- Etat miroire vertical  --
					elsif (val_etat = 2) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_V(val_cmpt); 
					-- Etat standart  --	
					elsif (val_etat = 3) then 
						VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
					end if; 
				when 1 => 
					-- Etat Eteint --
					if (val_etat = 0) then 
						VAL_SEG <= "1111111";
					-- Etat miroire horizontal --
					elsif (val_etat = 1) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_H(val_cmpt); 
					-- Etat miroire vertical  --
					elsif (val_etat = 2) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_V(val_cmpt); 
					-- Etat standart  --	
					elsif (val_etat = 3) then 
						VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
					end if; 
				when 2 => 
					-- Etat Eteint --
					if (val_etat = 0) then 
						VAL_SEG <= "1111111";
					-- Etat miroire horizontal --
					elsif (val_etat = 1) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_H(val_cmpt); 
					-- Etat miroire vertical  --
					elsif (val_etat = 2) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_V(val_cmpt); 
					-- Etat standart  --	
					elsif (val_etat = 3) then 
						VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
					end if; 
				when 3 => 
					-- Etat Eteint --
					if (val_etat = 0) then 
						VAL_SEG <= "1111111";
					-- Etat miroire horizontal --
					elsif (val_etat = 1) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_H(val_cmpt); 
					-- Etat miroire vertical  --
					elsif (val_etat = 2) then 
						VAL_SEG <= AFF_A_A_D_MIROIR_V(val_cmpt); 
					-- Etat standart  --	
					elsif (val_etat = 3) then 
						VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
					end if; 
				when others => VAL_SEG <= "1111110";
			end case; 
	end process; 
	
end COMP_AFF_7SEG; 


--			if val_etat = 0 then 
--				case val_cmpt is   
--					when 0 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when 1 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when 2 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when 3 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when others => VAL_SEG <= "1111110";
--				end case; 
--			elsif val_etat = 1 then
--				case val_cmpt is   
--					when 0 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when 1 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when 2 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when 3 => VAL_SEG <= AFF_A_A_D_NORMAL(val_cmpt); 
--					when others => VAL_SEG <= "1111110";
--				end case; 
--			end if; 
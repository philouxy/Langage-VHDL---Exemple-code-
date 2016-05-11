-----------------------------------------------------------------------------------//
-- Nom du projet 		    : Projet
-- Nom du fichier 		    : antirebond.vhd
-- Date de création 	    : 22.01.2016
-- Date de modification     : 19.02.2016
--
-- Auteur 				    : Ph. Bovey
--
-- Description              :  
--
-- Remarques 			    :  
----------------------------------------------------------------------------------//

-- déclaration standart des librairies standart pour le VHDL 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- déclaration de l'entité (Entrées / Sorties) 
entity ANTIREBOND is
	port(
		-- entrée -- 
		SW_X : in std_logic; 
		nRST : in std_logic; 
		CLK	 : in std_logic; 
		
		-- sortie -- 
		SW_OUT_P : out std_logic
	);
END ANTIREBOND;

architecture COMPORTEMENT_ARD of ANTIREBOND is

	-- déclaration de signaux, variables, etc -- 
	-- constante -- 
	constant MAX_CPT : integer 	:= 9216;  	-- correspond a 5ms/(1/f_osc) = 5ms/(1/1.8432MHz)
	
	-- signal logique -- 
	signal switch_etat_passe   : std_logic; 	 -- mémorisation
	signal switch_propre 	   : std_logic; 	 -- signal propre   	 	
	signal start_cpt_m         : std_logic;      -- pour démarage du cpt etat montant 
	signal start_cpt_d		   : std_logic; 	 -- pour démarage du cpt etat descendant
	signal fin_cpt			   : std_logic; 	
	
	-- signal numerique --
	signal cpt_5ms : integer range 0 to (MAX_CPT + 1) := 0;  -- idem
		
	begin

	------------------------
	-- detection de flanc -- 
	------------------------
	detec_flanc : process(nRST, SW_X, fin_cpt)
		begin
			if(nRST = '0') or (fin_cpt = '1') then
			    start_cpt_m <= '0'; 
				start_cpt_d <= '0';           -- forcer start à zéro
				switch_etat_passe <= 'X';
			-- si y a un changement d'état sur le signal du switch -- 	
			elsif (SW_X'event) and (SW_X = '1') then 
				-- detection du premier rebond // flanc montant --
				if (fin_cpt = '0') and (cpt_5ms = 0) then	 
					start_cpt_m <= '1'; 			-- activation du compteur
					switch_etat_passe <= '0'; 		-- mémorisation de l'etat du switch passer
				end if; 
			elsif (SW_X'event) and (SW_X = '0') then
				-- detection du premier rebond // flanc descendant --
				if (fin_cpt = '0') and (cpt_5ms = 0) then	 
					start_cpt_d <= '1';
					switch_etat_passe <= '1'; 		-- mémorisation de l'etat du switch passer
				end if; 
			end if; 
	end process; 
	
	----------------------------
	-- compteur 5ms commander --
	---------------------------- 
	compeur_5ms : process(CLK, start_cpt_m, start_cpt_d)
		begin  
		    -- si les signaux de start sont à zéro pas de comptage
			if(start_cpt_m = '0') and (start_cpt_d = '0') then
				cpt_5ms <= 0;		        -- valeur numérique
				fin_cpt <= '0';		   		-- valeur logique
			-- si start_cpt = 1 ou que le compteur < MAX_CPT alors incérmentation  compteur 	 	
			elsif (CLK'event) and (CLK = '1') then
				if (start_cpt_m = '1' and start_cpt_d = '0') or (start_cpt_m = '0' and start_cpt_d = '1') then 
					if (cpt_5ms < MAX_CPT) then  
						cpt_5ms <= cpt_5ms + 1;
					elsif(cpt_5ms >= MAX_CPT) then 
						fin_cpt <= '1'; 
						cpt_5ms <= 0;
					end if;
				end if;  
			end if; 
	end process;  
	
	----------------------------------
	-- assignation du signal propre --
	----------------------------------
	sign_propre_montant : process(fin_cpt, switch_etat_passe, SW_X)
		begin
			-- evenement sur le flanc montant du signal "fin_cpt_m" pour gérer le passage 0 -> 1 
			if(fin_cpt'event) and (fin_cpt = '1') then 
				if (switch_etat_passe = not(SW_X)) then
					switch_propre <= SW_X;
				else
					switch_propre <= SW_X; 
				end if; 
			end if; 
	end process;
	
	--------------------------------------------------------
	-- assignation du signal propre à une sortie physique --
	--------------------------------------------------------		
	SW_OUT_P <= switch_propre; 
		 
end COMPORTEMENT_ARD; 

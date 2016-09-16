-----------------------------------------------------------------------------------//
-- Nom du projet 		    : JONGLEUR
-- Nom du fichier 		    : Main_Jongleur.vhd
-- Date de création 	    : 09.08.2016
-- Date de modification     : 16.09.2016
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  électronique créée par l'ETML-ES, 
--							  réalisation / simulation d'un jongleur à l'aide des 
--							  deux affichage 7 segments à disposition.
--
--							  1A) faire tourner les segments dans le sens des 
--							      aiguilles d'une montre à 0.5s (soit 2Hz) 
--							   B) avec le Switch S9 de la carte, une pression (> 1s) 
--								  doit permettre d'arrêter la séquence, de la 
--								  redémarrer dans l'autre sens, si on appuie à nouveau 
--								  la séquence s'arrête, si on appuie encore une fois 
--								  la séquence repart dans la sens initial
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
		CLK_1_8MHZ 	: in std_logic; 						-- horloge a 1.8432 MHz 
		SW_9		: in std_logic; 						-- switch S9
		-- bus --
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		SEGMENTS_1 : out std_logic_vector(6 downto 0); 		-- Affichage 7Seg 
		SEGMENTS_2 : out std_logic_vector(6 downto 0); 		-- Affichage 7Seg 
		
		----------------------------------------------------
		-- Elément uniquement utiliser pour la simulation --
		----------------------------------------------------
		clk_2Hz_SIM : out std_logic 
		
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
	constant VAL_MAX_COMPTEUR_2HZ 	: std_logic_vector(23 downto 0) := X"1C1FFF";  	-- 1843200 = X"1C1FFF" =>  Pour simulation  -- X"000013";
	constant VAL_MAX_CMPT_DIV_2	 	: std_logic_vector(23 downto 0) := X"0E0FFF"; 	-- 921599  = X"0E0FFF" =>  pour simulation  -- X"000009
	constant VAL_MAX_CMPT_ETAT_S9	: std_logic_vector(3 downto 0)  := X"3";		--  
	
	-- signal -- 
	signal clk_2Hz 			: std_logic;
	signal flag_cmpt_etat	: std_logic := '1'; 		-- flag indiquand si le compteur d'état est operationnel ou pas  => 1 = Cmpt_Actif / 0 = Cmpt_no_Actif
	signal flag_start_S9	: std_logic;   
	
	signal etat_segment 	: std_logic_vector(2 downto 0);   
	signal compteur_num_f 	: std_logic_vector(23 downto 0);
	signal compteur_num_p 	: std_logic_vector(23 downto 0);
	signal cmpt_demi_s_p	: std_logic_vector(1 downto 0); 
	signal cmpt_demi_s_f	: std_logic_vector(1 downto 0);
	signal cmpt_etat_SW9	: std_logic_vector(1 downto 0) := "00";
	      
	begin 	
	----------------------------------
	-- compteur tic horloge systeme -- 
	----------------------------------	
	CMPT_ETAT_FUTUR_2HZ : process(compteur_num_p)
		begin 
			if (compteur_num_p >= VAL_MAX_COMPTEUR_2HZ) then
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
		
--	-----------------------------------------
--	-- Horloge 2Hz rapport cyclique de 50% -- 
--	-----------------------------------------
	CLK_2HZ_50P : process (compteur_num_p) 
		begin 
			if rising_edge (CLK_1_8MHZ) then 
				if (compteur_num_f <= VAL_MAX_CMPT_DIV_2) then
					clk_2Hz <= '0';
				else 
					clk_2Hz <= '1'; 
				end if;
			end if; 
	end process; 
	
	-- horloge de sortie -- 
	clk_2Hz_SIM <= clk_2Hz;
    
    ----------------------------------
	-- compteur tic horloge 2Hz -- 
	----------------------------------           
--	CMPT_DEMI_SEC_FUTUR : process(cmpt_demi_s_p)
--		begin 
--			if falling_edge (SW_9) then 
--				cmpt_demi_s_f <=  (others => '0');
--				flag_start_S9 <= 
--			elsif (cmpt_demi_s_p >= VAL_MAX_CMPT_DEMI_S) then 
--				cmpt_demi_s_f <=  (others => '0');
--			else 
--				cmpt_demi_s_f <= cmpt_demi_s_p + 1;  
--			end if; 
--	end process; 
--	
--	CMPT_DEMI_SEC_PRESENT : process(clk_2Hz)
--		begin
--		 if rising_edge(clk_2Hz) then 
--			cmpt_demi_s_p <= cmpt_demi_s_f;  
--		 end if; 
--	end process;           
    
	-----------------------
	-- Gestion touche S9 -- 
	-----------------------
	ETAT_S9 : process(SW_9)
		begin
		-- détection venement sur S9 --  
		if falling_edge(SW_9) then															
			if (cmpt_etat_SW9 >= VAL_MAX_CMPT_ETAT_S9) then
				cmpt_etat_SW9 <= "00"; 
			else 
				cmpt_etat_SW9 <= cmpt_etat_SW9 + 1;
				--flag_cmpt_etat <= not (flag_cmpt_etat); 
			end if; 
		end if;
	end process;
       
    --------------------------
	-- Gestion des Segments -- 
	--------------------------
	ETAT_SEG : process (clk_2Hz)
		begin 
			-- détection d'évenement sur flanc montant -- 
			if (clk_2Hz'event and clk_2Hz = '1') then
				-- test si compteur est à 0 -> tourne dans le sens des aiguilles d'une montre -- 
				if cmpt_etat_SW9 = "00" then 
					-- si plus petit que '6' -- 
					if etat_segment < "110" then 
						etat_segment <= etat_segment + 1; 
					else 
						etat_segment <= "000"; 
					end if; 
				-- test si compteur est à 2 -> tourne dans le sens contraire des aiguilles d'une montre --	
				elsif cmpt_etat_SW9 = "10" then 
					-- si plus petit que '6' -- 
					if etat_segment > "000" then 
						etat_segment <= etat_segment - 1; 
					else 
						etat_segment <= "110"; 
					end if;
				-- reste en mode bloquer --
				else 
					etat_segment <= etat_segment;
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

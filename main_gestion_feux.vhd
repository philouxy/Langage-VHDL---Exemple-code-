-----------------------------------------------------------------------------------//
-- Nom du projet 		    : Gestion_feux
-- Nom du fichier 		    : main_gestion_feux.vhd
-- Date de création 	    : 16.03.2016
-- Date de modification     : 16.06.2016
--
-- Auteur 				    : Ph. Bovey
--
-- Description              : simulation de la gestion d'un carfour entre une route 
--							  secondaire  et une route principal. 
--							  condition initial : Route Secondaire -> Feux rouge
--							  Détection voiture sur la route secondaire -> 3s 
--							  Séquence Feux : 
--							  1) Route principal : Vert - Orange - Rouge (1s par changement) 
--							  2) Route secondaire : Rouge/Orange - Vert (1s par changement) 
--						      3) 5s d'attente 
--							  4) Route secondaire : Orange - Rouge (1s par changement)
--							  5) Route principal : Rouge/Orange - Vert (1s par changement)
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
entity Gestion_feux is
	port(
		------------
		-- entrée --
		------------ 
		-- entrée simple -- 
		SW_9 			: in std_logic; 
		SW_nRST 		: in std_logic;
		CLK_SYSTEM 		: in std_logic; 
				
		------------
		-- sortie --
		------------
		-- sortie simple --  
		LED_R1, LED_O1, LED_V1 : out std_logic;
		LED_R2, LED_O2, LED_V2 : out std_logic; 
		POINT_A				   : out std_logic;
		
		-- sortie bus -- 
		AFF_7SEG_A : out std_logic_vector(6 downto 0)   
	);
END Gestion_feux;

architecture Comp_Gestion_Feu of Gestion_feux is 
	------------------------------
	-- déclaration de constante --
	------------------------------
	constant VAL_MAX_CMPT_1S 		: integer := 1843200;   	-- t_fpga = 1/f_fpga => on veut 1s : t_1s = 1s/(1/f_fgpa) = 1s/(1/1.8432MHz)
	constant VAL_MAX_CMPT_1S_DIV2 	: integer := 921600;   		-- t_fpga / 2 pour avoir un rapport cyclique (duty cycle) de 50%  
	constant VAL_NB_ETAT_MAX		: integer := 15;			-- nombre d'état possible 
	
	-----------------------------
	-- déclaration de variable --
	-----------------------------
	-- type entier --
	signal compteur_1s	 : integer range 0 to VAL_MAX_CMPT_1S := 0; 		-- réel 
	signal compteur_etat : integer range 0 to VAL_NB_ETAT_MAX := 0; 		-- etat  
		
	-- type logique -- 
	signal clock_int_1s 	:  std_logic;				-- réel 
	signal start_cmpt_etat 	:  std_logic 	:= '0';		-- 
	signal flag_3s			:  std_logic	:= '0';		--  
	signal point_clign		:  std_logic	:= '0';		-- 
	
	-- type logique bus -- 
	signal test : std_logic_vector(6 downto 0);
	
	-------------------------------
	-- déclaration de composants --
	-------------------------------
	component AFF_7_SEG
		port(
		-- entrée --
		VAL_AFF : in integer;-- range 0 to 100;			-- pour le sens de la lecture des switches (droite LSB Gauche MSB) 
		
		-- sortie --  
		SEGMENTS_A_TO_G : out std_logic_vector(6 downto 0)  
	); 
	end component; 
	
	-- START --
	begin
	
	--------------------
	-- affichage etat --
	--------------------
	AFFICH_STATUS_3S : AFF_7_SEG port map (compteur_etat, test); 
	
	AFF_7SEG_A <= test when compteur_etat <= 3 and flag_3s = '0' else 
	              "0111111";  												-- correspond à un trait 
	
	-------------------------
	-- compteur - durée 1s --
	-------------------------
	compt_1s : process(CLK_SYSTEM)
		begin
			-- événement sur la clock -> front montant -- 
			if(CLK_SYSTEM'event) and (CLK_SYSTEM = '1') then
				if(compteur_1s <= VAL_MAX_CMPT_1S -1) then 
					compteur_1s <=  compteur_1s + 1; 
				else 
					compteur_1s <= 0; 
				end if;  
			end if;  
	end process; 
	
	---------------------------------
	-- Clock 1HZ - duty cycle: 50% --
	---------------------------------
	clock_int_1s <= '1' when compteur_1s < (VAL_MAX_CMPT_1S_DIV2) else 	--	VAL_MAX_CMPT_1S/2
			        '0'; 	
	 
	----------------------------------------
	-- vie systeme - clignotement LED 1Hz --
	----------------------------------------
	POINT_A <= '1' when clock_int_1s = '0' else 
	           '0';
	
	-----------------------
	-- compteur commandé --
	-----------------------
	compt_M_E : process(clock_int_1s)
		begin 
			if (clock_int_1s'event) and (clock_int_1s = '1') then				
				if (compteur_etat >= VAL_NB_ETAT_MAX) or (start_cmpt_etat = '0') then 
					compteur_etat <= 0;
					flag_3s <= '0'; 
				-- test pour n'afficher que les 3s --
				elsif (compteur_etat >= 3) then 
					flag_3s <= '1'; 
					compteur_etat <= compteur_etat + 1;
				else 
					compteur_etat <= compteur_etat + 1; 
				end if;
			end if;  
	end process; 
	
	----------------------------
	-- détection event sur S9 --
	----------------------------
	detect_S9 : process(SW_9, start_cmpt_etat)
		begin 
			-- événement sur le S9 que si start_cmpt_etat = '0' -- 
			if (SW_9'event) and (SW_9 = '0') and (start_cmpt_etat = '0') then
				if (compteur_etat > 3) then 
					start_cmpt_etat <= '0'; 
				else 
					start_cmpt_etat <= '1';
				end if;  
			end if; 
	end process; 
		
	--------------------------------
	-- Gestion Feu machine d'état --
	--------------------------------
	ME_gest_feux : process(compteur_etat)
		begin
			-- initialisation --
			-- feux principal vert --
			-- feux secondaire rouge --
			if (compteur_etat < 4) then
				-- feux principal 
				LED_R1 <= '1'; 	-- Eteint 
				LED_O1 <= '1';	-- Eteint	 
				LED_V1 <= '0'; 	-- Allumé  
				
				-- secondaire
				LED_R2 <= '0'; 	-- Allumé 
				LED_O2 <= '1';	-- Eteint	 
				LED_V2 <= '1'; 	-- Eteint
			
			-- feux principal orange --
			elsif  (compteur_etat = 4) then
				-- feux principal 
				LED_R1 <= '1'; 	-- Eteint 
				LED_O1 <= '0';	-- Allumé	 
				LED_V1 <= '1'; 	-- Eteint
				
				-- secondaire
--				LED_R2 <= '0'; 	-- Allumé 
--				LED_O2 <= '1';	-- Eteint	 
--				LED_V2 <= '1'; 	-- Eteint

			-- feux principal rouge --
			-- feux secondaire rouge -- 
			elsif  (compteur_etat = 5) then
				-- feux principal 
				LED_R1 <= '0'; 	-- Allumé 
				LED_O1 <= '1';	-- Eteint	 
				LED_V1 <= '1'; 	-- Eteint
				
				-- secondaire
--				LED_R2 <= '0'; 	-- Allumé 
--				LED_O2 <= '1';	-- Eteint	 
--				LED_V2 <= '1'; 	-- Etein

			-- feux secondaire rouge/orange --
			elsif  (compteur_etat = 6) then
				-- feux principal 
--				LED_R1 <= 0; 	-- Allumé 
--				LED_O1 <= 1;	-- Eteint	 
--				LED_V1 <= 1; 	-- Eteint
				
				-- secondaire
				LED_R2 <= '0'; 	-- Allumé 
				LED_O2 <= '0';	-- Allumé	 
				LED_V2 <= '1'; 	-- Eteint
				
			-- feux principal rouge 
			-- feux secondaire vert --	
			elsif  (compteur_etat >= 7) or (compteur_etat < 12) then
				-- feux principal 
--				LED_R1 <= 0; 	-- Allumé 
--				LED_O1 <= 1;	-- Eteint	 
--				LED_V1 <= 1; 	-- Eteint
				
				-- secondaire
				LED_R2 <= '1'; 	-- Eteint 
				LED_O2 <= '1';	-- Eteint	 
				LED_V2 <= '0'; 	-- Allumé

			-- feux secondaire orange --	
			elsif  (compteur_etat = 12) then
				-- feux principal 
--				LED_R1 <= 0; 	-- Allumé 
--				LED_O1 <= 1;	-- Eteint	 
--				LED_V1 <= 1; 	-- Eteint
				
				-- secondaire
				LED_R2 <= '1'; 	-- Eteint 
				LED_O2 <= '0';	-- Allumé	 
				LED_V2 <= '1'; 	-- Eteint			

			-- feux principal rouge --
			-- feux secondaire rouge --	
			elsif  (compteur_etat = 13) then
				-- feux principal 
--				LED_R1 <= 0; 	-- Allumé 
--				LED_O1 <= 1;	-- Eteint	 
--				LED_V1 <= 1; 	-- Eteint
				
				-- secondaire
				LED_R2 <= '0'; 	-- Allumé 
				LED_O2 <= '1';	-- Eteint	 
				LED_V2 <= '1'; 	-- Eteint			

			-- feux principal rouge/orange -- 	
			elsif (compteur_etat = 14) then
				-- feux principal 
				LED_R1 <= '0'; 	-- Allumé 
				LED_O1 <= '0';	-- Allumé	 
				LED_V1 <= '1'; 	-- Eteint
				
				-- secondaire
--				LED_R2 <= '1'; 	-- Eteint 
--				LED_O2 <= '0';	-- Allumé	 
--				LED_V2 <= '1'; 	-- Eteint
			
			-- feux principal vert -- 	
			elsif (compteur_etat = 15) then
				-- feux principal 
				LED_R1 <= '1'; 	-- Eteint 
				LED_O1 <= '1';	-- Eteint	 
				LED_V1 <= '0'; 	-- Allumé
				
				-- secondaire
--				LED_R2 <= '1'; 	-- Eteint 
--				LED_O2 <= '0';	-- Allumé	 
--				LED_V2 <= '1'; 	-- Eteint 
			end if; 
	end process; 
	
end architecture;

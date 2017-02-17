-----------------------------------------------------------------------------------//
-- Nom du projet 		    : COMPTEUR 
-- Nom du fichier 		    : main_compteur_0_9.vhd
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
--							  1) L'affichage 7 segments de votre carte doit compter de 0 à 9 
--								 selon differentes configurations de switches 
--								 S1 -> 0 - bloqué/pas de compatge   
--									-> 1 - comptage 
--								 S2 -> 0 - comptge 0 à 9 
--									-> 1 - decomptage 9 à 0 
--								 S10&S11
--									-> 00 - clock de 1HZ - periode de 1s  
--									-> 11 - clock de 2Hz - periode de 0.5s 
--									-> 10 - periode de 1ms - clock de 1000 kHz - utiliser pour la simulation 
--									-> 01 - periode de 2ms - clock de 500 Hz - utiliser pour la simulation 
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
entity COMPTEUR is
	port(
		------------
		-- entrée --
		------------ 
		-- logique -- 
		CLK_1_8MHZ 				 : in std_logic; 						-- horloge a 1.8432 MHz 
		SW_1, SW_2, SW_10, SW_11 : in std_logic; 						-- switch 1, 2, 10, 11
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
		clk_1KHz_SIM  : out std_logic; 
		clk_500Hz_SIM : out std_logic 
		
	); 
END COMPTEUR;

architecture COMP_COMPTEUR of COMPTEUR is 
	----------------------
	-- signaux internes -- 
	----------------------
	-- constantes -- 
	constant VAL_MAX_COMPTEUR_1HZ 	     : std_logic_vector(0 to 23) := X"1C1FFF";   	-- Valeur réel : 1843200 - 1 	-> 1C1FFF (24) /  
	constant VAL_MAX_COMPTEUR_1HZ_DIV2   : std_logic_vector(0 to 19) := X"2CFFF";    	-- Valeur réel : 921600 - 1     -> 2CFFF  (19) / 
	constant VAL_MAX_COMPTEUR_2HZ 		 : std_logic_vector(0 to 19) := X"E0FFF";   	-- Valeur réel : 921600 - 1  	-> 2CFFF  (19) /  
	constant VAL_MAX_COMPTEUR_2HZ_DIV2   : std_logic_vector(0 to 19) := X"707FF";    	-- Valeur réel : 460800 - 1     -> 707FF  (19) / 
	constant VAL_MAX_COMPTEUR_500HZ 	 : std_logic_vector(0 to 11) := X"E66";   		-- Valeur réel : 3868 - 1    	-> E66 (11) / 
	constant VAL_MAX_COMPTEUR_500HZ_DIV2 : std_logic_vector(0 to 11) := X"733";    		-- Valeur réel : 1843 - 1       -> 733 (11) / 
	constant VAL_MAX_COMPTEUR_1KHZ 		 : std_logic_vector(0 to 11) := X"733";   		-- Valeur réel : 1843 - 1    	-> 733 (11) /  
	constant VAL_MAX_COMPTEUR_1KHZ_DIV2  : std_logic_vector(0 to 11) := X"398";    		-- Valeur réel : 921 - 1        -> 398 (11) / 	
	
	-- signaux -- 
	-- logique --
	signal clk_1Hz, clk_2Hz, clk_1kHz, clk_500Hz, clk_select_int : std_logic;
	 
	-- bus --  
	signal etat_comptage, select_frequence 	: std_logic_vector(1 downto 0); 
	signal cpt_p_1HZ, cpt_f_1HZ 			: std_logic_vector(0 to 23);
	signal cpt_p_2HZ, cpt_f_2HZ 			: std_logic_vector(0 to 19);
	signal cpt_p_1kHZ, cpt_f_1kHZ 			: std_logic_vector(0 to 11);
	signal cpt_p_500HZ, cpt_f_500HZ 		: std_logic_vector(0 to 19);
	
	-- entier -- 
	signal compteur_indice : integer range 0 to 12; 

	-- component name_composant is 
	-- 	port( meme chose qu'une entite
		)
	-- end component; 

	-- commencement programme -- 
	begin
	
	-- un_composant : name_composant port map (a => a_prog)
	
	
	----------------------------------
	-- BUS Interne - initialisation -- 
	----------------------------------	
	select_frequence <= (SW_10, SW_11); 			-- attention au sens de lecture S10(1) - S11(0)
	etat_comptage <= (SW_1, SW_2); 					-- attention au sens de lecture S1(1) - S2(0)

	----------------------------------
	-- compteur tic horloge systeme -- 
	----------------------------------	
	CMPT_ETAT_PRESENT : process(CLK_1_8MHZ)
		begin 
			-- MAJ de tous les compteur -- 
			if ((CLK_1_8MHZ'event) and (CLK_1_8MHZ = '1')) then 
				cpt_p_1HZ <= cpt_f_1HZ;
				cpt_p_2HZ <= cpt_f_2HZ;
				cpt_p_500HZ <= cpt_f_500HZ;
				cpt_p_1kHZ <= cpt_f_1kHZ;
			end if; 
	end process; 
	
	CMPT_ETAT_FUTUR_1HZ : process(cpt_p_1HZ)
		begin 
			if (cpt_p_1HZ >= VAL_MAX_COMPTEUR_1HZ) then
				cpt_f_1HZ <= (others => '0');				-- remise à 0 
			else 
				cpt_f_1HZ <= cpt_p_1HZ + 1;  				-- incrémentation 
			end if; 
	end process; 
	
	CMPT_ETAT_FUTUR_2HZ : process(cpt_p_2HZ)
		begin 
			if (cpt_p_2HZ >= VAL_MAX_COMPTEUR_2HZ) then
				cpt_f_2HZ <= (others => '0');				-- remise à 0 
			else 
				cpt_f_2HZ <= cpt_p_2HZ + 1;  				-- incrémentation 
			end if; 
	end process; 
	
	CMPT_ETAT_FUTUR_500HZ : process(cpt_p_500HZ)
		begin 
			if (cpt_p_500HZ >= VAL_MAX_COMPTEUR_500HZ) then
				cpt_f_500HZ <= (others => '0');				-- remise à 0 
			else 
				cpt_f_500HZ <= cpt_p_500HZ + 1;  				-- incrémentation 
			end if; 
	end process; 
	
	CMPT_ETAT_FUTUR_1KHZ : process(cpt_p_1kHZ)
		begin 
			if (cpt_p_1kHZ >= VAL_MAX_COMPTEUR_1KHZ) then
				cpt_f_1kHZ <= (others => '0');				-- remise à 0 
			else 
				cpt_f_1kHZ <= cpt_p_1kHZ + 1;  				-- incrémentation 
			end if; 
	end process; 
		
	-------------------------------------
	-- Horloge rapport cyclique de 50% -- 
	-------------------------------------
	CLK_1HZ_50P : process (CLK_1_8MHZ)
		begin 
			-- synchronisation sur la clock pour éviter des effets -- 
			if rising_edge(CLK_1_8MHZ) then 
				if (cpt_p_1HZ <= VAL_MAX_COMPTEUR_1HZ_DIV2) then 
					clk_1Hz <= '0'; 
				else 
					clk_1Hz <= '1';
				end if; 
			end if; 
	end process; 
	
	CLK_2HZ_50P : process (CLK_1_8MHZ)
		begin
			-- synchronisation sur la clock pour éviter des effets -- 
			if rising_edge(CLK_1_8MHZ) then 
				if (cpt_p_2HZ <= VAL_MAX_COMPTEUR_2HZ_DIV2) then 
					clk_2Hz <= '0'; 
				else 
					clk_2Hz <= '1';
				end if;
			end if;  
	end process; 
	
	CLK_500HZ_50P : process (CLK_1_8MHZ)
		begin
			-- synchronisation sur la clock pour éviter des effets -- 
			if rising_edge(CLK_1_8MHZ) then 
				if (cpt_p_500HZ <= VAL_MAX_COMPTEUR_500HZ_DIV2) then 
					clk_500Hz <= '0'; 
				else 
					clk_500Hz <= '1';
				end if; 
			end if; 
	end process; 
	
	CLK_1KHZ_50P : process (CLK_1_8MHZ)
		begin 
			-- synchronisation sur la clock pour éviter des effets -- 
			if rising_edge(CLK_1_8MHZ) then 
				if (cpt_p_1kHZ <= VAL_MAX_COMPTEUR_1KHZ_DIV2) then 
					clk_1kHz <= '0'; 
				else 
					clk_1kHz <= '1';
				end if;
			end if;  
	end process; 
	
	-------------------------------------
	-- Signaux de sorties - monde reel --
	-------------------------------------
	clk_500Hz_SIM <= clk_500Hz;  
	clk_1KHz_SIM <= clk_1kHz; 
	
	------------------------
	-- choix de la clock  --
	------------------------
	with select_frequence select 
		clk_select_int <= clk_1Hz 	when "00", 
						  clk_2Hz 	when "11",
						  clk_500Hz when "10",
						  clk_1kHz 	when "01",
						  '0'		when others; 

	------------------------------------
	-- Selection des Etat de comptage --
	------------------------------------
	GESTION_ETAT: process (clk_select_int)
		begin
			if rising_edge(clk_select_int) then
				case etat_comptage is 
					-- etat ou on compte ++ -- 
					when "10" => 
						if compteur_indice > 9 then 
							compteur_indice <= 0;
						else 
							compteur_indice <= compteur_indice + 1;
						end if; 
					-- etat ou on décompte -- --
					when "11" => 
						if compteur_indice < 0 then 
							compteur_indice <= 9;
						else 
							compteur_indice <= compteur_indice - 1;
						end if; 
				when others => 
					compteur_indice <= 10; 
				end case; 
			end if;  
	end process; 
	
	-----------------------------
	-- gestion affichage SEG 1 -- 
	-----------------------------
	GESTION_AFFICHAGE: process(compteur_indice)
		begin 
			case compteur_indice is 
				when 0 => SEGMENTS_1 <= "0000001";
				when 1 => SEGMENTS_1 <= "1001111";
				when 2 => SEGMENTS_1 <= "0010010";
				when 3 => SEGMENTS_1 <= "0000110";
				when 4 => SEGMENTS_1 <= "1001100";
				when 5 => SEGMENTS_1 <= "0100100";
				when 6 => SEGMENTS_1 <= "0100000";
				when 7 => SEGMENTS_1 <= "0001111";
				when 8 => SEGMENTS_1 <= "0000000";
				when 9 => SEGMENTS_1 <= "0000100";
				when others => SEGMENTS_1 <= "1111110"; 
			end case; 
	end process; 



--with compteur_indice select 
--					 ABCDEFG--
--		SEGMENTS_1 <= "0000001" when 0,		-- 0
--					  "1001111" when 1,		
--					  "0010010" when 2,        
--					  "0000110" when 3,
--					  "1001100" when 4,
--					  "0100100" when 5,
--					  "0100000" when 6,
--					  "0001111" when 7,
--					  "0000000" when 8,
--					  "0000100" when 9,	
--					  "1111110" when others;  -- '-'

end COMP_COMPTEUR; 

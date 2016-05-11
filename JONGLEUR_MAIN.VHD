-----------------------------------------------------------------------------------//
-- Nom du projet 		    : TEST2
-- Nom du fichier 		    : JONGLEUR_MAIN.vhd
-- Date de création 	    : 13.04.2016
-- Date de modification     : xx.xx.2016
--
-- Auteur 				    : Ph. Bovey
--
-- Description              : Simuler un jongleur avec la carte de l'ETML 
--
-- Remarques 			    :  
----------------------------------------------------------------------------------//
-- déclaration standart des librairies standart pour le VHDL --
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

-- déclaration de l'entité (Entrées / Sorties) --
entity jongleur is
	port(
		-- entree -- 
		NRST 			: in std_logic;  
		CLK 			: in std_logic; 
		SW_10, SW_11	: in std_logic; 
		
		-- sortie --
		SEG1 : out std_logic_vector(6 downto 0); 
		SEG2 : out std_logic_vector(6 downto 0); 
		
		P_SEG1, P_SEG2 : out std_logic
		--TEST1 : out std_logic; 
		--TEST2 : out std_logic
	); 
end jongleur; 


architecture comportement_jongleur_main of jongleur is
	------------------------------
	-- déclaration de constante --
	------------------------------
	constant VAL_MAX_CMPT_1MS : integer := 1843;  	-- t_fpga = 1/f_fpga => on veut 1ms : t_1ms = 1ms/(1/f_fgpa) = 1ms/(1/1.8432MHz)
	constant VAL_MAX_CMPT_1S  : integer := 1000;    -- t_1s / t_1ms  = 1000 valeur vrai -> 10 pour 10ms -> valeur de démo  
	constant SEG_ETAT		  : integer := 6; 		-- représente la valeur max des etat des segments 
	
	-----------------------------
	-- déclaration de variable --
	-----------------------------
	-- type entier --
	signal compteur_1ms  : integer range 0 to (VAL_MAX_CMPT_1MS + 1) := 0;   	-- 
	signal compteur_1s	 : integer range 0 to VAL_MAX_CMPT_1S := 0; 			-- 
	signal compteur_seg	 : integer range 0 to SEG_ETAT := 0;					--      
	
	-- type logique --
	signal clock_int_1ms : std_logic; 
	signal clock_int_1s :  std_logic;
	signal etat_switch :   std_logic_vector(1 downto 0); 
	
	
	begin 
	------------------------------
	-- compteur 1ms - autonome  --
	------------------------------
	compt_1ms : process(CLK)
		begin
			-- événement sur la clock -> front montant -- 
			if(CLK'event) and (CLK = '1') then
				if(compteur_1ms <= VAL_MAX_CMPT_1MS -1) then 
					compteur_1ms <=  compteur_1ms + 1; 
				else 
					compteur_1ms <= 0;
					if compteur_1s <= (VAL_MAX_CMPT_1S - 1) then 
						compteur_1s <= compteur_1s + 1; 
					else 
						compteur_1s <= 0; 
					end if;  
				end if;  
			end if;  
	end process; 

	---------------------------------------------------------
	-- assignation d'un signal pour la clock de 1ms => 50% --
	---------------------------------------------------------
	clock_int_1ms <= '1' when compteur_1ms <= (VAL_MAX_CMPT_1MS/2) else 
					 '0'; 
	--TEST1 <= clock_int_1ms;  

	---------------------------------------------------------
	-- assignation d'un signal pour la clock de 1s => 50% --
	---------------------------------------------------------
	clock_int_1s <= '1' when compteur_1s <= (VAL_MAX_CMPT_1S/2) else 
					 '0'; 
	
	P_SEG1 <= '1' when clock_int_1s = '0' else 
	          '0';
	P_SEG2 <= '0' when clock_int_1s = '0' else 
	          '1';
	--TEST2 <= clock_int_1s;  
	
	
	----------------------------------------
	-- récuperation des etat des swicthes --
	----------------------------------------
	etat_switch <= (SW_11, SW_10); 
	
	---------------------------
	-- compteur etat segment --
	---------------------------
	process(clock_int_1s, etat_switch)
		begin 
			-- événement sur la clock -> front montant -- 
			if(clock_int_1s'event) and (clock_int_1s = '1') then
				if etat_switch = "01" then 
					if(compteur_seg >= 6) then
						compteur_seg <= 1;
					else 
						compteur_seg <= compteur_seg + 1; 
					end if;
				elsif etat_switch = "10" then 
					if(compteur_seg < 2) then
						compteur_seg <= 6;
					else 
						compteur_seg <= compteur_seg - 1;
					end if;  
				elsif etat_switch = "00" then
					compteur_seg <= 0;
				end if;  
			end if;
	end process;
	
	---------------------------------------------------------
	-- assignation du segment 1 --
	---------------------------------------------------------
	with compteur_seg select 
		     -- GFEDCBA--
		SEG1 <="0111111" when 0,
			   "1101111" when 1,
			   "1011111" when 2,
			   "1111110" when 3,
			   "1111111" when others;
	
	with compteur_seg select 
		     -- GFEDCBA--
		SEG2 <="1111110" when 4,
			   "1111101" when 5,
			   "1111011" when 6,
			   "0111111" when 0,
			   "1111111" when others; 
			   
end comportement_jongleur_main; 
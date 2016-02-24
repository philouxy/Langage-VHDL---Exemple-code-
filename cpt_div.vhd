-----------------------------------------------------------------------------------//
-- Nom du projet 		    : COMPTEUR_DIVISEUR
-- Nom du fichier 		    : cpt_div.vhd
-- Date de création 	    : 19.02.2016
-- Date de modification     : 24.02.2016
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
entity CPT_DIV is
	port(
		-- entrée -- 
		--SW_X : in std_logic; 
		nRST 	 : in std_logic; 
		CLK_IN	 : in std_logic; 
		
		-- sortie -- 
		CLK_OUT_1A : out std_logic;
		CLK_OUT_2A : out std_logic;
		CLK_OUT_3A : out std_logic; 
		
		CLK_OUT_1B : out std_logic;
		CLK_OUT_2B : out std_logic;
		CLK_OUT_3B : out std_logic
	);
END CPT_DIV;


architecture COMPORTEMENT_CPT of CPT_DIV is
	-- déclaration de signaux, variables, etc -- 
	-- constante --
	constant MAX_CMPT_2 : integer :=2;
	constant MAX_CMPT_4 : integer :=4;
	constant MAX_CMPT_8 : integer :=8;
	
	-- composant -- 
	component DIV_2
		port(
			-- entrée -- 
			CLK_IN	: in std_logic; 
			
			-- sortie --
			CLK_OUT : out std_logic
		); 
	end component;
	
	component DIV_4
		port(
			-- entrée -- 
			CLK_IN	: in std_logic; 
			
			-- sortie --
			CLK_OUT : out std_logic
		); 
	end component; 
	
	component DIV_8
		port(
			-- entrée -- 
			CLK_IN	: in std_logic; 
			
			-- sortie --
			CLK_OUT : out std_logic
		); 
	end component;  
	
	-- variable -- 
	signal CLK_INT_1A : std_logic; 
	signal CLK_INT_2A : std_logic;
	--signal 
	
	begin
	-------------------------------------
	-- instanciation du composant DIV2 --  
	-------------------------------------
	BLOC_DIV2_1 : DIV_2 port map (CLK_IN => CLK_IN,     CLK_OUT => CLK_INT_1A);
    BLOC_DIV2_2 : DIV_2 port map (CLK_IN => CLK_INT_1A, CLK_OUT => CLK_INT_2A);
    BLOC_DIV2_3 : DIV_2 port map (CLK_IN => CLK_INT_2A, CLK_OUT => CLK_OUT_3A);
    
    -------------------------------------
	-- instanciation du composant DIV4 --  
	-------------------------------------
    BLOC_DIV4 : DIV_4 port map (CLK_IN => CLK_IN, CLK_OUT => CLK_OUT_2B);
   
	-------------------------------------
	-- instanciation du composant DIV8 --  
	------------------------------------- 
    BLOC_DIV8 : DIV_8 port map (CLK_IN => CLK_IN, CLK_OUT => CLK_OUT_3B); 
    
    -----------------------------
	-- assignation des sorties --  
	-----------------------------
    CLK_OUT_1A <= CLK_INT_1A; 
    CLK_OUT_2A <= CLK_INT_2A;
	--CLK_OUT_3A <= CLK_INT_2;
	
end COMPORTEMENT_CPT; 
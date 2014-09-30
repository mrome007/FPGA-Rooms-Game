--    Partners Names & E-mail: Michael Romero mrome007@ucr.edu Ricardo Sanchez rsanc012@ucr.edu
--    Lab Section: 022
--    Assignment: Lab #8  Exercise #2
--    Exercise Description: VGA
--
--    I acknowledge all content contained herein, excluding template or example
--    code, is my own original work.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity vga_controller is
    Port ( 
			  clk50MHz_i 	: in 	STD_LOGIC;
			  rst_i 			: in 	STD_LOGIC;
			  hsync 			: out	STD_LOGIC;
           vsync 			: out STD_LOGIC;
			  hcount      	: out STD_LOGIC_VECTOR(10 downto 0);
			  vcount      	: out STD_LOGIC_VECTOR(10 downto 0)
			  );
end vga_controller;

architecture Behavioral of vga_controller is
	
--	component clk_div is
--	Port (
--				rst_i 		: in 	STD_LOGIC;
--				clk50MHz_i 	: in 	STD_LOGIC;
--				clk25MHz_o 	: out STD_LOGIC );
--	end component;
	

--	signal clkdiv : STD_LOGIC;
	signal hcounter, vcounter : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
	
begin	
--	d:clk_div port map(rst_i,clk50MHz_i, clkdiv);

	
	--HORIZONTAL COUNTER	
	process(clk50MHz_i)
		begin
			if clk50MHz_i'event and clk50MHz_i = '1' then
				if rst_i = '1' then
					hcounter <= (others => '0');
					--rgb <= (others => '0');
				elsif hcounter = 800 then
					hcounter <= (others => '0');
				else
					hcounter <= hcounter + 1;
				end if;
			end if;
		end process;
		
	--VERTICAL COUNTER
		process(clk50MHz_i)
			begin
				if clk50MHz_i'event and clk50MHz_i = '1' then 
					if rst_i = '1' then
						vcounter <= (others => '0');
						--rgb <= (others => '0');
					elsif hcounter = 800 then
						if vcounter = 524 then
							vcounter <= (others => '0');
						else
							vcounter <= vcounter + 1;
						end if;
					end if;	
				end if;
			end process;
	
	--Hsync
		process(clk50MHz_i)
			begin
				if clk50MHz_i'event and clk50MHz_i = '1' then
					if hcounter >= 656 and hcounter < 752 then
						hsync <= '0';
					else
						hsync <= '1';
					end if;
				end if;
			end process;
			
	--Vsync
		process(clk50MHz_i)
			begin
				if clk50MHz_i'event and clk50MHz_i = '1' then
					if vcounter >= 491 and vcounter < 494 then
						vsync <= '0';
					else
						vsync <= '1';
					end if;
				end if;
			end process;
	

    hcount <= hcounter;
    vcount <= vcounter;
	 
	 

		
		
end Behavioral;
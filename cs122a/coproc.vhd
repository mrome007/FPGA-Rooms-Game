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

entity coproc is
	Port(
			fire		: 	in		std_logic;
			clk				: 	in		std_logic;
			rst				:	in 	std_logic;
			up_button		:	in 	std_logic;
			down_button		:	in 	std_logic;
			left_button		:	in 	std_logic;
			right_button	:	in 	std_logic;
			hs		 			: 	out	STD_LOGIC;
         vs 				: 	out 	STD_LOGIC;
			rgb_o				:	out	std_logic_vector(7 downto 0);
			room0		: 	out 	std_logic;
				room1		: 	out 	std_logic;
				room2		: 	out 	std_logic;
				room3		: 	out 	std_logic;
				enmylife :  out	std_logic_vector(1 downto 0);
				plyrlife	: 	out 	std_logic_vector(2 downto 0)
				
			);
end coproc;

architecture Behavioral of coproc is
	component clk_div is
	Port (
				rst_i 		: in 	STD_LOGIC;
				clk50MHz_i 	: in 	STD_LOGIC;
				clk25MHz_o 	: out STD_LOGIC );
	end component;
	
	signal clkdiv : STD_LOGIC;

	component vga_controller is
    Port ( 
			  clk50MHz_i 	: in 	STD_LOGIC;
			  rst_i 			: in 	STD_LOGIC;
			  hsync 			: out	STD_LOGIC;
           vsync 			: out STD_LOGIC;
			  hcount      	: out STD_LOGIC_VECTOR(10 downto 0);
			  vcount      	: out STD_LOGIC_VECTOR(10 downto 0)
			  );
	end component;
	
	signal hc, vc : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
	signal rooms : std_logic_vector(3 downto 0);
	component game_view is
	Port	(
				fire		: 	in		std_logic;
				clk		: 	in		std_logic;
				rst		:	in 	std_logic;
				up			:	in 	std_logic;
				down		:	in 	std_logic;
				left		:	in 	std_logic;
				right		:	in 	std_logic;
				xpos		: 	in 	std_logic_vector(10 downto 0);
				ypos		: 	in 	std_logic_vector(10 downto 0);
				rgbOut	:	out	std_logic_vector(7 downto 0);
				room		: 	out 	std_logic_vector(3 downto 0);
				enmylife :  out	std_logic_vector(1 downto 0);
				plyrlife	: 	out 	std_logic_vector(2 downto 0)
				
				
	);
	end component;
	

begin
	
	cd	: entity work.clk_div port map(
			rst_i => rst,
			clk50MHz_i => clk,
			clk25MHz_o => clkdiv
	);
	
	vg	: entity work.vga_controller port map(
			clk50MHz_i => clkdiv,
			rst_i	=> rst,
			hsync => hs,
			vsync	=> vs,
			hcount => hc,
			vcount => vc
	);

	gv : entity work.game_view port map(
			fire => fire,
			clk => clkdiv,
			rst => rst,
			up => up_button,
			down => down_button,
			left => left_button,
			right => right_button,
			xpos => hc,
			ypos => vc,
			rgbOut => rgb_o,		
			room => rooms,
			enmylife => enmylife,
			plyrlife => plyrlife
	);
	
	process(rooms)
		begin
			if rooms = "0001" then
				room0	<= '1';
				room1	<= '0';
				room2	<= '0';
				room3	<= '0';
			elsif rooms = "0010" then
				room0	<= '0';
				room1	<= '1';
				room2	<= '0';
				room3	<= '0';
			elsif rooms = "0011" then
				room0	<= '1';
				room1	<= '1';
				room2	<= '0';
				room3	<= '0';
			elsif rooms = "0100" then
				room0	<= '0';
				room1	<= '0';
				room2	<= '1';
				room3	<= '0';
			else
				room0	<= '0';
				room1	<= '0';
				room2	<= '0';
				room3	<= '0';
			end if;		
		end process;
end Behavioral;


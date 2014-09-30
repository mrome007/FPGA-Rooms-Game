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


entity game_view is
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
end game_view;	

architecture Behavioral of game_view is

COMPONENT megamanBram
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

COMPONENT turtle
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

signal xpos1, ypos1 : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
signal xpos2 : STD_LOGIC_VECTOR(10 downto 0) := "00011001000";
signal ypos2 : STD_LOGIC_VECTOR(10 downto 0) := "00001100100";
signal button_clk : std_logic;
signal button_clk1 : std_logic;
signal dout : STD_LOGIC_VECTOR (7 downto 0);	
signal addrCounter : STD_LOGIC_VECTOR (11 downto 0) := "000000000000";	
signal addrCounterT : STD_LOGIC_VECTOR (11 downto 0) := "000000000000";	
signal doutT : STD_LOGIC_VECTOR (7 downto 0);
signal xpos1T, ypos1T : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
signal xpos2T : STD_LOGIC_VECTOR(10 downto 0) := "00001100100";
signal ypos2T : STD_LOGIC_VECTOR(10 downto 0) := "00001100100";
signal rooms : std_logic_vector(3 downto 0) := "0000";
signal enemylife : std_logic_vector(1 downto 0) := "11";
signal playerlife : std_logic_vector(2 downto 0) := "111";


signal win	: std_logic := '0';
signal lose : std_logic := '0';
begin

		mmB : megamanBram port map(
				clka => clk,
				addra => addrCounter,
				douta => dout
		);
		
		trt : turtle port map(
				clka => clk,
				addra => addrCounterT,
				douta => doutT
		);
		
		xpos1 <= xpos2 - 65;
		ypos1 <= ypos2 - 49;
		
		xpos1T <= xpos2T - 51;
		ypos1T <= ypos2T - 51;	
		
		
		--output box
		
		
		process(clk, fire, enemylife)
			TYPE states is (init, buttonPress, buttonRelease);
			Variable state : states := init;
			begin
				if clk = '1' and clk'event then
					if rst = '1' then
						enemylife <= "00";
					else
						if rooms = "0011" then
						Case state is
							when init =>
								if fire = '1' then
									state := buttonPress;
								else
									state := init;
								end if;
							when buttonPress =>
								if fire = '0' then
									state := buttonRelease;
								else
									state := buttonPress;
								end if;
							when buttonRelease =>
								state := init;
						end CASE;
						CASE state is
							when init =>
								enmylife <= enemylife;
								win <= '0';
							when buttonPress =>
							when buttonRelease =>
							if enemylife = "00" then
									enemylife <= "11";
									win <= '1';
							else		
								enemylife <= enemylife - 1;
								end if;	
						end CASE;		
						end if;
						end if;
					end if;	
			end process;
		
		process(clk, rst, addrCounter, xpos, ypos, xpos1, xpos2, ypos1, ypos2, dout, addrCounterT, doutT, win, lose)
			TYPE states is (firstRoom, secondRoom, thirdRoom, fourthRoom);
			Variable state : states := firstRoom;
			
				begin
					if clk = '1' and clk'event then
						if rst = '1' then
							rgbOut <= "00000000";
							rooms <= "0000";
						else
							CASE state is
								when firstRoom =>
									if xpos2 < 129 and ypos2 < 50  then
										state := secondRoom;
									elsif xpos1 > 256 and xpos2 < 385 and ypos1 > 400 and ypos2 < 480 then
										state := thirdRoom;
									elsif xpos1 > 570 and xpos2 < 640 and ypos1 > 176 and ypos2 < 305 then 
										state := fourthRoom;
									else
										state := firstRoom;
									end if;
								when secondRoom =>
									if ypos1 > 400 and ypos2 < 480 and xpos2 < 129 then
										state := firstRoom;
									else
										state := secondRoom;
									end if;
								when thirdRoom =>
									if ypos2 < 50 and xpos1 > 256 and xpos2 < 385 then
										state := firstRoom;
									elsif win = '1' then
										state := firstRoom;
									elsif lose = '1' then
										state := firstRoom;
									else
										state := thirdRoom;
									end if;	
								when fourthRoom =>
									if ypos1 > 176 and ypos2 < 305 and xpos2 < 66 then
										state := firstRoom;
									else
										state := fourthRoom;
									end if;	
								when others =>
									state := firstRoom;
							end CASE;
							CASE state is
								when firstRoom =>
									rooms <= "0001";
									if xpos > xpos1 and xpos < xpos2 and ypos > ypos1 and ypos < ypos2 then
										if addrCounter < 3072 then
										rgbOut <= dout;
										addrCounter <= addrCounter + 1;
									else
										addrCounter <= "000000000000";
										rgbOut <= dout;
									end if;
									elsif ypos = ypos2 then
										addrCounter <= "000000000000";
					
									else	
										if (xpos < 129 and ypos > 0 and ypos < 49) or (xpos > 256 and xpos < 385 and ypos > 431 and ypos < 480) or (ypos > 176 and ypos < 305 and xpos > 575 and xpos < 640) then
											rgbOut <= "00000011";
										else
											rgbOut <= "00000000";
										end if;
										
									end if;
									
								when secondRoom =>
									if xpos > xpos1 and xpos < xpos2 and ypos > ypos1 and ypos < ypos2 then
										if addrCounter < 3072 then
										rgbOut <= dout;
										addrCounter <= addrCounter + 1;
									else
										addrCounter <= "000000000000";
										rgbOut <= dout;
									end if;
									elsif ypos = ypos2 then
										addrCounter <= "000000000000";
					
									else	
										if (xpos > 0 and xpos < 129 and ypos > 431 and ypos < 480) then
											rgbOut <= "00000011";
										else
											rgbOut <= "00000000";
										end if;
									end if;
									rooms <= "0010";
								when thirdRoom =>
									if xpos > xpos1 and xpos < xpos2 and ypos > ypos1 and ypos < ypos2 then
										if addrCounter < 3072 then
										rgbOut <= dout;
										addrCounter <= addrCounter + 1;
									else
										addrCounter <= "000000000000";
										rgbOut <= dout;
									end if;
									elsif ypos = ypos2 then
										addrCounter <= "000000000000";
					
									else	
										if xpos > xpos1T and xpos < xpos2T and ypos > ypos1T and ypos < ypos2T then
											if addrCounterT < 2500 then
												rgbOut <= doutT;
												addrCounterT <= addrCounterT + 1;
											else
												addrCounterT <= "000000000000";
												rgbOut <= doutT;
											end if;
										elsif ypos = 450 then
											addrCounterT <= "000000000000";
											
										elsif (xpos > 256 and xpos < 385 and ypos < 50) then
											rgbOut <= "00000011";
										else
											rgbOut <= "00000000";
										end if;
									end if;
									rooms <= "0011";
								when fourthRoom =>
									if xpos > xpos1 and xpos < xpos2 and ypos > ypos1 and ypos < ypos2 then
										if addrCounter < 3072 then
										rgbOut <= dout;
										addrCounter <= addrCounter + 1;
									else
										addrCounter <= "000000000000";
										rgbOut <= dout;
									end if;
									elsif ypos = ypos2 then
										addrCounter <= "000000000000";
					
									else	
										if (xpos < 65 and ypos > 176 and ypos < 305) then
											rgbOut <= "00000011";
										else
											rgbOut <= "00000000";
										end if;
									end if;	
									rooms <= "0100";	
							end CASE;		
						end if;			
					end if;	
				end process;


		process(clk)
			VARIABLE cnt: INTEGER := 0;
				begin
					if clk = '1' and clk'event then
						if rst = '1' then
							cnt := 0;
						else
							cnt := cnt + 1;
							if cnt = 80000 then
								button_clk <= '1';
								cnt := 0;
							else
								button_clk <= '0';
							end if;	
						end if;
					end if;
				end process;
		
		
		--go left and up
		process(button_clk, up, left, down, right, ypos2, xpos2)
			begin
				if button_clk = '1' and button_clk'event then
					if rst = '1' then
					else	
						if up = '1' then 
							if ypos2 < 50 then
									
							else
								ypos2 <= ypos2 - 1;
							end if;
						elsif left = '1' then	
							if xpos2 < 66 then
							
							else
								xpos2 <= xpos2 - 1;
							end if;
						elsif down = '1' then	
							if xpos2 = 640 then
							
							else
								xpos2 <= xpos2 + 1;
							end if;	
						elsif right = '1' then	
							if ypos2 = 480 then
							
							else
								ypos2 <= ypos2 + 1;
							end if;		
						end if;	
					end if;
				 end if;
			end process;
			
			
		
		process(button_clk, ypos2T, xpos2T, rooms)
			begin
				if button_clk = '1' and button_clk'event then
					if rooms = "0011" then
						ypos2T <= ypos2T + 1;
						if ypos2T = 400 then
							ypos2T <= "00001100100";
							xpos2T <= xpos2T + 50;
							if xpos2T = 500 then
								xpos2T <= "00001100100";
							else	
							end if;
						end if;
					end if;
				end if;		
			end process;
			
			
			process(button_clk)
			VARIABLE cnt: INTEGER := 0;
				begin
					if button_clk = '1' and button_clk'event then
						if rst = '1' then
							cnt := 0;
						else
							cnt := cnt + 1;
							if cnt = 500 then
								button_clk1 <= '1';
								cnt := 0;
							else
								button_clk1 <= '0';
							end if;	
						end if;
					end if;
				end process;
		
		process(button_clk1, playerlife)
			TYPE states is (initAtk, attacked);
			Variable state : states := initAtk;
			begin
				if button_clk1 = '1' and button_clk1'event then
					if rst = '1' then
						playerlife <= "000";
					else
							CASE state is
								WHEN initAtk =>
								if rooms = "0011" then
									state := attacked;
								else
									state := initAtk;
								end if;	
								WHEN attacked =>
								if rooms = "0011" then
									state := attacked;
								else
									state := initAtk;
								end if;	
							end CASE;
							CASE state is
								WHEN initAtk =>
									plyrlife <= playerlife;
									lose <= '0';
								WHEN attacked =>
									
										if playerlife = "000" then
											lose <= '1';
											playerlife <= "111";
										else
											lose <= '0';
											playerlife <= playerlife - 1;
											
										end if;	
									plyrlife <= playerlife;
							end CASE;
						
					end if;
				end if;	
			end process;
			
		room <= rooms;
		
end Behavioral;
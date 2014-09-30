--    Partners Names & E-mail: Michael Romero mrome007@ucr.edu Ricardo Sanchez rsanc012@ucr.edu
--    Lab Section: 022
--    Assignment: Lab #8  Exercise #1
--    Exercise Description: VGA
--
--    I acknowledge all content contained herein, excluding template or example
--    code, is my own original work.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clk_div is
Port (
  rst_i : in STD_LOGIC;
  clk50MHz_i : in STD_LOGIC;
  clk25MHz_o : out STD_LOGIC );
end clk_div;


architecture Behavioral of clk_div is

signal sig_clk_25MHz : STD_LOGIC := '0';

begin

process(rst_i, clk50MHz_i)

begin

  if rst_i = '1' then
    sig_clk_25MHz <= '0';

  elsif rising_edge(clk50MHz_i) then
    sig_clk_25MHz <= NOT(sig_clk_25MHz);

end if;

end process;

clk25MHz_o <= sig_clk_25MHz;


end Behavioral;



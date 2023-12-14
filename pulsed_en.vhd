-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    7:20:00 12/14/2023
-- Design Name:    Pulsed Enable
-- Module Name:    pulsed_en - enpls
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                Pulsed enable for slowing seven-segment display multiplexing and debouncing buttons.
--!                Goal is to debounce at ~100Hz, and multiplex sseg displays at ~500hz.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Pulsed Enable
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pulsed_en is
  port
  (
    clk                : in std_logic; --! Clock
    en_slow, en_medium : out std_logic --! Different pulsed enables
  );
end pulsed_en;

architecture enpls of pulsed_en is
  signal medium_count_reg : unsigned(15 downto 0); -- to get down to 100Hz from 50MHz need to count to
  signal slow_count_reg   : unsigned(2 downto 0);
begin
  -- counter
  process (clk)
  begin
    if rising_edge(clk) then
      medium_count_reg <= medium_count_reg + 1;
      if medium_count_reg = 0 then
        slow_count_reg <= slow_count_reg + 1;
      end if;
    end if;
  end process;

  -- pulses
  en_medium <= '1' when medium_count_reg = 0 else
    '0';
  en_slow <= '1' when medium_count_reg = 0 and slow_count_reg = 0 else
    '0';
end enpls;
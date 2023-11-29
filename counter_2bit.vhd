-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    15:50:00 11/28/2023
-- Design Name:    2-Bit Counter
-- Module Name:    counter_2bit - counter
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                2-Bit Counter used for Seven-Segment Multiplexing.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- 2-Bit Counter
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter_2bit is
  port
  (
    clk   : in std_logic; --! Clock
    count : out std_logic_vector(1 downto 0) --! Counter Value
  );
end counter_2bit;

architecture counter of counter_2bit is
  signal count_buf : unsigned(1 downto 0);
begin
  process (clk)
  begin
    if rising_edge(clk) then
      count_buf <= count_buf + 1;
    end if;
  end process;
  count <= std_logic_vector(count_buf);
end counter;
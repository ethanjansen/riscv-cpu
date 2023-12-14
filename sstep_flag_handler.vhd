-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    22:10:00 12/13/2023
-- Design Name:    SSTEP Flag Handler
-- Module Name:    sstep_flag_handler - flag
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                keeps a value of SSTEP in memory for performing single step accross states.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- SSTEP Flag Handler
library IEEE;
use IEEE.std_logic_1164.all;

entity sstep_flag_handler is
  port
  (
    clk   : in std_logic; --! Clock
    clear : in std_logic; --! Sets val to 0
    set   : in std_logic; --! Sets val to 1
    val   : out std_logic --! output value
  );
end sstep_flag_handler;

architecture flag of sstep_flag_handler is

begin
  process (clk)
  begin
    if rising_edge(clk) then
      if set = '1' then
        val <= '1';
      elsif clear = '1' then
        val <= '0';
      end if;
    end if;
  end process;
end flag;
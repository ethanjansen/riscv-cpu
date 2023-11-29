-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    23:30:00 11/28/2023
-- Design Name:    Accumulator
-- Module Name:    accumulator - a
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                32-bit Accumulator Regsiter for use in DPU. Always write enabled.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Data Path Unit
library IEEE;
use ieee.std_logic_1164.all;

entity accumulator is
  port
  (
    clk : in std_logic; --! Clock
    d   : in std_logic_vector(31 downto 0); --! Data In
    q   : out std_logic_vector(31 downto 0) --! Data Out
  );
end accumulator;

architecture a of accumulator is
begin
  mem : process (clk)
  begin
    if rising_edge(clk) then
      q <= d;
    end if;
  end process;
end a;
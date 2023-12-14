-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    15:30:00 11/28/2023
-- Design Name:    Flag Handler
-- Module Name:    flag_handler - flags
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                Handles flags from value in Accumulator.
--!                "00"=eq 0, "01"=lt 0, "10"=gt 0, "11"=neq 0.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Flag Handler
library IEEE;
use IEEE.std_logic_1164.all;

entity flag_handler is
  port
  (
    a_in     : in std_logic_vector(31 downto 0); --! Accumulator data in
    flag_out : out std_logic_vector(1 downto 0) --! Flag out (high bit if positive, low bit if negative)
  );
end flag_handler;

architecture flags of flag_handler is

begin
  flag_out(1) <= '1' when (a_in(31) = '0' and a_in(30 downto 0) /= "0000000000000000000000000000000") else
  '0';
  flag_out(0) <= '1' when a_in(31) = '1' else
  '0';
end flags;
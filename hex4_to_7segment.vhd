-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    15:50:00 11/28/2023
-- Design Name:    Hex to Seven-Segment LUT
-- Module Name:    hex4_to_7segment - lut_7segment
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                LUT for 4-bit hex to 8-bit sseg translation.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- HEX TO 7-SEGMENT (8 including decimal)
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity hex4_to_7segment is
  port
  (
    hex : in std_logic_vector(3 downto 0); --! 4-bit hex input
    seg : out std_logic_vector(7 downto 0) --! 8-bit sseg output
  );
end hex4_to_7segment;

architecture lut_7segment of hex4_to_7segment is
begin
  -- mapping 0-F in binary to segments on display
  with hex select
    seg <= "11000000" when X"0",
    "11111001" when X"1",
    "10100100" when X"2",
    "10110000" when X"3",
    "10011001" when X"4",
    "10010010" when X"5",
    "10000010" when X"6",
    "11111000" when X"7",
    "10000000" when X"8",
    "10011000" when X"9",
    "10001000" when X"A",
    "10000011" when X"B",
    "10100111" when X"C",
    "10100001" when X"D",
    "10000110" when X"E",
    "10001110" when others; --X"F"
end lut_7segment;
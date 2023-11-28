-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    16:00:00 11/14/2023
-- Design Name:    Processor
-- Module Name:    top_sch_proj - main
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    Accumulator based microprocessor design
--
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- MAIN
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity top_sch_proj is
  port
  (
    clk   : in std_logic;
    btn   : in std_logic_vector(2 downto 0);
    sw    : in std_logic_vector(7 downto 0);
    led   : out std_logic_vector(15 downto 0);
    cath  : out std_logic_vector(7 downto 0); -- seven-seg display (muxing done outside of processor)
    anode : out std_logic_vector(4 downto 0)
  );
end top_sch_proj;

architecture main of top_sch_proj is
begin
end main;
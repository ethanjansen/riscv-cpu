-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    15:50:00 11/28/2023
-- Design Name:    Seven-Segment Display Handler
-- Module Name:    sseg_handler - sseg
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                Seven-Segment Display Logic with multiplexing, and with memory for holding output.
--                 1-bit select for ('1') high bytes or ('0') low bytes.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Seven-Segment Display Handler
library IEEE;
use IEEE.std_logic_1164.all;

entity sseg_handler is
  port
  (
    clk         : in std_logic; --! Clock
    we          : in std_logic; --! Write Enable
    sel         : in std_logic; --! 1-bit Select for ('1') high bytes or ('0') low bytes.
    data_in     : in std_logic_vector(31 downto 0); --! Data Input
    anode_out   : out std_logic_vector(4 downto 0); --! Anode Output
    cathode_out : out std_logic_vector(7 downto 0) --! Cathode Output
  );
end sseg_handler;

architecture sseg of sseg_handler is

begin

end sseg;
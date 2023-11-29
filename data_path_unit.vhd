-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    14:40:00 11/28/2023
-- Design Name:    Data Path Unit
-- Module Name:    data_path_unit - dpu
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                DPU for CPU Project. Consists of Regiser memory, ALU, Accumulator, Seven-Segment Display Logic, Flag Handler, and I/O Muxes.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Data Path Unit
library IEEE;
use IEEE.std_logic_1164.all;

entity data_path_unit is
  port
  (
    clk              : in std_logic; --! Clock
    data_or_addr_in  : in std_logic_vector(9 downto 0); --! Data or Address in from Controller
    flags            : out std_logic_vector(1 downto 0); --! Flags based on A (1=>"gt 0", 0=>"lt 0")
    led_out          : out std_logic_vector(15 downto 0); --! LED Output
    sseg_anode_out   : out std_logic_vector(4 downto 0); --! Seven-Segment Display Anode Output (time multiplexed)
    sseg_cathode_out : out std_logic_vector(7 downto 0) --! Seven-Segment Display Cathode Output (time multiplexed)
  );
end data_path_unit;

architecture dpu of data_path_unit is

begin

end dpu;
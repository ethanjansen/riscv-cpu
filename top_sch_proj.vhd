--! {reg: [
--!   {"bits": 10, "name": "Data", "attr": ["address", "immediate", "offset"]},
--!   {"bits": 1, "name": "Immediate"},
--!   {"bits": 2, "name": "general"},
--!   {"bits": 3, "name": "Function", "attr": ["load", "add", "shift left", "shift right", "and", "or", "xor", "branch", "wait", "seven-segment", "led"]},
--!   {"bits": 2, "name": "Operation", "attr": ["ALU", "store", "PC", "Display"] }
--! ]}

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
    mclk  : in std_logic; --! Master Clock
    btn   : in std_logic_vector(2 downto 0); --! Push Buttons (0=>reset, 1=>contiue, 2=>sstep)
    sw    : in std_logic_vector(7 downto 0); --! Toggle Switches
    sw8   : in std_logic; --! Toggle Switch 8 (toggles high/low byte display on led and sseg)
    led   : out std_logic_vector(15 downto 0); --! LEDs
    cath  : out std_logic_vector(7 downto 0); --! Seven-Segment Display Cathode
    anode : out std_logic_vector(4 downto 0) --! Seven-Segment Display Anode
  );
end top_sch_proj;

architecture main of top_sch_proj is
  component data_path_unit is
    port
    (
      clk              : in std_logic; --! Clock
      ctrl             : in std_logic_vector(7 downto 0); --! Control Signal from DPU
      data_or_addr_in  : in std_logic_vector(9 downto 0); --! Data or Address in from Controller
      sw_in            : in std_logic_vector(7 downto 0); --! Data in from Switch
      high_low_sw      : in std_logic; --! High/Low Display Select from sw8
      flags            : out std_logic_vector(1 downto 0); --! Flags based on A (1=>"gt 0", 0=>"lt 0")
      led_out          : out std_logic_vector(15 downto 0); --! LED Output
      sseg_anode_out   : out std_logic_vector(4 downto 0); --! Seven-Segment Display Anode Output (time multiplexed)
      sseg_cathode_out : out std_logic_vector(7 downto 0) --! Seven-Segment Display Cathode Output (time multiplexed)
    );
  end component;
begin
  -- clk will become derived clock rather than mclk in the future.
  -- Constant inputs for testing. Will be mapped to controller.
  -- flags will be mapped to controller
  dpu : data_path_unit port map
  (
    clk => mclk, ctrl => X"00", data_or_addr_in => "0000000000", sw_in => sw, high_low_sw => sw8,
    flags => open, led_out => led, sseg_anode_out => anode, sseg_cathode_out => cath);
end main;
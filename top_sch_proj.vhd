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
  signal inversebtns : std_logic_vector(2 downto 0);

  signal clk : std_logic; --! Used with slowclock

  signal sig_alu_flags : std_logic_vector(1 downto 0); --! From DPU ALU Flags to Controller FSM
  signal sig_ctrl      : std_logic_vector(7 downto 0); --! From Controller FSM to DPU
  signal sig_d_addr    : std_logic_vector(9 downto 0); --! From Controller FSM to DPU

  component slow_clock is
    generic
      (clk_div_half : integer := 499);
    port
    (
      mclk   : in std_logic;
      slwclk : out std_logic
    );
  end component;

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

  component controller is
    port
    (
      clk        : in std_logic; --! Clock
      ctrl_btns  : in std_logic_vector(2 downto 0); --! Buttons for reset (0), continue (1), and sstep (2)
      alu_flags  : in std_logic_vector(1 downto 0); --! Flags from ALU
      d_addr_out : out std_logic_vector(9 downto 0); --! Data and Addr out for DPU
      ctrl       : out std_logic_vector(7 downto 0) --! Control signals from PMEM for DPU
    );
  end component;
begin
  inversebtns <= not btn;

  clock : slow_clock generic
  map (clk_div_half => 24999999) port map
  (mclk => mclk, slwclk => clk);
  ctrlr : controller port
  map(clk => clk, ctrl_btns => inversebtns, alu_flags => sig_alu_flags, d_addr_out => sig_d_addr, ctrl => sig_ctrl);
  dpu : data_path_unit port
  map
  (
  clk => clk, ctrl => sig_ctrl, data_or_addr_in => sig_d_addr, sw_in => sw, high_low_sw => sw8,
  flags => sig_alu_flags, led_out => led, sseg_anode_out => anode, sseg_cathode_out => cath);
end main;
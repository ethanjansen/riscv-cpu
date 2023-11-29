-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    14:40:00 11/28/2023
-- Design Name:    Sign Extender
-- Module Name:    sign_extender - ext
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                For certain Control signals, will sign extended the input of the DPU from the Controller.
--!                Converts immediate/switch input to 32 bits.
--                 Unnecessarily large ctrl to match controller opcodes and reduce combinational logic.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Sign Extender
library IEEE;
use IEEE.std_logic_1164.all;

entity sign_extender is
  port
  (
    ctrl                : in std_logic_vector(4 downto 0); --! Control Signals: "00000" or "00111" for 8-bit, otherwise 10-bit.
    data_from_cntrlr_in : in std_logic_vector(9 downto 0); --! 8- to 10-bit Data from Controller
    data_from_sw_in     : in std_logic_vector(7 downto 0); --! 8-bit Data from Switches
    data_out            : out std_logic_vector(31 downto 0) --! Data Out
  );
end sign_extender;

architecture ext of sign_extender is
  constant sel_load_immediate : std_logic_vector(4 downto 0) := "00000";
  constant sel_load_switch    : std_logic_vector(4 downto 0) := "00111";

  signal data_to_use        : std_logic_vector(9 downto 0); --! Selected data input from Controller or Switches.
  signal ext_7bit, ext_9bit : std_logic_vector(31 downto 0); --! Extensions based on bit x as most significant bit. 
begin
  data_to_use <= "00" & data_from_sw_in when ctrl = sel_load_switch else
    data_from_cntrlr_in;

  ext_7bit <= X"000000" & data_to_use(7 downto 0) when data_to_use(7) = '0' else
    X"FFFFFF" & data_to_use(7 downto 0);

  ext_9bit <= "0000000000000000000000" & data_to_use when data_to_use(9) = '0' else
    "1111111111111111111111" & data_to_use;

  with ctrl select
    data_out <= ext_7bit when sel_load_immediate | sel_load_switch,
    ext_9bit when others;
end ext;
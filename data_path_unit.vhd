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
    sw_in            : in std_logic_vector(7 downto 0); --! Data in from Switch
    flags            : out std_logic_vector(1 downto 0); --! Flags based on A (1=>"gt 0", 0=>"lt 0")
    led_out          : out std_logic_vector(15 downto 0); --! LED Output
    sseg_anode_out   : out std_logic_vector(4 downto 0); --! Seven-Segment Display Anode Output (time multiplexed)
    sseg_cathode_out : out std_logic_vector(7 downto 0) --! Seven-Segment Display Cathode Output (time multiplexed)
  );
end data_path_unit;

architecture dpu of data_path_unit is
  component accumulator is
    port
    (
      clk : in std_logic; --! Clock
      d   : in std_logic_vector(31 downto 0); --! Data In
      q   : out std_logic_vector(31 downto 0) --! Data Out
    );
  end component;

  component arithmetic_logic_unit is
    port
    (
      ctrl               : in std_logic_vector(6 downto 0); --! comes from high 7 bits of instruction encoding
      data1_in, data2_in : in std_logic_vector(31 downto 0); --! assuming immediate sign extensions happen outside of alu
      data_out           : out std_logic_vector(31 downto 0)
    );
  end component;

  component flag_handler is
    port
    (
      a_in     : in std_logic_vector(31 downto 0); --! Accumulator data in
      flag_out : out std_logic_vector(1 downto 0) --! Flag out
    );
  end component;

  component led_handler is
    port
    (
      clk     : in std_logic; --! Clock
      we      : in std_logic; --! Write Enable
      sel     : in std_logic; --! 1-bit Select for ('1') high bytes or ('0') low bytes.
      data_in : in std_logic_vector(31 downto 0); --! Data Input
      led_out : out std_logic_vector(15 downto 0) --! LED Output
    );
  end component;

  component ram_wf is
    port
    (
      clk   : in std_logic; --! Clock
      we    : in std_logic; --! Write Enable
      addr  : in std_logic_vector(9 downto 0); --! Address
      d_in  : in std_logic_vector(31 downto 0); --! Data in
      d_out : out std_logic_vector(31 downto 0) --! Data out
    );
  end component;

  component sign_extender is
    port
    (
      ctrl                : in std_logic_vector(4 downto 0); --! Control Signals: "00000" or "00111" for 8-bit, otherwise 10-bit.
      data_from_cntrlr_in : in std_logic_vector(9 downto 0); --! 8- to 10-bit Data from Controller
      data_from_sw_in     : in std_logic_vector(7 downto 0); --! 8-bit Data from Switches
      data_out            : out std_logic_vector(31 downto 0) --! Data Out
    );
  end component;

  component sseg_handler is
    port
    (
      clk         : in std_logic; --! Clock
      we          : in std_logic; --! Write Enable
      sel         : in std_logic; --! 1-bit Select for ('1') high bytes or ('0') low bytes.
      data_in     : in std_logic_vector(31 downto 0); --! Data Input
      anode_out   : out std_logic_vector(0 to 4); --! Anode Output
      cathode_out : out std_logic_vector(7 downto 0) --! Cathode Output
    );
  end component;

begin

end dpu;
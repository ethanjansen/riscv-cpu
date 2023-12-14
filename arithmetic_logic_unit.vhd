-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    16:00:00 11/14/2023
-- Design Name:    Arithmetic-Logic Unit
-- Module Name:    arithmetic_logic_unit - alu
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    Accumulator based microprocessor design
--                 Where the control signals are obtained from:
--                    The control signals are obtained from the high 7 bits of the given instruction set encoding. This allows for directly taking the values from the instruction rather than having to create new signals from the controller.
--                    The first two bits (high to low) represent "course select" which would be "00" for ALU, "01" for store, "10" for branch/wait, and "11" for display/output.
--                    Because of this all the alu ctrl signals start with "00".
--                    The next 3 bits represent fine select and correspond to operations such as load ("000"), add ("001"), shift left ("010"), etc.
--                    The last 2 bits of the control signal are "general" and are used to indicate between different sub operations such as load b0, b1, b2, or b3, for instance.
--
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- ALU
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity arithmetic_logic_unit is
  port
  (
    ctrl               : in std_logic_vector(6 downto 0); --! comes from high 7 bits of instruction encoding
    data1_in, data2_in : in std_logic_vector(31 downto 0); --! assuming immediate sign extensions happen outside of alu
    data_out           : out std_logic_vector(31 downto 0)
  );
end arithmetic_logic_unit;

architecture alu of arithmetic_logic_unit is
  constant sel_load                                                : std_logic_vector(6 downto 0) := "0000000";
  constant sel_load_b1                                             : std_logic_vector(6 downto 0) := "0000001";
  constant sel_load_b2                                             : std_logic_vector(6 downto 0) := "0000010";
  constant sel_load_b3                                             : std_logic_vector(6 downto 0) := "0000011";
  constant sel_add                                                 : std_logic_vector(6 downto 0) := "0000100";
  constant sel_shiftr                                              : std_logic_vector(6 downto 0) := "0001000";
  constant sel_shiftl                                              : std_logic_vector(6 downto 0) := "0001100";
  constant sel_and                                                 : std_logic_vector(6 downto 0) := "0010000";
  constant sel_or                                                  : std_logic_vector(6 downto 0) := "0010100";
  constant sel_xor                                                 : std_logic_vector(6 downto 0) := "0011000";
  signal sig_load_b1, sig_load_b2, sig_load_b3                     : std_logic_vector(31 downto 0);
  signal sig_add, sig_shiftr, sig_shiftl, sig_and, sig_or, sig_xor : std_logic_vector(31 downto 0);
begin
  -- signals all calculated to be muxed via ctrl
  -- loads (sig_load_regiser = sig_load_b0 = data1_in)
  sig_load_b1 <= data1_in(31 downto 8) & data2_in(7 downto 0);
  sig_load_b2 <= data1_in(31 downto 16) & data2_in(15 downto 0);
  sig_load_b3 <= data1_in(31 downto 24) & data2_in(23 downto 0);
  -- logic
  sig_add    <= std_logic_vector(signed(data1_in) + signed(data2_in));
  sig_shiftr <= '0' & data2_in(31 downto 1);
  sig_shiftl <= data2_in(30 downto 0) & '0';
  sig_and    <= data1_in and data2_in;
  sig_or     <= data1_in or data2_in;
  sig_xor    <= data1_in xor data2_in;

  -- signal select mux
  with ctrl select
    data_out <= data1_in when sel_load,
    sig_load_b1 when sel_load_b1,
    sig_load_b2 when sel_load_b2,
    sig_load_b3 when sel_load_b3,
    sig_add when sel_add,
    sig_shiftr when sel_shiftr,
    sig_shiftl when sel_shiftl,
    sig_and when sel_and,
    sig_or when sel_or,
    sig_xor when sel_xor,
    data2_in when others; -- passthrough when ALU not use to preserve A
end alu;
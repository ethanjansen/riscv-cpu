-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Jaron Brown
--
-- Create Date:    19:05:00 3/6/2024
-- Design Name:    Arithmetic-Logic Unit
-- Module Name:    arithmetic_logic_unit - alu
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    

-- Revision:       Revision 1.1
-- Testing Status: Tested
-------------------------------------------------------------------------------
-- ALU
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity arithmetic_logic_unit is
  port
  (
    ctrl               : in std_logic_vector(2 downto 0); --! From control module
    data1_in, data2_in : in std_logic_vector(31 downto 0); --! Assuming immediate sign extensions happen outside of alu
    data_out           : out std_logic_vector(31 downto 0);
    flags              : out std_logic_vector(3 downto 0)
  );
end arithmetic_logic_unit;

architecture alu of arithmetic_logic_unit is
  constant sel_add                         : std_logic_vector(2 downto 0) := "000";
  constant sel_sll                         : std_logic_vector(2 downto 0) := "001";
  constant sel_sub                         : std_logic_vector(2 downto 0) := "010";
  constant sel_sra                         : std_logic_vector(2 downto 0) := "011";
  constant sel_xor                         : std_logic_vector(2 downto 0) := "100";
  constant sel_srl                         : std_logic_vector(2 downto 0) := "101";
  constant sel_or                          : std_logic_vector(2 downto 0) := "110";
  constant sel_and                         : std_logic_vector(2 downto 0) := "111";
  signal nonzero_s, nonzero_u              : std_logic;
  signal shift                             : std_logic_vector(4 downto 0);
  signal sig_sra                           : std_logic_vector(31 downto 0);
  signal sig_xor, sig_srl, sig_or, sig_and : std_logic_vector(31 downto 0);
  signal sig_sll                           : unsigned(31 downto 0);
  signal sig_add, sig_sub                  : signed(31 downto 0);
  signal unsigned_ext_1, unsigned_ext_2    : std_logic_vector(32 downto 0);
  signal sig_unsigned_comp                 : signed(32 downto 0);

begin
  -- signals all calculated to be muxed via ctrl

  -- logic
  shift   <= data2_in(4 downto 0);
  sig_add <= signed(data1_in) + signed(data2_in);
  sig_sll <= shift_left(unsigned(data1_in), to_integer(unsigned(shift))); --! Check type of output
  sig_sub <= signed(data1_in) - signed(data2_in);
  sig_sra <= std_logic_vector(shift_right(signed(data1_in), to_integer(unsigned(shift))));
  sig_xor <= data1_in xor data2_in;
  sig_srl <= std_logic_vector(shift_right(unsigned(data1_in), to_integer(unsigned(shift))));
  sig_or  <= data1_in or data2_in;
  sig_and <= data1_in and data2_in;

  nonzero_s <= '0' when sig_sub = X"00000000" else
    '1'; --! Check difference is non-zero
  flags(3)          <= (not sig_sub(31)) and nonzero_s; --! Positive and non-zero
  flags(2)          <= sig_sub(31); --! Sign bit of signed subtraction operation
  unsigned_ext_1    <= '0' & data1_in; --! Effectively create positive signed value from unsigned
  unsigned_ext_2    <= '0' & data2_in; --! Effectively create positive signed value from unsigned
  sig_unsigned_comp <= signed(unsigned_ext_1) - signed(unsigned_ext_2);
  nonzero_u         <= '0' when sig_unsigned_comp = "000000000000000000000000000000000" else
    '1'; --! Check difference is non-zero
  flags(1) <= (not sig_unsigned_comp(32)) and nonzero_u;
  flags(0) <= sig_unsigned_comp(32);
  -- signal select mux
  with ctrl select
    data_out <=
    std_logic_vector(sig_add) when sel_add,
    std_logic_vector(sig_sll) when sel_sll,
    std_logic_vector(sig_sub) when sel_sub,
    sig_sra when sel_sra,
    sig_xor when sel_xor,
    sig_srl when sel_srl,
    sig_or when sel_or,
    sig_and when others;
end alu;
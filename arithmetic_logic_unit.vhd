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

-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- ALU
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity arithmetic_logic_unit is
  port
  (
    funct3               : in std_logic_vector(3 downto 0); --! From funct3[2:0], bit-30
    br                 : in std_logic; --! Triggers subtraction for branch conditions (op code = 1100011)

    -- May need to add more control signals for store, load, branch, jump
    data1_in, data2_in : in std_logic_vector(31 downto 0); --! Assuming immediate sign extensions happen outside of alu
    data_out           : out std_logic_vector(31 downto 0);
    less               : out std_logic; --! Less-than
    greater            : out std_logic --! Greater-than
  );
end arithmetic_logic_unit;

architecture alu of arithmetic_logic_unit is
  constant sel_add                                                 : std_logic_vector(2 downto 0) := "000";
  constant sel_sll                                                 : std_logic_vector(2 downto 0) := "001";
  constant sel_slt                                                 : std_logic_vector(2 downto 0) := "010";
  constant sel_sltiu                                               : std_logic_vector(2 downto 0) := "011";
  constant sel_xor                                                 : std_logic_vector(2 downto 0) := "100";
  constant sel_sr                                                  : std_logic_vector(2 downto 0) := "101";
  constant sel_or                                                  : std_logic_vector(2 downto 0) := "110";
  constant sel_and                                                 : std_logic_vector(2 downto 0) := "111";
  signal sig_add, sig_sub, sig_sll, sig_slt, sig_xor, sig_sr, sig_or, sig_and : std_logic_vector(31 downto 0);
begin
  -- signals all calculated to be muxed via ctrl
 
  -- logic
  sig_add    <= std_logic_vector(signed(data1_in) + signed(data2_in));
  sig_sub    <= std_logic_vector(signed(data1_in) - signed(data2_in));
  sig_sll    <= shift_left(unsigned(data1_in), to_integer(unsigned(data2_in))); --! Check type of output (may need to cast to std_logic_vector)
  sig_slt    <= (0=>less, others=>'0'); --! Double-check the syntax
  sig_xor    <= data1_in xor data2_in;
  sig_sr     <= ; --! Implement arithmetic and logical shift
  sig_and    <= data1_in and data2_in;
  sig_or     <= data1_in or data2_in;
  

  less       <= sig_sub(31); --! Sign bit of subtraction operation
  nonzero <= '0' when sig_sub=X"00000000" else '1'; --! Check difference is non-zero
  greater    <= (sig_sub(31) = '0') & nonzero; --! Positive and non-zero


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

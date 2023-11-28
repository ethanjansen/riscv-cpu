-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    16:00:00 11/14/2023
-- Design Name:    Processor
-- Module Name:    top_sch_proj - test_alu
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
    extin : in std_logic_vector(6 downto 0); -- added for testing
    led   : out std_logic_vector(15 downto 0);
    cath  : out std_logic_vector(7 downto 0); -- seven-seg display (muxing done outside of processor)
    anode : out std_logic_vector(4 downto 0)
  );
end top_sch_proj;

architecture test_alu of top_sch_proj is
  component arithmetic_logic_unit is
    port
    (
      ctrl               : in std_logic_vector(6 downto 0); -- come from high 7 bits of instruction encoding
      data1_in, data2_in : in std_logic_vector(31 downto 0); -- assuming immediate sign extensions happen outside of alu
      data_out           : out std_logic_vector(31 downto 0)
    );
  end component;
  signal sig_in, sig_out : std_logic_vector(31 downto 0);
begin
  -- with current testing implementation can only add using 8 least bits and display to leds with 16 least bits. Would change for further testing.
  sig_in <= "000000000000000000000000" & sw;
  led    <= sig_out(15 downto 0);

  alu : arithmetic_logic_unit port map
  (
    ctrl     => extin,
    data1_in => sig_in,
    data2_in => "11011110101011011011111011101111", --deadbeef
    data_out => sig_out
  );
end test_alu;
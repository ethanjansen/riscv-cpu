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
  signal cath_internal0, cath_internal1, cath_internal2, cath_internal3 : std_logic_vector(7 downto 0); --! each cathode value computed from lut (not directly displayed)
  signal cath_internal4, cath_internal5, cath_internal6, cath_internal7 : std_logic_vector(7 downto 0); --! each cathode value computed from lut (not directly displayed)
  signal half_data                                                      : std_logic_vector(31 downto 0); --! selected high/low bytes of display_data_buf
  signal display_data_buf                                               : std_logic_vector(63 downto 0); --! holds data (in concatenated sseg format) when we='0' 
  signal cnt                                                            : std_logic_vector(1 downto 0); --! 2-bit counter

  component hex4_to_7segment is -- LUT
    port
    (
      hex : in std_logic_vector(3 downto 0); --! 4-bit hex input
      seg : out std_logic_vector(7 downto 0) --! 8-bit sseg output
    );
  end component;

  component counter_2bit is -- Counter
    port
    (
      clk   : in std_logic; --! Clock
      count : out std_logic_vector(1 downto 0) --! Counter Value
    );
  end component;
begin
  -- use lut to translate bits
  lut0 : hex4_to_7segment port map
    (hex => data_in(3 downto 0), seg => cath_internal0);
  lut1 : hex4_to_7segment port
  map(hex => data_in(7 downto 4), seg => cath_internal1);
  lut2 : hex4_to_7segment port
  map(hex => data_in(11 downto 8), seg => cath_internal2);
  lut3 : hex4_to_7segment port
  map(hex => data_in(15 downto 12), seg => cath_internal3);
  lut4 : hex4_to_7segment port map
    (hex => data_in(19 downto 16), seg => cath_internal4);
  lut5 : hex4_to_7segment port
  map(hex => data_in(23 downto 20), seg => cath_internal5);
  lut6 : hex4_to_7segment port
  map(hex => data_in(27 downto 24), seg => cath_internal6);
  lut7 : hex4_to_7segment port
  map(hex => data_in(31 downto 28), seg => cath_internal7);

  -- memory
  hold_data : process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        display_data_buf <= cath_internal7 & cath_internal6 & cath_internal5 & cath_internal4 & cath_internal3 & cath_internal2 & cath_internal1 & cath_internal0;
      end if;
    end if;
  end process;

  -- get counter value
  counter : counter_2bit port
  map (clk => clk, count => cnt);
  
  -- display high or low bits based on sel
  half_data <= display_data_buf(63 downto 32) when sel = '1' else display_data_buf(31 downto 0);

  -- specify which digit to output to cathodes based on cnt
  with cnt select -- 0: 1s, 1: 16s, 2: 256s, 3: 4096s
    cathode_out <= half_data(7 downto 0) when "00",
    half_data(15 downto 8) when "01",
    half_data(23 downto 16) when "10",
    half_data(31 downto 24) when others;

  -- specify which anode to enable based on cnt.
  -- implemented to remove leading zeros.
  anode_out <= "10111" when cnt = "00" else
    "11011" when (cnt = "01" and half_data(31 downto 8) /= X"C0C0C0") else --in sseg sections
    "11101" when (cnt = "10" and half_data(31 downto 16) /= X"C0C0") else
    "11110" when (cnt = "11" and half_data(31 downto 24) /= X"C0") else
    "11111";
end sseg;
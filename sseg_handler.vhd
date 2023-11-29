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
    anode_out   : out std_logic_vector(0 to 4); --! Anode Output
    cathode_out : out std_logic_vector(7 downto 0) --! Cathode Output
  );
end sseg_handler;

architecture sseg of sseg_handler is
  signal cath_internal0, cath_internal1, cath_internal2, cath_internal3 : std_logic_vector(7 downto 0); --! each cathode value computed from lut (not directly displayed)
  signal half_data_in                                                   : std_logic_vector(15 downto 0); --! selected high/low bytes of data_in
  signal display_data_buf                                               : std_logic_vector(31 downto 0); --! holds data (in concatenated sseg format) when we='0' 
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
  -- with sel choose high or low bytes
  half_data_in <= data_in(31 downto 16) when sel = '1' else
    data_in(15 downto 0);

  -- use lut to translate bits
  lut0 : hex4_to_7segment port map
    (hex => half_data_in(3 downto 0), seg => cath_internal0);
  lut1 : hex4_to_7segment port
  map(hex => half_data_in(7 downto 4), seg => cath_internal1);
  lut2 : hex4_to_7segment port
  map(hex => half_data_in(11 downto 8), seg => cath_internal2);
  lut3 : hex4_to_7segment port
  map(hex => half_data_in(15 downto 12), seg => cath_internal3);

  -- memory
  hold_data : process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        display_data_buf <= cath_internal3 & cath_internal2 & cath_internal1 & cath_internal0;
      end if;
    end if;
  end process;

  -- get counter value
  counter : counter_2bit port
  map (clk => clk, count => cnt);

  -- specify which digit to output to cathodes based on cnt
  with cnt select -- 0: 1s, 1: 16s, 2: 256s, 3: 4096s
    cathode_out <= display_data_buf(7 downto 0) when "00",
    display_data_buf(15 downto 8) when "01",
    display_data_buf(23 downto 16) when "10",
    display_data_buf(31 downto 24) when others;

  -- specify which anode to enable based on cnt.
  -- implemented to remove leading zeros.
  anode_out <= "11101" when cnt = "00" else
    "11011" when (cnt = "01" and display_data_buf(31 downto 8) /= X"000000") else
    "10111" when (cnt = "10" and display_data_buf(31 downto 16) /= X"0000") else
    "01111" when (cnt = "11" and display_data_buf(31 downto 24) /= X"00") else
    "11111";
end sseg;
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
    signal display_data_buf : std_logic_vector(31 downto 0); --! holds data (in concatenated sseg format) when we='0' 
    signal cnt : std_logic_vector(1 downto 0);
    signal hex_digit : std_logic_vector(3 downto 0);
    signal anode_interal : std_logic_vector(4 downto 0);
    signal cathode_internal : std_logic_vector(7 downto 0);

    component hex4_to_7segment is -- LUT
        port
            (
              hex : in std_logic_vector(3 downto 0); --! 4-bit hex input
              seg : out std_logic_vector(7 downto 0) --! 8-bit sseg output
            );
        end component;
        
    component counter_2bit is -- Counter
        port(
            clk : in std_logic; --! Clock
            count : out std_logic_vector(1 downto 0) --! Counter Value
        );
    end component;
begin
  lut0 : hex4_to_7segment port map(hex=>data_in(7 downto 0), seg=>cath_internal0);
  lut1 : hex4_to_7segment port map(hex=>data_in(15 downto 8), seg=>cath_internal1);
  lut2 : hex4_to_7segment port map(hex=>data_in(23 downto 16), seg=>cath_internal2);
  lut3 : hex4_to_7segment port map(hex=>data_in(31 downto 24), seg=>cath_internal3);
  -- memory
  process(clk)
  begin
    if rising_edge(clk) then
        if we = '1' then
            if sel = '1' then -- data _in(31 downto 16)
              display_data_buf(7 downto 0) <= data_in(31 downto 16);
            else -- data_in(15 downto 0)
              display_data_buf <= data_in(15 downto 0);
            end if;
        end if;
    end if;
  end process;

  -- specify which digit to output to cathodes based on cnt
  with cnt select -- 0,1: 1s, 2: 10s, 3: 100s
  q <= p(7 downto 4) when "10",
  "00" & p(9 downto 8) when "11",
  p(3 downto 0) when others;

-- specify which anode to enable based on cnt (order is backwards from what is expected).
-- implemented to remove leading zeros.
anode_internal <= "10111" when cnt(1) = '0' else
  "11011" when cnt = "10" and (q /= "0000" or p(9 downto 8) /= "00") else --need to check 10s and 100s
  "11101" when cnt = "11" and q /= "0000" else
  "11111";
end sseg;

----------------------------------------------------------------------------------
-- HEX TO 7-SEGMENT (8 including decimal)
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity hex4_to_7segment is
  port
  (
    hex : in std_logic_vector(3 downto 0); --! 4-bit hex input
    seg : out std_logic_vector(7 downto 0) --! 8-bit sseg output
  );
end hex4_to_7segment;

architecture lut_7segment of hex4_to_7segment is
begin
  -- mapping 0-F in binary to segments on display
  with hex select
    seg <= "11000000" when X"0",
    "11111001" when X"1",
    "10100100" when X"2",
    "10110000" when X"3",
    "10011001" when X"4",
    "10010010" when X"5",
    "10000010" when X"6",
    "11111000" when X"7",
    "10000000" when X"8",
    "10011000" when X"9",
    "10001000" when X"A",
    "10000011" when X"B",
    "10100111" when X"C",
    "10100001" when X"D",
    "10000110" when X"E",
    "10001110" when others; --X"F"
end lut_7segment;

----------------------------------------------------------------------------------
-- 2-Bit Counter
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter_2bit is
    port(
        clk : in std_logic; --! Clock
        count : out std_logic_vector(1 downto 0) --! Counter Value
    );
    end counter_2bit;

architecture counter of counter_2bit is
    signal count_buf : unsigned(1 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            count_buf <= count_buf + 1;
        end if;
    end process;
    count <= std_logic_vector(count_buf);
end counter;

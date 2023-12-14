-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    15:50:00 11/28/2023
-- Design Name:    LED Handler
-- Module Name:    led_handler - leds
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                LED Logic with memory for holding output.
--                 1-bit select for ('1') high bytes or ('0') low bytes.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- LED Handler
library IEEE;
use IEEE.std_logic_1164.all;

entity led_handler is
  port
  (
    clk     : in std_logic; --! Clock
    we      : in std_logic; --! Write Enable
    sel     : in std_logic; --! 1-bit Select for ('1') high bytes or ('0') low bytes.
    data_in : in std_logic_vector(31 downto 0); --! Data Input
    led_out : out std_logic_vector(15 downto 0) --! LED Output
  );
end led_handler;

architecture leds of led_handler is
  signal led_buf : std_logic_vector(31 downto 0); --! memory for LEDs
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        led_buf <= data_in;
      end if;
    end if;
  end process;

  -- output
  led_out <= led_buf(31 downto 16) when sel = '1' else
    led_buf(15 downto 0);
end leds;
-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    13:00:00 11/21/2023
-- Design Name:    Write-First RAM
-- Module Name:    ram_wf - ram
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                1024x32 Write-First RAM for use in DPU.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- RAM
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram_wf is
  port
  (
    clk   : in std_logic; --! Clock
    we    : in std_logic; --! Write Enable
    addr  : in std_logic_vector(9 downto 0); --! Address
    d_in  : in std_logic_vector(31 downto 0); --! Data in
    d_out : out std_logic_vector(31 downto 0) --! Data out
  );
end ram_wf;

architecture ram_arch of ram_wf is
  type ram_type is array(0 to 1023) of std_logic_vector(31 downto 0);
  signal ram : ram_type;
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        ram(to_integer(unsigned(addr))) <= d_in;
        d_out                           <= d_in;
      else
        d_out <= ram(to_integer(unsigned(addr)));
      end if;
    end if;
  end process;
end ram_arch;
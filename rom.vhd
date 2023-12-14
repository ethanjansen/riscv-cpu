-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    13:00:00 11/21/2023
-- Design Name:    Initialized ROM
-- Module Name:    rom_with_init - rom
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                2048x18 ROM initialized by "rom.data" for Instruction Memory
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- ROM
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity rom_with_init is
  port
  (
    clk  : in std_logic; --! Clock
    en   : in std_logic; --! Enable
    addr : in std_logic_vector(10 downto 0); --! Address
    d    : out std_logic_vector(17 downto 0) --! Data Out
  );
end rom_with_init;

architecture rom of rom_with_init is
  type rom_type is array(0 to 2047) of std_logic_vector(17 downto 0);

  impure function initRomFromFile(romFileName : in string) return rom_type is
    file romFile                                : text is in romFileName;
    variable romFileLine                        : line;
    variable rom                                : rom_type;
  begin
    for i in rom_type'range loop
      readline(romFile, romFileLine);
      read(romFileLine, rom(i));
    end loop;
    return rom;
  end function;

  signal rom : rom_type := initRomFromFile("rom.data");
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if en = '1' then
        d <= rom(to_integer(unsigned(addr)));
      end if;
    end if;
  end process;
end rom;
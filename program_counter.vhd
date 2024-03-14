-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    16:00:00 11/14/2023
-- Design Name:    Program Counter
-- Module Name:    program_counter - counter_signed
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                11-bit Program Counter for use in Controller
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Program Counter
library IEEE;
use IEEE.std_logic_1164.all;

entity program_counter is
  port
  (
    clk   : in std_logic; --! Clock
    reset : in std_logic; --! Reset to 0
    en    : in std_logic; --! Enable
    D     : in std_logic_vector(9 downto 0); --! New pc
    Q     : out std_logic_vector(9 downto 0) --! Current pc
  );
end program_counter;

architecture pc of program_counter is
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        Q <= "0000000000";
      elsif en = '1' then
        Q <= D; --! When reset != 0 and en = 1
      else
        Q <= Q; --! When reset != 0 and en = 0
      end if;
    end if;
  end process;

end pc;
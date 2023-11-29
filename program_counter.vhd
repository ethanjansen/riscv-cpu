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
use IEEE.numeric_std.all;

entity program_counter is
  port
  (
    clk        : in std_logic; --! Clock
    reset      : in std_logic; --! Reset to 0
    en         : in std_logic; --! Enable
    br         : in std_logic; --! Branch
    jump_value : in std_logic_vector(11 downto 0); --! Jump by signed value for branch operations.
    count      : out std_logic_vector(10 downto 0) --! Counter Value (11 bits)
  );
end program_counter;

architecture counter_signed of program_counter is
  signal count_buf : signed(11 downto 0); --! adding extra bit for signed addition
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        count_buf <= to_signed(0, 12);
      elsif en = '1' then
        if br = '1' then
          count_buf <= count_buf + signed(jump_value); -- Careful! Will allow overflow
        else
          count_buf <= count_buf + 1;
          if count_buf(11) = '1' then -- reset to 0 after counting passed 2047
            count_buf <= to_signed(0, 12);
          end if;
        end if;
      end if;
    end if;
  end process;
  count <= std_logic_vector(unsigned(count_buf(10 downto 0)));
end counter_signed;
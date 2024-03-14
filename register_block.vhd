-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Jaron Brown
--
-- Create Date:    18:06:00 3/13/2024
-- Design Name:    Register block
-- Module Name:    register block
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    

-- Revision:       Revision 0.1
-- Testing Status: Untested
-------------------------------------------------------------------------------
-- Register block
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_block is
    port
    (
      clk               : in std_logic; --! Master clock
      we                : in std_logic; --! Write enable
      en                : in std_logic; --! Keeps Q_1 and Q_2 from changing
      A_1, A_2, A_Write : in std_logic_vector(4 downto 0); --! Address inputs
      D                 : in std_logic_vector(31 downto 0); --! Data in
      Q_1, Q_2          : out std_logic_vector(31 downto 0) --! Data out
    );
end register_block;

architecture reg_blk of register_block is
	type reg_type is array (31 downto 0) of std_logic_vector(31 downto 0);
	signal REG : reg_type := (others=>(others=>'0'));

	
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if en = '1' then
				if we = '1' and A_Write /= "00000" then
					REG(to_integer(unsigned(A_Write))) <= D;
					if (A_Write = A_1) and (A_Write = A_2) then
						Q_1 <= D;
						Q_2 <= D;
					elsif (A_Write = A_1) then
						Q_1 <= D;
						Q_2 <= REG(to_integer(unsigned(A_2)));
					elsif (A_Write = A_2) then
						Q_2 <= D;
						Q_1 <= REG(to_integer(unsigned(A_1)));
					else
						Q_1 <= REG(to_integer(unsigned(A_1)));
						Q_2 <= REG(to_integer(unsigned(A_2)));
					end if;
				else
					Q_1 <= REG(to_integer(unsigned(A_1)));
               Q_2 <= REG(to_integer(unsigned(A_2)));
				end if;
                
			end if;
		end if;
	end process;
end reg_blk;
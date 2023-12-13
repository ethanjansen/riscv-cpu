----------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
-- 
-- Create Date:    15:10:59 10/31/2023 
-- Design Name:    SlowClock
-- Module Name:    slow_clock - slow
-- Project Name:   SlowClock
-- Target Devices: Artix 7
-- Tool versions: 
-- Description: Create a slow clock from mclk.
--					 Divides mclk by 2*clk_div_half.
--              clk_div_half := 499 by default.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- SLOW CLOCK (50kHz default)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."ceil";
use IEEE.math_real."log2";

library UNISIM; -- for BUFG
use UNISIM.VComponents.all;

entity slow_clock is
    generic(clk_div_half : integer := 499);
    port(
	      mclk : in std_logic;
			slwclk : out std_logic
	 );
end slow_clock;

-- based off of clock generator by L. Aamodt
architecture slow of slow_clock is
    signal cnt_next, cnt_reg : unsigned((integer(ceil(log2(real(clk_div_half))))-1) downto 0);
	 signal t_next, t_reg : std_logic;
begin
    process(mclk) -- state memory
    begin
	     if rising_edge(mclk) then
		      cnt_reg <= cnt_next;
				t_reg <= t_next;
		  end if;
	 end process;

-- next state
cnt_next <= (others=>'0') when cnt_reg=clk_div_half else cnt_reg+1;
t_next <= (not t_reg) when cnt_reg=clk_div_half else t_reg;

clk_buffer : BUFG port map (i=>t_reg,
                           o=>slwclk);
end slow;

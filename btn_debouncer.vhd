-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    7:20:00 12/14/2023
-- Design Name:    Button Debouncer
-- Module Name:    btn_debouncer - dbnc
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                Debounce Buttons and create single clock pulses.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Button Debouncer

library IEEE;
use IEEE.std_logic_1164.all;

entity btn_debouncer is
  port
  (
    clk   : in std_logic; --! Clock
    en    : in std_logic; --! Pulsed Enable to slow operation
    btn   : in std_logic; --! Button
    pulse : out std_logic --! One clk pulse from the button
  );
end btn_debouncer;

architecture dbnc of btn_debouncer is
  type state_type is (wait_state, down_state, up_state);
  signal state_reg, state_next : state_type;
begin
  -- memory
  process (clk)
  begin
    if rising_edge(clk) then
      state_reg <= state_next;
    end if;
  end process;

  -- next state logic
  process (state_reg, btn, en)
  begin
    state_next <= state_reg;
    if en = '1' then
      case state_reg is
        when wait_state =>
          if btn = '0' then
            state_next <= down_state;
          end if;
        when down_state =>
          if btn = '1' then
            state_next <= up_state;
          end if;
        when up_state =>
          state_next <= wait_state;
      end case;
    end if;
  end process;

  -- output logic
  pulse <= '1' when state_reg = up_state and en = '1' else
    '0';

end dbnc;
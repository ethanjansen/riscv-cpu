
-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    16:10:00 12/5/2023
-- Design Name:    Controller FSM
-- Module Name:    controller_fsm - fsm
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                CPU Controller Control FSM
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Controller FSM
library IEEE;
use IEEE.std_logic_1164.all;

entity controller_fsm is
  port
  (
    clk                             : in std_logic; --! Clock
    cont                            : in std_logic; --! Continue
    reset                           : in std_logic; --! Reset
    sstep                           : in std_logic; --! Single Step
    alu_flags                       : in std_logic_vector(1 downto 0); --! ALU Flags
    op1_in, op2_in                  : in std_logic_vector(17 downto 0); --! Operation Codes from PMEM (assume 2 is one ahead of 1)
    pc_en, pmem_en, pc_br, pc_reset : out std_logic; --! pmem and pc enable outs, pc br switch out, pc reset out
    pc_offset                       : out std_logic_vector(11 downto 0); --! PC offset
    d_addr_out                      : out std_logic_vector(9 downto 0); --! immediate/addr out to dpu
    ctrl                            : out std_logic_vector(7 downto 0) --! ctrl signals out to dpu
  );
end controller_fsm;

architecture fsm of controller_fsm is
  type state_type is (init, delay, run, wait_state, run_copy, reset_state);
  signal state_reg, state_next : state_type; --! state signals
  signal do_branch             : std_logic; --! computed based on op1_in and alu flags
begin
  -- state memory
  process (clk)
  begin
    if rising_edge(clk) then
      state_reg <= state_next;
    end if;
  end process;

  -- next state logic
  process (state_reg, op1_in, do_branch, reset, cont, sstep)
  begin
    case state_reg is
      when init =>
        state_next <= delay;
      when delay =>
        state_next <= run;
      when run =>
        if reset = '1' then -- reset
          state_next <= reset_state;
        elsif op1_in(17 downto 16) = "10" then -- wait and br
          if op1_in(15 downto 12) = "1111" then -- wait
            state_next <= wait_state;
          elsif do_branch = '1' then -- branch
            state_next <= init;
          else
            state_next <= state_reg; -- dont wait or branch
          end if;
        else
          state_next <= state_reg; --stay in run
        end if;
      when wait_state =>
        if reset = '1' then
          state_next <= reset_state; -- reset
        elsif cont = '1' then -- continue to run
          state_next <= run;
        elsif sstep = '1' then -- step to run copy which goes directly to wait
          state_next <= run_copy;
        else -- stay in wait
          state_next <= state_reg;
        end if;
      when run_copy =>
        state_next <= wait_state;
      when reset_state =>
        state_next <= init;
    end case;
  end process;

  -- output logic (state based) init, delay, run, wait_state, run_copy, reset_state
  process (state_reg)
  begin
    -- init
    pc_en <= '0';
    pmem_en <= '0';
    pc_reset <= '0';

    case state_reg is
        when init =>
            pc_en <= '1';
            pmem_en <= '1';
        when delay =>
            pc_en <= '1';
            pmem_en <= '1';
        when run =>
            pc_en <= '1';
            pmem_en <= '1';
        when wait_state =>
        when run_copy =>
            pc_en <= '1';
            pmem_en <= '1';
        when reset_state =>
            pc_reset <= '1';
    end case;
    
    pc_br     <= do_branch;
  end process;

  -- output logic (pure mealy)
  pc_offset <= op1_in(11 downto 0);


  -- signal assignments
  do_branch <= '1' when (op1_in(15 downto 12) = "0000") or
    (op1_in(15 downto 12) = "0001" and alu_flags = "00") or
    (op1_in(15 downto 12) = "0010" and alu_flags /= "00") or
    (op1_in(15 downto 12) = "0011" and alu_flags = "10") or
    (op1_in(15 downto 12) = "0100" and alu_flags = "01") else
    '0';
end fsm;
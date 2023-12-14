
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
    continue                        : in std_logic; --! Continue
    reset                           : in std_logic; --! Reset
    sstep, sstep_set_read           : in std_logic; --! Single Step
    alu_flags                       : in std_logic_vector(1 downto 0); --! ALU Flags
    pmem_in                         : in std_logic_vector(17 downto 0); --! Operation Codes from PMEM (assume 2 is one ahead of 1)
    pc_en, pmem_en, pc_br, pc_reset : out std_logic; --! pmem and pc enable outs, pc br switch out, pc reset out
    sstep_set_load, sstep_clear     : out std_logic; --! sstep FF set and clear
    pc_offset                       : out std_logic_vector(11 downto 0); --! PC offset
    d_addr_out                      : out std_logic_vector(9 downto 0); --! immediate/addr out to dpu
    ctrl                            : out std_logic_vector(7 downto 0) --! ctrl signals out to dpu
  );
end controller_fsm;

architecture fsm of controller_fsm is
  -- states
  constant pc_inc_state          : std_logic_vector(3 downto 0) := "0000";
  constant reset_state           : std_logic_vector(3 downto 0) := "0001";
  constant choose_state          : std_logic_vector(3 downto 0) := "0010";
  constant branch_pc_inc_state   : std_logic_vector(3 downto 0) := "0011";
  constant branch_pmem_en_state  : std_logic_vector(3 downto 0) := "0100";
  constant reg_write_state       : std_logic_vector(3 downto 0) := "0101";
  constant extra_for_3step_state : std_logic_vector(3 downto 0) := "0110";
  constant reg_read_state        : std_logic_vector(3 downto 0) := "0111";
  constant wait_state            : std_logic_vector(3 downto 0) := "1000";
  constant sstep_state           : std_logic_vector(3 downto 0) := "1001";
  constant wait_copy_state       : std_logic_vector(3 downto 0) := "1010";
  constant sstep_copy_state      : std_logic_vector(3 downto 0) := "1011";
  signal state_reg, state_next   : std_logic_vector(3 downto 0); --! state signals
  signal do_branch               : std_logic; --! computed based on op1_in and alu flags

  constant zero_data : std_logic_vector(9 downto 0) := "0000000000";
begin
  -- state memory
  process (clk)
  begin
    if rising_edge(clk) then
      state_reg <= state_next;
    end if;
  end process;

  -- next state logic
  process (state_reg, reset, continue, sstep, sstep_set_read, pmem_in, do_branch)
  begin
    if reset = '1' then
      state_next <= reset_state;
    else
      case state_reg is
        when pc_inc_state =>
          state_next <= choose_state;
        when reset_state =>
          state_next <= pc_inc_state;
        when choose_state =>
          if pmem_in(17 downto 16) = "11" then -- display (optionally go to wait)
            if sstep_set_read = '1' then
              state_next <= wait_state;
            else
              state_next <= pc_inc_state;
            end if;
          elsif pmem_in(17 downto 12) = "101111" then -- wait
            state_next <= wait_state;
          elsif do_branch = '1' then -- branch
            state_next <= branch_pc_inc_state;
          elsif pmem_in(17 downto 16) = "01" then -- store
            state_next <= reg_write_state;
          elsif pmem_in(10) = '1' then -- ALU 3step
            state_next <= extra_for_3step_state;
          else -- ALU 4step
            state_next <= reg_read_state;
          end if;
        when branch_pc_inc_state => -- figure out sstep
          if sstep_set_read = '1' then
            state_next <= wait_copy_state; -- go to wait copy
          else
            state_next <= branch_pmem_en_state;
          end if;
        when branch_pmem_en_state =>
          state_next <= choose_state;
        when wait_state =>
          if continue = '1' then
            state_next <= pc_inc_state;
          elsif sstep = '1' then
            state_next <= sstep_state;
          else
            state_next <= state_reg;
          end if;
        when wait_copy_state => -- copy of wait
          if continue = '1' then
            state_next <= branch_pmem_en_state;
          elsif sstep = '1' then
            state_next <= sstep_copy_state;
          else
            state_next <= state_reg;
          end if;
        when sstep_state =>
          state_next <= pc_inc_state;
        when sstep_copy_state =>
          state_next <= branch_pmem_en_state;
        when others => -- reg_write, extra_for_3step, reg_read
          if sstep_set_read = '1' then
            state_next <= wait_state;
          else
            state_next <= pc_inc_state;
          end if;
      end case;
    end if;
  end process;

  -- output logic
  process (state_reg)
  begin
    case state_reg is
      when pc_inc_state =>
        pc_en   <= '1';
        pmem_en <= '1';
      when reset_state =>
        pc_reset <= '1';
      when branch_pc_inc_state =>
        pc_br <= '1';
      when branch_pmem_en_state =>
        pmem_en <= '1';
      when wait_state =>
        sstep_clear <= '1';
      when wait_copy_state =>
        sstep_clear <= '1';
      when sstep_state =>
        sstep_set_load <= '1';
      when sstep_copy_state =>
        sstep_set_load <= '1';
      when others => -- choose, reg_write, extra_for_3step, reg_read
    end case;
  end process;

  -- always pass (DPU)
  ctrl       <= pmem_in(17 downto 10);
  d_addr_out <= pmem_in(9 downto 0);
  -- always pass (PC)
  pc_offset <= pmem_in(11 downto 0);

  -- signal assignments
  do_branch <= '1' when (pmem_in(15 downto 12) = "0000") or
    (pmem_in(15 downto 12) = "0001" and alu_flags = "00") or
    (pmem_in(15 downto 12) = "0010" and alu_flags /= "00") or
    (pmem_in(15 downto 12) = "0011" and alu_flags = "10") or
    (pmem_in(15 downto 12) = "0100" and alu_flags = "01") else
    '0';
end fsm;
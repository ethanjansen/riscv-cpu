-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    22:55:00 12/12/2023
-- Design Name:    Controller
-- Module Name:    controller - ctrlr
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                Controller for CPU Project. Consists of PC, PMEM ROM, FSM, and SSTEP Flag Handler.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Controller
library IEEE;
use IEEE.std_logic_1164.all;

entity controller is
  port
  (
    clk        : in std_logic; --! Clock
    ctrl_btns  : in std_logic_vector(2 downto 0); --! Buttons for reset (0), continue (1), and sstep (2)
    alu_flags  : in std_logic_vector(1 downto 0); --! Flags from ALU
    d_addr_out : out std_logic_vector(9 downto 0); --! Data and Addr out for DPU
    ctrl       : out std_logic_vector(7 downto 0) --! Control signals from PMEM for DPU
  );
end controller;

architecture ctrlr of controller is
  signal sig_pmem_d         : std_logic_vector(17 downto 0); --! From PMEM d to FSM PMEM_in
  signal sig_pc_count       : std_logic_vector(10 downto 0); --! count from PC to PMEM addr
  signal sig_pmem_en        : std_logic; --! PMEM enable signal from FSM
  signal sig_sstep_set_load : std_logic; --! From FSM sstep_set_load to SSTEP flag handler set
  signal sig_sstep_clear    : std_logic; --! from FSM sste_clear to SSTEP flag handler clear
  signal sig_sstep_val      : std_logic; --! from SSTEP val to FSM sstep_set_read
  signal sig_pc_offset      : std_logic_vector(11 downto 0); --! from FSM pc_offset to PC jump_value
  signal sig_pc_br          : std_logic; --! from FSM pc_br to PC br
  signal sig_pc_en          : std_logic; --! from FSM pc_en to PC en
  signal sig_pc_reset       : std_logic; --! from FSM pc_reset to PC reset

  component sstep_flag_handler is
    port
    (
      clk   : in std_logic; --! Clock
      clear : in std_logic; --! Sets val to 0
      set   : in std_logic; --! Sets val to 1
      val   : out std_logic --! output value
    );
  end component;

  component program_counter is
    port
    (
      clk        : in std_logic; --! Clock
      reset      : in std_logic; --! Reset to 0
      en         : in std_logic; --! Enable
      br         : in std_logic; --! Branch
      jump_value : in std_logic_vector(11 downto 0); --! Jump by signed value for branch operations.
      count      : out std_logic_vector(10 downto 0) --! Counter Value (11 bits)
    );
  end component;

  component rom_with_init is
    port
    (
      clk  : in std_logic; --! Clock
      en   : in std_logic; --! Enable
      addr : in std_logic_vector(10 downto 0); --! Address
      d    : out std_logic_vector(17 downto 0) --! Data Out
    );
  end component;

  component controller_fsm is
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
  end component;
begin
  -- port mappings
  pc : program_counter port map
    (clk => clk, reset => sig_pc_reset, en => sig_pc_en, br => sig_pc_br, jump_value => sig_pc_offset, count => sig_pc_count);
  pmem : rom_with_init port
  map(clk => clk, en => sig_pmem_en, addr => sig_pc_count, d => sig_pmem_d);
  sstep_handler : sstep_flag_handler port
  map(clk => clk, clear => sig_sstep_clear, set => sig_sstep_set_load, val => sig_sstep_val);
  fsm : controller_fsm port
  map(clk => clk, continue => ctrl_btns(1), reset => ctrl_btns(0), sstep => ctrl_btns(2), sstep_set_read => sig_sstep_val, alu_flags => alu_flags, pmem_in => sig_pmem_d, pc_en => sig_pc_en, pmem_en => sig_pmem_en, pc_br => sig_pc_br, pc_reset => sig_pc_reset, sstep_set_load => sig_sstep_set_load, sstep_clear => sig_sstep_clear, pc_offset => sig_pc_offset, d_addr_out => d_addr_out, ctrl => ctrl);
end ctrlr;
-------------------------------------------------------------------------------
-- Company:        Walla Walla University
-- Engineer:       Ethan Jansen
--
-- Create Date:    14:40:00 11/28/2023
-- Design Name:    Data Path Unit
-- Module Name:    data_path_unit - dpu
-- Project Name:   MicroprocessorDesign
-- Target Devices: Artix 7
-- Description:    
--!                DPU for CPU Project. Consists of Regiser memory, ALU, Accumulator, Seven-Segment Display Logic, Flag Handler, and I/O Muxes.
-- Revision:       Revision 0.01 - File Created
-------------------------------------------------------------------------------
-- Data Path Unit
library IEEE;
use IEEE.std_logic_1164.all;

entity data_path_unit is
  port
  (
    clk              : in std_logic; --! Clock
    ctrl             : in std_logic_vector(7 downto 0); --! Control Signal from DPU
    data_or_addr_in  : in std_logic_vector(9 downto 0); --! Data or Address in from Controller
    sw_in            : in std_logic_vector(7 downto 0); --! Data in from Switch
    high_low_sw      : in std_logic; --! High/Low Display Select from sw8
    flags            : out std_logic_vector(1 downto 0); --! Flags based on A (1=>"gt 0", 0=>"lt 0")
    led_out          : out std_logic_vector(15 downto 0); --! LED Output
    sseg_anode_out   : out std_logic_vector(4 downto 0); --! Seven-Segment Display Anode Output (time multiplexed)
    sseg_cathode_out : out std_logic_vector(7 downto 0) --! Seven-Segment Display Cathode Output (time multiplexed)
  );
end data_path_unit;

architecture dpu of data_path_unit is
  constant sel_store : std_logic_vector(1 downto 0) := "01"; --! used to compare for RAM we
  constant sel_led   : std_logic_vector(4 downto 0) := "11000"; --! used to compare for LED we
  constant sel_sseg  : std_logic_vector(4 downto 0) := "11001"; --! used to compare for SSEG we

  signal sig_ram_we, sig_led_we, sig_sseg_we                                   : std_logic; --! 1-bit write enable signals
  signal sig_d_in, sig_ram_d_out, sig_a_d, sig_a_q, sig_alu_d1_in, sig_display : std_logic_vector(31 downto 0); --! 32-bit data signals

  component accumulator is
    port
    (
      clk : in std_logic; --! Clock
      d   : in std_logic_vector(31 downto 0); --! Data In
      q   : out std_logic_vector(31 downto 0) --! Data Out
    );
  end component;

  component arithmetic_logic_unit is
    port
    (
      ctrl               : in std_logic_vector(6 downto 0); --! comes from high 7 bits of instruction encoding
      data1_in, data2_in : in std_logic_vector(31 downto 0); --! assuming immediate sign extensions happen outside of alu
      data_out           : out std_logic_vector(31 downto 0)
    );
  end component;

  component flag_handler is
    port
    (
      a_in     : in std_logic_vector(31 downto 0); --! Accumulator data in
      flag_out : out std_logic_vector(1 downto 0) --! Flag out
    );
  end component;

  component led_handler is
    port
    (
      clk     : in std_logic; --! Clock
      we      : in std_logic; --! Write Enable
      sel     : in std_logic; --! 1-bit Select for ('1') high bytes or ('0') low bytes.
      data_in : in std_logic_vector(31 downto 0); --! Data Input
      led_out : out std_logic_vector(15 downto 0) --! LED Output
    );
  end component;

  component ram_wf is
    port
    (
      clk   : in std_logic; --! Clock
      we    : in std_logic; --! Write Enable
      addr  : in std_logic_vector(9 downto 0); --! Address
      d_in  : in std_logic_vector(31 downto 0); --! Data in
      d_out : out std_logic_vector(31 downto 0) --! Data out
    );
  end component;

  component sign_extender is
    port
    (
      ctrl               : in std_logic_vector(4 downto 0); --! Control Signals: "00000" or "00111" for 8-bit, otherwise 10-bit.
      data_from_ctrlr_in : in std_logic_vector(9 downto 0); --! 8- to 10-bit Data from Controller
      data_from_sw_in    : in std_logic_vector(7 downto 0); --! 8-bit Data from Switches
      data_out           : out std_logic_vector(31 downto 0) --! Data Out
    );
  end component;

  component sseg_handler is
    port
    (
      clk         : in std_logic; --! Clock
      we          : in std_logic; --! Write Enable
      sel         : in std_logic; --! 1-bit Select for ('1') high bytes or ('0') low bytes.
      data_in     : in std_logic_vector(31 downto 0); --! Data Input
      anode_out   : out std_logic_vector(0 to 4); --! Anode Output
      cathode_out : out std_logic_vector(7 downto 0) --! Cathode Output
    );
  end component;
begin
  -- comparisons
  sig_ram_we <= '1' when ctrl(7 downto 6) = sel_store else
    '0';
  sig_led_we <= '1' when ctrl(7 downto 3) = sel_led else
    '0';
  sig_sseg_we <= '1' when ctrl(7 downto 3) = sel_sseg else
    '0';

  sig_alu_d1_in <= sig_ram_d_out when ctrl(0) = '0' else
    sig_d_in;
  sig_display <= sig_a_q when ctrl(0) = '0' else
    sig_d_in;

  -- port maps
  a : accumulator port map
  (
    clk => clk, d => sig_a_d,
    q => sig_a_q);
  alu : arithmetic_logic_unit port
  map(ctrl => ctrl(7 downto 1), data1_in => sig_alu_d1_in, data2_in => sig_a_q,
  data_out => sig_a_d);
  flagger : flag_handler port
  map(a_in => sig_a_q,
  flag_out => flags);
  led_buf : led_handler port
  map(clk => clk, we => sig_led_we, sel => high_low_sw, data_in => sig_display,
  led_out => led_out);
  ram : ram_wf port
  map(clk => clk, we => sig_ram_we, addr => data_or_addr_in, d_in => sig_a_q,
  d_out => sig_ram_d_out);
  sign_ext : sign_extender port
  map(ctrl => ctrl(7 downto 3), data_from_ctrlr_in => data_or_addr_in, data_from_sw_in => sw_in,
  data_out => sig_d_in);
  sseg_buf : sseg_handler port
  map(clk => clk, we => sig_sseg_we, sel => high_low_sw, data_in => sig_display,
  anode_out => sseg_anode_out, cathode_out => sseg_cathode_out);
end dpu;
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:36:52 03/13/2024
-- Design Name:   
-- Module Name:   /home/wwu/1458226/Documents/CPTR380/RISC_V/register_block_test_testbench.vhd
-- Project Name:  RISC_V
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: register_block
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY register_block_test_testbench IS
END register_block_test_testbench;
 
ARCHITECTURE behavior OF register_block_test_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT register_block
    PORT(
         clk : IN  std_logic;
         we : IN  std_logic;
         en : IN  std_logic;
         A_1 : IN  std_logic_vector(4 downto 0);
         A_2 : IN  std_logic_vector(4 downto 0);
         A_Write : IN  std_logic_vector(4 downto 0);
         D : IN  std_logic_vector(31 downto 0);
         Q_1 : OUT  std_logic_vector(31 downto 0);
         Q_2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal we : std_logic := '0';
   signal en : std_logic := '0';
   signal A_1 : std_logic_vector(4 downto 0) := (others => '0');
   signal A_2 : std_logic_vector(4 downto 0) := (others => '0');
   signal A_Write : std_logic_vector(4 downto 0) := (others => '0');
   signal D : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal Q_1 : std_logic_vector(31 downto 0);
   signal Q_2 : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 30 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: register_block PORT MAP (
          clk => clk,
          we => we,
          en => en,
          A_1 => A_1,
          A_2 => A_2,
          A_Write => A_Write,
          D => D,
          Q_1 => Q_1,
          Q_2 => Q_2
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here
		
		-- x0 is zeros
		en <= '1';
		we <= '0';
		A_1 <= "00000";
		A_2 <= "00000";
		A_Write <= "00000";
		D <= x"F0F0F0F0";
		wait for 32 ns;
		assert(Q_1 = x"00000000" and Q_2 = x"00000000")
		report "Not zeros in reg x0" severity error;
		
		-- Test write to zero
		en <= '1';
		we <= '1';
		A_1 <= "00000";
		A_2 <= "00000";
		A_Write <= "00000";
		D <= x"F0F0FFFF";
		wait for 32 ns;
		assert(Q_1 = x"00000000" and Q_2 = x"00000000")
		report "x0 is not zero" severity error;
		
		-- Can write to register and read from it
		en <= '1';
		we <= '1';
		A_1 <= "00001";
		A_2 <= "00001";
		A_Write <= "00001";
		D <= x"F0F0F0F1";
		wait for 32 ns;
		assert(Q_1 = x"F0F0F0F1" and Q_2 = x"F0F0F0F1")
		report "Load into x1 failed" severity error;
		
		-- Can write to another register and read from other set register
		en <= '1';
		we <= '1';
		A_1 <= "00001";
		A_2 <= "00010";
		A_Write <= "00010";
		D <= x"F0F0F0FF";
		wait for 32 ns;
		assert(Q_1 = x"F0F0F0F1" and Q_2 = x"F0F0F0FF")
		report "Load into x2 failed" severity error;
		
		-- First en test
		en <= '0';
		we <= '0';
		A_1 <= "00011";
		A_2 <= "00110";
		A_Write <= "10010";
		D <= x"FFFFFFFF";
		wait for 32 ns;
		assert(Q_1 = x"F0F0F0F1" and Q_2 = x"F0F0F0FF")
		report "Values not held when en = 0" severity error;
		
		en <= '1';
		we <= '0';
		A_1 <= "10010";
		A_2 <= "10010";
		A_Write <= "00000";
		D <= x"FFFFFFFF";
		wait for 32 ns;
		assert(Q_1 = x"00000000" and Q_2 = x"00000000")
		report "Write occurred when en = 0" severity error;
		
		-- Test en when we = 1
		en <= '0';
		we <= '1';
		A_1 <= "00011";
		A_2 <= "00110";
		A_Write <= "10011";
		D <= x"FFFFFFFF";
		wait for 32 ns;
		assert(Q_1 = x"00000000" and Q_2 = x"00000000")
		report "Failed previous test and or not holding those values" severity error;
		
		en <= '1';
		we <= '0';
		A_1 <= "10011";
		A_2 <= "10011";
		A_Write <= "10011";
		D <= x"FFFFFFFF";
		wait for 32 ns;
		assert(Q_1 = x"00000000" and Q_2 = x"00000000")
		report "Write occurred when en = 0 and we = 1" severity error;
		
		wait;
   end process;

END;

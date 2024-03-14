--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:42:22 03/14/2024
-- Design Name:   
-- Module Name:   /home/wwu/1458226/Documents/CPTR380/RISC_V/ALU_testbench.vhd
-- Project Name:  RISC_V
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: arithmetic_logic_unit
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
--USE ieee.numeric_std.ALL;
 
ENTITY ALU_testbench IS
END ALU_testbench;
 
ARCHITECTURE behavior OF ALU_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT arithmetic_logic_unit
    PORT(
         ctrl : IN  std_logic_vector(2 downto 0);
         data1_in : IN  std_logic_vector(31 downto 0);
         data2_in : IN  std_logic_vector(31 downto 0);
         data_out : OUT  std_logic_vector(31 downto 0);
         flags : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal ctrl : std_logic_vector(2 downto 0) := (others => '0');
   signal data1_in : std_logic_vector(31 downto 0) := (others => '0');
   signal data2_in : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(31 downto 0);
   signal flags : std_logic_vector(3 downto 0);   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: arithmetic_logic_unit PORT MAP (
          ctrl => ctrl,
          data1_in => data1_in,
          data2_in => data2_in,
          data_out => data_out,
          flags => flags
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here
		
		ctrl <= "000"; -- ADD
		data1_in <= x"DEADBEEF";
		data2_in <= x"FEEBDAED";
		wait for 20 ns;
		assert (data_out = x"DD9999DC")
		report "Test failed for ADD" severity error;
		
		ctrl <= "001"; -- SLL
		data1_in <= x"DEADBEEF";
		data2_in <= x"00000004";
		wait for 20 ns;
		assert (data_out = x"EADBEEF0")
		report "Test failed for SLL" severity error;
		
		ctrl <= "010"; -- SUB
		data1_in <= x"DEADBEEF";
		data2_in <= x"10000001";
		wait for 20 ns;
		assert (data_out = x"CEADBEEE")
		report "Test failed for SUB" severity error;
		
		ctrl <= "011"; -- SRA
		data1_in <= x"DEADBEEF";
		data2_in <= x"00000008";
		wait for 20 ns;
		assert (data_out = x"FFDEADBE")
		report "Test failed for SRA" severity error;
		
		ctrl <= "100"; -- XOR
		data1_in <= x"DEADBEEF";
		data2_in <= x"F0F0F0F0";
		wait for 20 ns;
		assert (data_out = x"2E5D4E1F")
		report "Test failed for XOR" severity error;
		
		ctrl <= "101"; -- SRL
		data1_in <= x"DEADBEEF";
		data2_in <= x"00000008";
		wait for 20 ns;
		assert (data_out = x"00DEADBE")
		report "Test failed for SRL" severity error;
		
		ctrl <= "110"; -- OR
		data1_in <= x"DEADBEEF";
		data2_in <= x"F0F0F0F0";
		wait for 20 ns;
		assert (data_out = x"FEFDFEFF")
		report "Test failed for OR" severity error;
		
		ctrl <= "111"; -- AND
		data1_in <= x"DEADBEEF";
		data2_in <= x"F0F0F0F0";
		wait for 20 ns;
		assert (data_out = x"D0A0B0E0")
		report "Test failed for AND" severity error;
		
		ctrl <= "000"; -- Test comparision 1
		data1_in <= x"FFFFFFFF";
		data2_in <= x"FFFFFFFF";
		wait for 20 ns;
		assert (flags = "0000")
		report "Test failed for comparison 1" severity error;
		
		ctrl <= "001"; -- Test comparision 2
		data1_in <= x"0FFFFFFF";
		data2_in <= x"00FFFFFF";
		wait for 20 ns;
		assert (flags = "1010")
		report "Test failed for comparison 2" severity error;
		
		ctrl <= "000"; -- Test comparision 3
		data1_in <= x"FFFFFFFF";
		data2_in <= x"00000001";
		wait for 20 ns;
		assert (flags = "0110")
		report "Test failed for comparison 3" severity error;
		
		ctrl <= "010"; -- Test comparision 4
		data1_in <= x"00000001";
		data2_in <= x"FFFFFFF0";
		wait for 20 ns;
		assert (flags = "1001")
		report "Test failed for comparison 4" severity error;
		
		ctrl <= "010"; -- Test comparision 5
		data1_in <= x"FFFFFFFE";
		data2_in <= x"FFFFFFFF";
		wait for 20 ns;
		assert (flags = "0101")
		report "Test failed for comparison 5" severity error;
		
		ctrl <= "010"; -- Test comparision 6
		data1_in <= x"FFFFFFFE";
		data2_in <= x"FFFFFFF0";
		wait for 20 ns;
		assert (flags = "1010")
		report "Test failed for comparison 6" severity error;

      wait;
   end process;

END;

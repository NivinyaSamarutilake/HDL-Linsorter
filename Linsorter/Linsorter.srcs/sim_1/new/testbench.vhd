library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.All;

entity testbench is
end testbench;

architecture Behavioral of testbench is
    constant CLK_PERIOD : time := 10 ns;  
    signal clk, reset, clear, mode, read_inpt, write_inpt : std_logic;
    signal value, sorted_outpt : std_logic_vector(7 downto 0);
    
begin
-- Instantiate the Sorter module
    UUT: entity work.Sorter
      generic map (N => 8)
      port map (
        clk => clk,
        reset => reset,
        clear => clear,
        read_inpt => read_inpt,
        write_inpt => write_inpt,
        value => value,
        sorted_outpt => sorted_outpt,
        mode => mode
      );

    -- Clock generation process
    clk_gen: process
    begin
      while now < 1000 ns loop
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
      end loop;
      wait;
    end process;

    -- Stimulus process
    stimulus: process
    begin
      reset <= '1';
      wait for 5 * CLK_PERIOD;
      reset <= '0';
      wait for 5 * CLK_PERIOD;

      -- Test set 
      write_inpt <= '1';
      read_inpt <= '0';
      mode <= '0';
      
      value <= "11001010";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      
      value <= "00110101";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      
      value <= "10101010";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      
      value <= "01111000";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      
      value <= "01010101";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      
      value <= "01011101";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      
      value <= "01010101";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      
      value <= "10111000";
      wait for CLK_PERIOD;
      report "Input given " & integer'image(conv_integer(value));
      

      -- Read sorted data
      write_inpt <= '0';
      read_inpt <= '1';
      wait for 10 * CLK_PERIOD;
      
      -- End simulation
      wait;
    end process;



end Behavioral;

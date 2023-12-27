library IEEE;
use IEEE.std_logic_1164.All;
use IEEE.std_logic_unsigned.All;

entity Sorter is 
generic (N: natural:=8);
Port(
    clk: in std_logic;
    reset: in std_logic;
    mode: in std_logic; -- a signal to indicate which sorting order is required : ascending (0) or descending (1)
    read_inpt: in std_logic; -- a signal to indicate that input reading is complete
    write_inpt: in std_logic; -- a signal to write the input to "inpt_list"
    value: in std_logic_vector (7 downto 0);  -- the data to be sorted
    
    sorted_outpt: out std_logic_vector (7 downto 0); -- the sorted values output 
    clear: out std_logic 
);
end Sorter;


architecture Behavioral of Sorter is

type data_list is array (0 to N-1) of std_logic_vector (7 downto 0);
signal inpt_list: data_list;   -- the array of input data (FIFO)
signal inpt_list_cpy: data_list; -- a copy of inpt_list
signal data_count: natural;    -- counter to keep track of the number of input data
signal write_inpt_flag1, write_inpt_flag2: std_logic; -- to implement one clock cycle delay to capture the rising edge of "write_inpt" signal.
signal scores_list: data_list;  -- list to keep track of all the scores for all input data
signal array_sorted: data_list; -- the sorted array of data 
signal stage1, stage2: std_logic_vector (2 downto 0); -- to keep track of the states of processes at each stage
signal wait_count, out_count: integer; -- counters
signal fin_send, fin_sort, fin_compare, fin_comp_flag1, fin_comp_flag2: std_logic; 
-- 'fin_comp_flag1' and 'fin_comp_flag2' are used to detect the rising edge of the "fin_compare" signal
-- 'fin_sort' is used to signal that the sorting is done, and the next sequence can proceed
-- 'fin_send' signals that the output has been sent

begin 

-- "EnterData" is the process to read and store input values into inpt_list
-- When a rising edge on the write_inpt signal is detected,
-- a value will be read from the input medium and the data_count will be incremented

EnterData: process(clk, reset)
begin
    if (reset = '1') then
        inpt_list <= (others=> (others=>'0'));
        data_count <= 0;
    elsif (clk'event and clk = '1') then
        if (write_inpt = '1') then 
            inpt_list(data_count) <= value;
            data_count <= data_count + 1;
        else
            data_count <= data_count;
            inpt_list <= inpt_list;
        end if;
    end if;
end process;


-- The "CompareData" process is where the parallel processing of data happens 
-- This is a process with 3 states.

-- state 1 : the score and other variables are reset to 0
-- state 2 : the data in inpt_list_cpy are compared in parallel 
-- state 3 : waits for 5 clock cycles to let the next process finish

CompareData:process(clk, reset)

variable score:data_list;

begin
    if (reset= '1') then
        score := (others=>(others=> '0'));
        inpt_list_cpy <= (others=>(others=>'0'));
        scores_list <= (others=>(others=>'0'));
        write_inpt_flag1 <= '0';
        write_inpt_flag2 <= '0';
        fin_compare <= '0';
        stage1 <= "000";
        wait_count <= 0;
        
    elsif (clk'event and clk='1') then
        write_inpt_flag1 <= write_inpt;
        write_inpt_flag2 <= write_inpt_flag1;
        inpt_list_cpy <= inpt_list;
        
        case(stage1) is
        when("000") =>
            if (write_inpt_flag1 = '0' and write_inpt_flag2 = '1') then
                stage1 <= "001";
                report "Sorting will begin";
            else
                stage1 <= "000";
            end if;
        when ("001") =>
            L1: for i in 0 to 7 loop 
                L2: for j in 0 to 7 loop 
                    next L1 when j=data_count;
                    if (mode = '0') then
                        if (inpt_list_cpy(i) < inpt_list_cpy(j)) then
                            score(i) := score(i) + 0;
                        elsif (inpt_list_cpy(i) = inpt_list_cpy(j)) then
                            if (i < j) then
                                score(i) := score(i) + 0;
                            else
                                score(i) := score(i) + 1;
                            end if;
                        else
                            score(i) := score(i) + 1;
                        end if;
                    else
                        if (inpt_list_cpy(i) > inpt_list_cpy(j)) then
                            score(i) := score(i) + 0;
                        elsif (inpt_list_cpy(i) = inpt_list_cpy(j)) then
                            if (i < j) then
                                score(i) := score(i) + 0;
                            else
                                score(i) := score(i) + 1;
                            end if;
                        else
                            score(i) := score(i) + 1;
                        end if;
                    end if;
                    
                end loop L2;
            end loop L1;
            stage1 <= "010";
            fin_compare <= '1';
            scores_list <= score;
        when ("010") =>
            if (wait_count > 5) then
                fin_compare <= '0';
                scores_list <= (others=> (others => '0'));
                score := (others=>(others => '0'));
                wait_count <= 0;
                stage1 <= "000";
            else
                wait_count <= wait_count + 1;
                stage1 <= "010";
            end if;
        when others =>
            score := score;
        end case;
    end if;
end process;


-- "SortData" is the process to place the input values in the sorted array 
-- according to the score for each value

SortData: process(clk, reset)
variable addr: integer;
begin
    if (reset = '1') then
        array_sorted <= (others=> (others=>'0'));
        fin_sort <= '0';
        fin_comp_flag1 <= '0';
        fin_comp_flag2 <= '0';
    elsif (clk'event and clk = '1') then
        fin_comp_flag1 <= fin_compare;
        fin_comp_flag2 <= fin_comp_flag1;
        if (fin_comp_flag2 = '0' and fin_comp_flag1 = '1') then
            for k in 0 to 7 loop
                addr := conv_integer (scores_list(k));
                array_sorted(addr-1) <= inpt_list_cpy(k);
            end loop;
            fin_sort <= '1';
        else
            array_sorted <= array_sorted;
            fin_sort <= '0';
        end if;
    end if;
end process;  


-- "OutputData" is the process to output the sorted data
-- There are 3 states in this process
-- state 000 : waits for sort_data signal to be set to 1  
-- state 001 : waits for read_inpt signal to be set to 1
-- state 010 : writes the contents of array_sorted onto sorted_outpt, one number per each clock cycle
--             when all data are written, sets 'fin_send' and 'clear' signals to 1
-- state 011 : resets the state machine for next sorting sequence    

OutputData: process(clk, reset)
begin
    if (reset = '1') then
        stage2 <= "000";
        out_count <= 0;
        fin_send <= '0';
        clear <= '0';
        sorted_outpt <= (others =>'0');
            
    elsif (clk'event and clk = '1') then
        case(stage2) is
            when("000") => 
                if (fin_sort = '1') then
                    stage2 <= "001";
                    clear <= '0';
                else
                    stage2 <= "000";
                end if;
            when("001") =>
                if (read_inpt = '1') then
                    stage2 <= "010";
                else
                    stage2 <= "001";
                end if;
            when ("010") =>
                if (out_count = data_count) then
                    stage2 <= "011";
                    fin_send <= '1';
                    clear <= '1';
                    out_count <= 0;
                    
                else
                    sorted_outpt <= array_sorted(out_count);
                    report "sorted " & integer'image(conv_integer(array_sorted(out_count)));
                    out_count <= out_count + 1;
                end if;
                
            when ("011") =>
                fin_send <= '0';
                stage2 <= "000"; 
            when others =>
                stage2 <= "000";
            end case;

    end if;
end process;

end Behavioral;           

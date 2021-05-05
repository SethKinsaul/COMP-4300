-- dlx_datapath.vhd
-- Seth Kinsaul (smk0036@auburn.edu)
-- Lab Assignment 4

package dlx_types is
  subtype dlx_word is bit_vector(31 downto 0); 
  subtype half_word is bit_vector(15 downto 0); 
  subtype byte is bit_vector(7 downto 0); 

  subtype alu_operation_code is bit_vector(3 downto 0); 
  subtype error_code is bit_vector(3 downto 0); 
  subtype register_index is bit_vector(4 downto 0);

  subtype opcode_type is bit_vector(5 downto 0);
  subtype offset26 is bit_vector(25 downto 0);
  subtype func_code is bit_vector(5 downto 0);
end package dlx_types; 

use work.dlx_types.all; 
use work.bv_arithmetic.all;  

entity alu is
     generic(prop_delay: Time := 5 ns); 
     port(operand1, operand2: in dlx_word; operation: in alu_operation_code; 
          signed: in bit; result: out dlx_word; error: out error_code); 
end entity alu; 

architecture behavior of ALU is
signal operand1_int: integer; -- conversion to int
signal operand2_int: integer; -- conversion to int 
begin
	ALUPROCESS : process(operation,operand1,operand2,signed) is
	Variable res : dlx_word;
	Variable overflow : boolean;
	Variable and_operator : dlx_word;
	Variable or_operator: dlx_word;
	begin
	-- 4-bit to select ALU operation
	case operation is
	 when "0000" =>  
	   error <= "0000"; -- no error
	   if signed = '1' then
	        bv_add(operand1,operand2,res,overflow); -- ADD
	   	result <= res after prop_delay;
		if overflow = True then
		error <= "0001" after prop_delay;
		end if;
	   else
	        bv_addu(operand1,operand2,res,overflow); -- ADDU
		result <= res after prop_delay;
		if overflow = True then
		error <= "0001" after prop_delay;
		end if;
		end if;
	 when "0001" =>
	    error <= "0000"; -- no error
	    if signed = '1' then
		bv_sub(operand1,operand2,res,overflow); -- SUB
		result <= res after prop_delay;
		if overflow = True then 
		error <= "0001" after prop_delay;
		end if;
	     else 
		bv_subu(operand1,operand2,res,overflow); --SUBU
		result <= res after prop_delay;
		if overflow = True then
		error <= "0001" after prop_delay;
		end if;
		end if;
	 when "0010" =>
		for i in 0 to 31 loop 			 -- AND
		if operand1(i) = '1' then
		   if operand2(i) = '1' then
			and_operator(i) := '1'; 
		end if;
		end if;
		end loop;
		result <= and_operator after prop_delay;
	 when "0011" =>
	        for i in 0 to 31 loop   		 -- OR
		if operand1(i) = '1' then
		or_operator(i) := '1';
		end if;
		if operand2(i) = '1' then
		or_operator(i) := '1';
		end if;
		end loop;
		result <= or_operator after prop_delay;
	 when "0100" =>
	   result <= "00000000000000000000000000000100" after prop_delay;
	 when "0101" =>
	   result <= "00000000000000000000000000000101" after prop_delay;
	 when "0110" =>
	   result <= "00000000000000000000000000000110" after prop_delay;
	 when "0111" =>
	   result <= "00000000000000000000000000000111" after prop_delay;
	 when "1000" =>
	   result <= "00000000000000000000000000001000" after prop_delay;
	 when "1001" =>
	   result <= "00000000000000000000000000001001" after prop_delay;
	 when "1010" =>
	   result <= "00000000000000000000000000001010" after prop_delay;
	 when "1011" =>
	   operand1_int <= bv_to_integer(operand1); 	-- SLT
	   operand2_int <= bv_to_integer(operand2); 
	   if operand1_int < operand2_int then
		result <= "00000000000000000000000000000001" after prop_delay;
	   else 
		result <= "00000000000000000000000000000000" after prop_delay;
	   end if;
	 when "1100" =>
	   result <= "00000000000000000000000000001100" after prop_delay;
	 when "1101" =>
	   result <= "00000000000000000000000000001101" after prop_delay;
	 when "1110" =>
	   error <= "0000";
	   if signed = '1' then				 -- MULT
	        bv_mult(operand1,operand2,res,overflow);
	   	result <= res after prop_delay;
		if overflow = True then
		error <= "0001" after prop_delay;
		end if;
	   else
	        bv_multu(operand1,operand2,res,overflow);-- MULTU
		result <= res after prop_delay;
		if overflow = True then
		error <= "0001" after prop_delay;
		end if;
		end if;
	 when "1111" =>
	   result <= "00000000000000000000000000001111" after prop_delay;
	 when others =>
	   error <= "0001"; -- not a viable operation selection
	end case;

end process;

end architecture behavior;

use work.dlx_types.all; 

entity mips_zero is
  
  port (
    input  : in  dlx_word;
    output : out bit);

end mips_zero;

architecture behavior of mips_zero is
begin
	comb_logic: process(input)
	begin
		if (input = "00000000000000000000000000000000") then
		   output <= '1' after 5 ns;
		else
		   output <= '0' after 5 ns;
		end if;
	end process comb_logic;
end architecture behavior;

use work.dlx_types.all; 

entity mips_register is
     port(in_val: in dlx_word; clock: in bit; out_val: out dlx_word);
end entity mips_register;

architecture behavior of mips_register is

begin
	MIPSPROCESS : process(in_val, clock) is
	begin
	
	if clock = '1' then 
	   out_val <= in_val after 5 ns;
	end if;
end process MIPSPROCESS;
end architecture behavior;

use work.dlx_types.all; 

entity mips_bit_register is
     port(in_val: in bit; clock: in bit; out_val: out bit);
end entity mips_bit_register;

architecture behavior of mips_register is

begin
	MIPSPROCESS : process(in_val, clock) is
	begin
	
	if clock = '1' then 
	   out_val <= in_val after 5 ns;
	end if;
end process MIPSPROCESS;
end architecture behavior;

use work.dlx_types.all; 

entity mux is
     port (input_1,input_0 : in dlx_word; which: in bit; output: out dlx_word);
end entity mux;

architecture behavior of mux is

begin	
	MUX : process(input_1,input_0,which) is
	begin

	if which = '1' then
	   output <= input_1 after 5 ns;
	end if;
	if which = '0' then
	   output <= input_0 after 5 ns;
	end if;
end process MUX;
end architecture behavior;

use work.dlx_types.all;

entity index_mux is
     port (input_1,input_0 : in register_index; which: in bit; output: out register_index);
end entity index_mux;

architecture behavior of index_mux is

begin	
	MUX : process(input_1,input_0,which) is
	begin

	if which = '1' then
	   output <= input_1 after 5 ns;
	end if;
	if which = '0' then
	   output <= input_0 after 5 ns;
	end if;
end process MUX;
end architecture behavior;

use work.dlx_types.all;

entity sign_extend is
     port (input: in half_word; signed: in bit; output: out dlx_word);
end entity sign_extend;

architecture behavior of sign_extend is

begin
	SIGNEXTEND : process(input) is 
	variable upper : half_word;
	begin
	for i in 0 to input'high loop
	   if i = 15 and input(i) = '0' then
		upper := "0000000000000000";
	   	output <= upper & input after 5 ns;
	   elsif i = 15 and input(i) = '1' then
		upper := "1111111111111111";
	   	output <= upper & input after 5 ns;
	end if;
	   end loop;
end process SIGNEXTEND;
end architecture behavior;

use work.dlx_types.all; 
use work.bv_arithmetic.all; 

entity add4 is
    port (input: in dlx_word; output: out dlx_word);
end entity add4;

architecture behavior of add4 is

begin	
	PCINCREMENT : process(input) is
	variable new_pc: dlx_word;
	variable error: boolean;
	begin
	bv_addu(input,"00000000000000000000000000000100",new_pc,error);
	output <= new_pc after 5 ns;

end process PCINCREMENT;
end architecture behavior;
 
use work.dlx_types.all;
use work.bv_arithmetic.all;  

entity regfile is
     port (read_notwrite,clock : in bit; 
           regA,regB: in register_index; 
	   data_in: in  dlx_word; 
	   dataA_out,dataB_out: out dlx_word
	   );
end entity regfile; 

architecture behavior of regfile is
	type reg_type is array (0 to 31) of dlx_word;
begin	
	REGISTERFILE : process(read_notwrite,clock,regA,regB,data_in) is
	variable registers: reg_type;
	begin
	
	if clock = '1' then
	   if read_notwrite = '1' then -- read operation
		dataA_out <= registers(bv_to_integer(regA)) after 5 ns;
		dataB_out <= registers(bv_to_integer(regB)) after 5 ns;
	   else 	               -- write operation
		registers(bv_to_integer(regA)) := data_in;
	   end if;
	end if;
end process REGISTERFILE;
end architecture behavior;

use work.dlx_types.all;
use work.bv_arithmetic.all;

entity DM is
  
  port (
    address : in dlx_word;
    readnotwrite: in bit; 
    data_out : out dlx_word;
    data_in: in dlx_word; 
    clock: in bit); 
end DM;

architecture behaviour of DM is

begin  -- behaviour

  DM_behav: process(address,clock) is
    type memtype is array (0 to 1024) of dlx_word;
    variable data_memory : memtype;
  begin
    -- fill this in by hand to put some values in there
    data_memory(1023) := B"00000101010101010101010101010101";
    data_memory(0) := B"00000000000000000000000000000001";
    data_memory(1) := B"00000000000000000000000000000010";
    if clock'event and clock = '1' then
      if readnotwrite = '1' then
        -- do a read
        data_out <= data_memory(bv_to_natural(address)/4);
      else
        -- do a write
        data_memory(bv_to_natural(address)/4) := data_in; 
      end if;
    end if;


  end process DM_behav; 

end behaviour;

use work.dlx_types.all;
use work.bv_arithmetic.all;

entity IM is
  
  port (
    address : in dlx_word;
    instruction : out dlx_word;
    clock: in bit); 
end IM;

architecture behaviour of IM is

begin  -- behaviour

  IM_behav: process(address,clock) is
    type memtype is array (0 to 1024) of dlx_word;
    variable instr_memory : memtype;                   
  begin
    -- fill this in by hand to put some values in there
    -- first instr is 'LW R1,4092(R0)' 
    instr_memory(0) := B"10001100000000010000111111111100";
    -- next instr is 'ADD R2,R1,R1'
    instr_memory(1) := B"00000000001000010001000000100000";
    -- next instr is SW R2,8(R0)'
    instr_memory(2) := B"10101100000000100000000000001000";
    -- next instr is LW R3,8(R0)'
    instr_memory(3) := B"10001100000000110000000000001000"; 

    -- ADDUI
    -- $t = $s + imm; advance_pc (4);
    -- addui $t, $s, imm
    -- 1 + 1 = aluA_mux_out = 2
    instr_memory(4) := B"00101000001000010000000000000001"; -- add it to itself back into R2
                      -- 001010/00001/00001/0000000000000001              
    -- SUB 
    -- $d = $s - $t; advance_pc (4);
    -- sub $d, $s, $t
    -- 1 - 1 = alu_result = 0
    instr_memory(5) := B"00000000001000010001000000100010"; -- subtract
                      -- 000000/00001/00001/00001/00000100010       
    -- SUBI
    -- $t = $s + imm; advance_pc (4);
    -- addi $t, $s, imm
    -- 1 - 1 = aluA_result = 0
    instr_memory(6) := B"00000000001000010000000000000001"; -- add it to itself back into R2
                      -- 000000/00001/00001/0000000000000001                
    -- SUBU
    -- next instr is 'SUBU R1,R2,R1'
	  -- 1 - 1 = alu_result = 0
    instr_memory(7) := B"00000000001000010000100000100011"; -- 
                      -- 000000/00001/00001/00001/00000100011              
    -- MUL
    -- $LO = $s * $t; advance_pc (4);
    -- mulu $s, $t
	  -- 1 * 3 = alu_result = 3
    instr_memory(8) := B"00000000011000010000000000011000"; -- 
                      -- 000000/00011/00001/00000/0000 0000 0001 1000
    -- MULU
    -- $LO = $s * $t; advance_pc (4);
    -- mulu $s, $t
	  -- 1 * 3 = alu_result = 2
    instr_memory(9) := B"00000000011000010000100000011001"; -- 
                      -- 000000/00011/00001/00010/00000011001    
    -- AND
    -- $d = $s & $t; advance_pc (4);
    -- and $d, $s, $t
    instr_memory(10) := B"00000011111111110001000000100000"; 
                      --  000000/11111/11111/00010/00000100000
    -- ANDI
    -- $t = $s & imm; advance_pc (4);
    -- andi $t, $s, imm
    instr_memory(11) := B"00100011111000000000001010101010"; 
                      --  001000/11111/11111/11111111111111       
    -- OR
    -- next instr is 'OR R1,R2,R1'
    instr_memory(12) := B"00000011111000000001000000100101"; 
                      --  000000/11111/00000/00010/00000100101      
    -- SLT
    -- next instr is 'SLT R1,R2,R1'
    instr_memory(13) := B"00000000001000010001000000101010"; 
                      --  000000/00001/00001/00010/00000101010
    -- SLTU
    -- next instr is 'SLTU R1,R2,R1'
    instr_memory(14) := B"00000000001000010001000000101011"; 
                      --  000000/00001/00001/00010/00000101011              
    -- SW
    -- next instr is SW R2,8(R0)'
    instr_memory(15) := B"10101100000000100000000000001000";
    

    if clock'event and clock = '1' then
        -- do a read
        instruction <= instr_memory(bv_to_natural(address)/4);
    end if;
  end process IM_behav; 

end behaviour;








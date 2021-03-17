-- Seth Kinsaul (smk0036@auburn.edu)
-- Lab Assignment 2
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity ALU is 
	generic(prop_delay: Time := 5 ns);
	port(operand1,operand2: in dlx_word; operation:in
		alu_operation_code;
		signed:in bit;
		result: out dlx_word;error:out error_code);
end entity ALU;

architecture behavior1 of ALU is
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

end architecture behavior1;
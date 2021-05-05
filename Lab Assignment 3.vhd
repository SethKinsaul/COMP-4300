-- Seth Kinsaul (smk0036@auburn.edu)
-- Lab Assignment 3
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity mips is 
	generic(prop_delay: Time := 5 ns);
	port(in_val: in dlx_word; clock: in bit; out_val: out dlx_word);
end entity mips;

architecture thirty_two_bit_register of mips is

begin
	MIPSPROCESS : process(in_val, clock) is
	begin
	
	if clock = '1' then 
	   out_val <= in_val after prop_delay;
	end if;
end process MIPSPROCESS;
end architecture thirty_two_bit_register;

use work.dlx_types.all;
entity mux is
	generic(prop_delay: Time := 5 ns);
	port(input_1,input_0 : in dlx_word; which: in bit;
output: out dlx_word);
end entity mux;

architecture thirty_two_bit_two_way_multiplexer of mux is

begin	
	MUX : process(input_1,input_0,which) is
	begin

	if which = '1' then
	   output <= input_1 after prop_delay;
	end if;
	if which = '0' then
	   output <= input_0 after prop_delay;
	end if;
end process MUX;
end architecture thirty_two_bit_two_way_multiplexer;

use work.dlx_types.all;
use work.bv_arithmetic.all;
entity sign_extend is
	generic(prop_delay: Time := 5 ns);
	port(input: in half_word; output: out dlx_word);
end entity sign_extend;

architecture sign_extender of sign_extend is

begin
	SIGNEXTEND : process(input) is 
	variable upper : half_word;
	begin
	for i in 0 to input'high loop
	   if i = 15 and input(i) = '0' then
		upper := "0000000000000000";
	   	output <= upper & input after prop_delay;
	   elsif i = 15 and input(i) = '1' then
		upper := "1111111111111111";
	   	output <= upper & input after prop_delay;
	end if;
	   end loop;
end process SIGNEXTEND;
end architecture sign_extender;

use work.dlx_types.all;
use work.bv_arithmetic.all;
entity add4 is
	generic(prop_delay: Time := 5 ns);
	port(input : in dlx_word; output: out dlx_word);
end entity add4;

architecture pc_incrementer of add4 is

begin	
	PCINCREMENT : process(input) is
	variable new_pc: dlx_word;
	variable error: boolean;
	begin
	bv_addu(input,"00000000000000000000000000000100",new_pc,error);
	output <= new_pc after prop_delay;

end process PCINCREMENT;
end architecture pc_incrementer;

use work.dlx_types.all;
use work.bv_arithmetic.all;
entity regfile is 
	generic(prop_delay: Time := 5 ns);
	port (read_notwrite,clock : in bit;
regA,regB: in register_index;
data_in: in dlx_word;
dataA_out,dataB_out: out dlx_word
);
end entity regfile;

architecture register_file of regfile is
	type reg_type is array (0 to 31) of dlx_word;
begin	
	REGISTERFILE : process(read_notwrite,clock,regA,regB,data_in) is
	variable registers: reg_type;
	begin
	
	if clock = '1' then
	   if read_notwrite = '1' then -- read operation
		dataA_out <= registers(bv_to_integer(regA)) after prop_delay;
		dataB_out <= registers(bv_to_integer(regB)) after prop_delay;
	   else 	               -- write operation
		registers(bv_to_integer(regA)) := data_in;
	   end if;
	end if;
end process REGISTERFILE;
end architecture register_file;

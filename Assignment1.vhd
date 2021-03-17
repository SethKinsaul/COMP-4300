-- Seth Kinsaul (smk0036@auburn.edu)
-- Assignment 1
entity xorGate is
	generic(prop_delay: Time := 10 ns);
	port(a_in,b_in: in bit;
		result: out bit);
end entity xorGate;

architecture behavior1 of xorGate is
begin
	xorProcess : process(a_in,b_in) is

	begin 
		if a_in = '1' then
		  if b_in = '0' then
		    --1 and 1 = 0
		    result <= '1' after prop_delay;
		  else
		    -- 0 and 1 = 1
		    result <= '0' after prop_delay;
		  end if;
		else
		  if b_in = '1' then
		    -- 1 and 1 = 0 
                    result <= '1' after prop_delay;
		  else 
		    -- 0 and 0 = 0
		    result <= '0' after prop_delay;
		  end if;
		end if;
	end process xorProcess;
end architecture behavior1;		    
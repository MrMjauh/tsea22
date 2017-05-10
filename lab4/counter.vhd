--------------------------------------
-- Counter 
--------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------

entity counter is
port(	
      CLK, CLR: in std_logic;
      LOAD : in std_logic;	
      EN_T : in std_logic;
      EN_P : in std_logic;
      LOAD_VALUE : in std_logic_vector(7 downto 0);	
      COUNT_TO : in std_logic_vector(7 downto 0);
      RCO : out std_logic;
      DATA: out std_logic_vector(7 downto 0));
end entity;  

--------------------------------------

architecture rtl of counter is
  
signal Q_int:unsigned(7 downto 0) := (others => '0'); 

begin
process(CLK,CLR)
  begin
    if (CLR='1') then
      Q_int <= "00000000";
      RCO <= '0';	
    elsif rising_edge(CLK) then
    	if LOAD = '1' then
		RCO <= '0';
		Q_int <= unsigned(LOAD_VALUE);
	elsif EN_T = '1' and EN_P = '1' then
   	 	if Q_int = unsigned(COUNT_TO) then
			Q_int <= "00000000";
			RCO <= '1';
 	   	else
			Q_int <= Q_int + 1;
			RCO <= '0';
    		end if;
	end if;
    end if;
end process;

DATA <= std_logic_vector(Q_int);

end rtl;


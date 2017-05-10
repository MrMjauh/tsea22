--------------------------------------
-- Counter 
--------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------

entity ripple_ctrs is
port(	
      CLK: in std_logic; 
      RCO : out std_logic;
      SEC_VAL,MIN_VAL : out std_logic_vector(7 downto 0));	
end entity;  

--------------------------------------

architecture rtl of ripple_ctrs is
component counter
	PORT(
		CLK : in std_logic;
		CLR : in std_logic;
      		LOAD : in std_logic;	
      		LOAD_VALUE : in std_logic_vector(7 downto 0);	
      		COUNT_TO : in std_logic_vector(7 downto 0);
      		RCO : out std_logic;
      		DATA: out std_logic_vector(7 downto 0)
	);
end component;
signal SEC_RCO : std_logic := '0';
signal MIN_RCO : std_logic := '0';
--
begin
	sec_ctr : counter 		
	port map (
		CLK => CLK,
		CLR => '0',
		COUNT_TO => "01000000",
		LOAD_VALUE => "00000000",
		LOAD => '0',
		RCO => SEC_RCO,
		DATA => SEC_VAL
	);

	min_ctr : counter
	port map (
		CLK => SEC_RCO,
		CLR => '0',
		COUNT_TO => "01000000",
		LOAD_VALUE => "00000000",
		LOAD => '0',
		RCO => MIN_RCO,
		DATA => MIN_VAL
	);

	RCO <= SEC_RCO;
end rtl;


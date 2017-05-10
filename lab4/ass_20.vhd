--------------------------------------
-- Counter 
--------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------

entity ass_20 is
port(	
      CLK, SEC_CLK,MUX_CLK: in std_logic;
      BTN_START_STOP,BTN_RESET : in std_logic;
      LED_START_STOP,LED2 : out std_logic;
      MUX_SELECTION : out unsigned(1 downto 0);
      MUX_VALUE : out std_logic_vector(7 downto 0));	 
end entity;  

--------------------------------------

architecture rtl of ass_20 is
component counter
	PORT(
		CLK : in std_logic;
		EN_T : in std_logic;
		EN_P : in std_logic;
		CLR : in std_logic;
      		LOAD : in std_logic;	
      		LOAD_VALUE : in std_logic_vector(7 downto 0);	
      		COUNT_TO : in std_logic_vector(7 downto 0);
      		RCO : out std_logic;
      		DATA: out std_logic_vector(7 downto 0)
	);
end component;
-- Counter specific
signal ce : std_logic := '0';
signal load : std_logic := '0';

signal sec_rco_left,sec_rco_right,min_rco_left,min_rco_right : std_logic := '0';
signal sec_val_left,sec_val_right,min_val_left,min_val_right : std_logic_vector(7 downto 0) := (others => '0');


-- One pulse signal variables
signal start_stop_btn_state : std_logic := '0';
signal start_stop_btn_pulse : std_logic := '0';
signal reset_btn_state : std_logic := '0';
signal reset_btn_pulse : std_logic := '0';
signal is_running : std_logic := '0';
signal mux_state : std_logic := '0';
signal mux_pulse : std_logic := '0';
signal sec_state : std_logic := '0';
signal sec_pulse : std_logic := '0';

-- Mux counter
signal mux_signal : unsigned(1 downto 0) := (others => '0');
--
begin
	sec_ctr_right : counter		
	port map (
		CLK => CLK,
		EN_T => sec_pulse,
		EN_P => ce,
		CLR => '0',
		LOAD => load,
		LOAD_VALUE => "00000000",
		COUNT_TO => "00001010",
		RCO => sec_rco_right,
		DATA => sec_val_right
	);

	sec_ctr_left : counter		
	port map (
		CLK => CLK,
		EN_T => sec_rco_right,
		EN_P => ce,
		CLR => '0',
		LOAD => load,
		LOAD_VALUE => "00000000",
		COUNT_TO => "00000100",
		RCO => sec_rco_left,
		DATA => sec_val_left
	);

	min_ctr_right : counter		
	port map (
		CLK => CLK,
		EN_T => sec_rco_left,
		EN_P => ce,
		CLR => '0',
		LOAD => load,
		LOAD_VALUE => "00000000",
		COUNT_TO => "00001010",
		RCO => min_rco_right,
		DATA => min_val_right
	);

	min_ctr_left : counter		
	port map (
		CLK => CLK,
		EN_T => min_rco_right,
		EN_P => ce,
		CLR => '0',
		LOAD => load,
		LOAD_VALUE => "00000000",
		COUNT_TO => "00000100",
		RCO => min_rco_left,
		DATA => min_val_left
	);


	process(CLK) begin
	if rising_edge(CLK) then	
		if mux_pulse = '1' then
			mux_signal <= mux_signal + 1;
		end if;
	end if;
	end process;
	MUX_VALUE <= 	sec_val_right when mux_signal = "00" else
			sec_val_left when mux_signal = "01" else
			min_val_right when mux_signal = "10" else
			min_val_left;
	MUX_SELECTION <= mux_signal;

	-- One pulse signals from input
	process(CLK)
	begin
		if rising_edge(CLK) then
			if BTN_START_STOP = '1' and start_stop_btn_state = '0' then
				start_stop_btn_pulse <= '1';
			else
				start_stop_btn_pulse <= '0';
			end if;
			start_stop_btn_state <= BTN_START_STOP;

			if BTN_RESET = '1' and reset_btn_state = '0' then			
				reset_btn_pulse <= '1';	
			else
				reset_btn_pulse <= '0';
			end if;
			reset_btn_state <= BTN_RESET;

			if mux_state = '0' and MUX_CLK = '1' then
				mux_pulse <= '1';
			else
				mux_pulse <= '0';
			end if;
			mux_state <= MUX_CLK;

			if sec_state = '0' and SEC_CLK = '1' then
				sec_pulse <= '1';
			else
				sec_pulse <= '0';
			end if;
			sec_state <= SEC_CLK;
		end if;
	end process;

	-- The stopwatch
	process(CLK)
	begin
		if rising_edge(CLK) then
			-- stop the time
			if is_running = '1' and start_stop_btn_pulse = '1' then
				is_running <= '0';
				ce <= '0';
				load <= '0';
			-- start the time
			elsif is_running = '0' and start_stop_btn_pulse = '1' then
				CE <= '1';
				is_running <= '1';
				load <= '0';
			-- reset it
			end if;
			
			if RESET_BTN_PULSE = '1' then
				load <= '1';
				ce <= '0';
				is_running <= '0';
			else
				load <= '0';
			end if; 
		end if;
	end process;
	LED_START_STOP <= is_running;
end rtl;


--------------------------------------
-- Counter 
--------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------

entity ass_20 is
port(	
      CLK, MILLI_CLK,MUX_CLK: in std_logic;
      BTN_START_STOP,BTN_RESET : in std_logic;	
      LED_START_STOP,LED2 : out std_logic;
      DISPLAY_SELECTION : in std_logic;
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

signal milli_rco_right,milli_rco_left,sec_rco_left,sec_rco_right,min_rco_left,min_rco_right : std_logic := '0';
signal milli_val_right,milli_val_left,sec_val_left,sec_val_right,min_val_left,min_val_right : std_logic_vector(7 downto 0) := (others => '0');


-- One pulse signal variables
signal start_stop_btn_state : std_logic := '0';
signal start_stop_btn_pulse : std_logic := '0';
signal reset_btn_state : std_logic := '0';
signal reset_btn_pulse : std_logic := '0';
signal is_running : boolean := false;
signal mux_state : std_logic := '0';
signal mux_pulse : std_logic := '0';
signal milli_state : std_logic := '0';
signal milli_pulse : std_logic := '0';


constant COUNTER_RUNNING : std_logic_vector(1 downto 0) := "01";
constant COUNTER_STOPPED : std_logic_vector(1 downto 0) := "00";
constant COUNTER_RUNNING_SHOWING_LAP : std_logic_vector(1 downto 0) := "10";
constant COUNTER_STOPPED_SHOWING_LAP : std_logic_vector(1 downto 0) := "11";
signal counter_state : std_logic_vector(1 downto 0) := COUNTER_STOPPED;
signal sec_valold_left,sec_valold_right,min_valold_left,min_valold_right : std_logic_vector(7 downto 0) := (others => '0');

-- Mux counter
signal mux_signal : unsigned(1 downto 0) := (others => '0');
--
begin
	milli_ctr_right : counter		
	port map (
		CLK => CLK,
		EN_T => milli_pulse,
		EN_P => ce,
		CLR => '0',
		LOAD => load,
		LOAD_VALUE => "00000000",
		COUNT_TO => "01100011",
		RCO => milli_rco_right,
		DATA => milli_val_right
	);

	milli_ctr_left : counter		
	port map (
		CLK => CLK,
		EN_T => milli_rco_right,
		EN_P => ce,
		CLR => '0',
		LOAD => load,
		LOAD_VALUE => "00000000",
		COUNT_TO => "01100011",
		RCO => milli_rco_left,
		DATA => milli_val_left
	);

	sec_ctr_right : counter		
	port map (
		CLK => CLK,
		EN_T => milli_rco_left,
		EN_P => ce,
		CLR => '0',
		LOAD => load,
		LOAD_VALUE => "00000000",
		COUNT_TO => "00001001",
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
	MUX_VALUE <= 			-- Displays
					sec_valold_right when (counter_state = COUNTER_RUNNING_SHOWING_LAP or counter_state = COUNTER_STOPPED_SHOWING_LAP) and mux_signal = "00" else
					sec_valold_left when (counter_state = COUNTER_RUNNING_SHOWING_LAP or counter_state = COUNTER_STOPPED_SHOWING_LAP) and mux_signal = "01" else
					min_valold_right when (counter_state = COUNTER_RUNNING_SHOWING_LAP or counter_state = COUNTER_STOPPED_SHOWING_LAP) and mux_signal = "10" else
					min_valold_left when (counter_state = COUNTER_RUNNING_SHOWING_LAP or counter_state = COUNTER_STOPPED_SHOWING_LAP) and mux_signal = "11" else
					-- For 1c
					x"00" when mux_signal = "01" and DISPLAY_SELECTION = '0' and milli_val_left = x"00" and sec_val_right = x"00" and sec_val_left = x"00" else
					x"00" when mux_signal = "10" and DISPLAY_SELECTION = '0' and sec_val_right = x"00" and sec_val_left = x"00" else
					x"00" when mux_signal = "11" and DISPLAY_SELECTION = '0' and sec_val_left = x"00" else
					x"00" when mux_signal = "01" and DISPLAY_SELECTION = '1' and sec_val_left = x"00" and min_val_right = x"00" and min_val_left = x"00" else
					x"00" when mux_signal = "10" and DISPLAY_SELECTION = '1' and min_val_right = x"00" and min_val_left = x"00" else
					x"00" when mux_signal = "11" and DISPLAY_SELECTION = '1' and min_val_left = x"00" else
					-- Display normal values otherwise, switch depending on display selection
					sec_val_left when mux_signal = "10" and DISPLAY_SELECTION = '0' else
					sec_val_right when mux_signal = "11" and DISPLAY_SELECTION = '0' else
					milli_val_left when mux_signal = "10" and DISPLAY_SELECTION = '0' else
					milli_val_right when mux_signal = "11" and DISPLAY_SELECTION = '0' else
					sec_val_left when mux_signal = "00" and DISPLAY_SELECTION = '1' else
					sec_val_right when mux_signal = "01" and DISPLAY_SELECTION = '1' else
					min_val_left when mux_signal = "10" and DISPLAY_SELECTION = '1' else
					min_val_right;
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

			if milli_state = '0' and MILLI_CLK = '1' then
				milli_pulse <= '1';
			else
				milli_pulse <= '0';
			end if;
			milli_state <= MILLI_CLK;
		end if;
	end process;

	-- The stopwatch
	process(CLK)
	begin
		if rising_edge(CLK) then
			-- If counter is running and we press the lap/reset btn we should show the lap time
			if counter_state = COUNTER_RUNNING and reset_btn_pulse = '1' then
				counter_state <= COUNTER_RUNNING_SHOWING_LAP;
				-- Store the current value
				sec_valold_left <= sec_val_left;
				sec_valold_right <= sec_val_right;
				min_valold_left <= min_valold_left;
				min_valold_right <= min_valold_right;
				load <= '0';
				ce <= '1';
			-- If lap time is showing and counter is running and we press start/stop then we should stop it
			elsif counter_state = COUNTER_RUNNING_SHOWING_LAP and start_stop_btn_pulse = '1' then
				ce <= '0';
				counter_state <= COUNTER_STOPPED_SHOWING_LAP;
				LED_START_STOP <= '0';
				load <= '0';
			-- If lap time is showing and it is stopped, then on lap/reset btn press we should show final time
			elsif counter_state = COUNTER_STOPPED_SHOWING_LAP and reset_btn_pulse = '1' then
				counter_state <= COUNTER_STOPPED;	
				LED_START_STOP <= '0';
				ce <= '0';
				load <= '0';
			-- Counter is stopped no lap times are showing, the reset it
			elsif counter_state = COUNTER_STOPPED and reset_btn_pulse = '1' then
				load <= '1';
				ce <= '0';
			-- Stop the time
			elsif counter_state = COUNTER_RUNNING and start_stop_btn_pulse = '1' then
				counter_state <= COUNTER_STOPPED;
				ce <= '0';
				LED_START_STOP <= '0';
				load <= '0';
			-- Start the time
			elsif counter_state = COUNTER_STOPPED and start_stop_btn_pulse = '1' then
				counter_state <= COUNTER_RUNNING;
				LED_START_STOP <= '1';
				ce <= '1';
				load <= '0';
			-- reset it
			end if;
		end if;
	end process;
end rtl;


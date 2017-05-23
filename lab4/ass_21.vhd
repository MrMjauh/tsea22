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
-- Counter specific
signal ce : std_logic := '0';
signal load : std_logic := '0';

signal milli_rco_right,milli_rco_left,sec_rco_left,sec_rco_right,min_rco_left,min_rco_right : std_logic := '0';
signal milli_val_right,milli_val_left,sec_val_left,sec_val_right,min_val_left,min_val_right,current_val : unsigned(3 downto 0) := (others => '0');
signal counter_empty : std_logic := '0';

-- One pulse signal variables
signal start_stop_btn_state : std_logic := '0';
signal start_stop_btn_pulse : std_logic := '0';
signal reset_btn_state : std_logic := '0';
signal reset_btn_pulse : std_logic := '0';
signal mux_state : std_logic := '0';
signal mux_pulse : std_logic := '0';
signal milli_state : std_logic := '0';
signal milli_pulse : std_logic := '0';


constant COUNTER_RUNNING : std_logic_vector(1 downto 0) := "01";
constant COUNTER_STOPPED : std_logic_vector(1 downto 0) := "00";
constant COUNTER_STOPPED_SHOWING_LAP : std_logic_vector(1 downto 0) := "10";
constant COUNTER_RUNNING_SHOWING_LAP : std_logic_vector(1 downto 0) := "11";
signal counter_state : std_logic_vector(1 downto 0) := COUNTER_STOPPED;
signal dot : std_logic := '0';
-- register storing old values
signal sec_valold_left,sec_valold_right,min_valold_left,min_valold_right : unsigned(3 downto 0) := (others => '0');

-- Mux
signal mux_signal : unsigned(1 downto 0) := (others => '0');
signal mux_buffer : std_logic_vector(3 downto 0) := (others => '0');
--
begin
	-- milli right
	process(CLK)
	  begin
		 if rising_edge(CLK) then
				if ce = '1' and milli_pulse = '1' then
					if milli_val_right = "1001" then
						milli_val_right <= "0000";
						milli_rco_right <= '1';
					else
						milli_val_right <= milli_val_right + 1;
						milli_rco_right <= '0';
					end if;
				elsif LOAD = '1' then
					milli_rco_right <= '0';
					milli_val_right <= "0000";
				else
					milli_rco_right <= '0';
				end if;
		 end if;
	end process;
	
	-- milli left
	process(CLK)
	  begin
		 if rising_edge(CLK) then
				if ce = '1' and milli_rco_right = '1' then
					if milli_val_left = "1001" then
						milli_val_left <= "0000";
						milli_rco_left <= '1';
					else
						milli_val_left <= milli_val_left + 1;
						milli_rco_left <= '0';
					end if;
				elsif LOAD = '1' then
					milli_rco_left <= '0';
					milli_val_left <= "0000";
				else
					milli_rco_left <= '0';
				end if;
		 end if;
	end process;

	-- sec right
	process(CLK)
	  begin
		 if rising_edge(CLK) then
				if ce = '1' and milli_rco_left = '1' then
					if sec_val_right = "1001" then
						sec_val_right <= "0000";
						sec_rco_right <= '1';
					else
						sec_val_right <= sec_val_right + 1;
						sec_rco_right <= '0';
					end if;
				elsif LOAD = '1' then
					sec_rco_right <= '0';
					sec_val_right <= "0000";
				else
					sec_rco_right <= '0';
				end if;
		 end if;
	end process;
	
	-- sec left
	process(CLK)
	  begin
		 if rising_edge(CLK) then
				if ce = '1' and sec_rco_right = '1' then
					if sec_val_left = "0101" then
						sec_val_left <= "0000";
						sec_rco_left <= '1';
					else
						sec_val_left <= sec_val_left + 1;
						sec_rco_left <= '0';
					end if;
				elsif LOAD = '1' then
					sec_rco_left <= '0';
					sec_val_left <= "0000";
				else
					sec_rco_left <= '0';
				end if;
		 end if;
	end process;
	
	-- min right
	process(CLK)
	  begin
		 if rising_edge(CLK) then
				if ce = '1' and sec_rco_left = '1' then
					if min_val_right = "1001" then
						min_val_right <= "0000";
						min_rco_right <= '1';
					else
						min_val_right <= min_val_right + 1;
						min_rco_right <= '0';
					end if;
				elsif LOAD = '1' then
					min_rco_right <= '0';
					min_val_right <= "0000";
				else
					min_rco_right <= '0';
				end if;
		 end if;
	end process;

	-- min left
	process(CLK)
	  begin
		 if rising_edge(CLK) then
				if ce = '1' and min_rco_right = '1' then
					if min_val_left = "1001" then
						min_val_left <= "0000";
						min_rco_left <= '1';
					else
						min_val_left <= min_val_left + 1;
						min_rco_left <= '0';
					end if;
				elsif LOAD = '1' then
					min_rco_left <= '0';
					min_val_left <= "0000";
				else
					min_rco_left <= '0';
				end if;
		 end if;
	end process;

	process(CLK) begin
	if rising_edge(CLK) then	
		if mux_pulse = '1' then
			-- Show laptime
			if mux_signal = "11" and counter_state(1) = '1' then
				current_val <= sec_valold_right;
				counter_empty <= '0';
				mux_signal <= mux_signal + 1;
				dot <= '0';
			elsif mux_signal = "00" and counter_state(1) = '1' then
				current_val <= sec_valold_left;
				if min_valold_right = "0000" and min_valold_right = "0000" and sec_valold_left = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '0';
			elsif mux_signal = "01" and counter_state(1) = '1' then
				current_val <= min_valold_right;
				if min_valold_right = "0000" and min_valold_right = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;			
				dot <= '1';				
			elsif mux_signal = "10" and counter_state(1) = '1' then
				current_val <= min_valold_left;
				if min_valold_right = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '0';
			-- Show normal times depending on display selection
			elsif mux_signal = "11" and DISPLAY_SELECTION = '0' then
				current_val <= milli_val_right;
				counter_empty <= '0';
				mux_signal <= mux_signal + 1;
				dot <= '0';
			elsif mux_signal = "00" and DISPLAY_SELECTION = '0' then
				current_val <= milli_val_left;
				if milli_val_left = "0000" and sec_val_right = "0000" and sec_val_left = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '0';
			elsif mux_signal = "01" and DISPLAY_SELECTION = '0' then
				current_val <= sec_val_right;
				if sec_val_right = "0000" and sec_val_left = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '1';
			elsif mux_signal = "10" and DISPLAY_SELECTION = '0' then
				current_val <= sec_val_left;
				if sec_val_left = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '0';
			elsif mux_signal = "11" and DISPLAY_SELECTION = '1' then
				current_val <= sec_val_right;
				counter_empty <= '0';
				mux_signal <= mux_signal + 1;
				dot <= '0';
			elsif mux_signal = "00" and DISPLAY_SELECTION = '1' then
				current_val <= sec_val_left;
				if sec_val_left = "0000" and min_val_right = "0000" and min_val_left = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '0';
			elsif mux_signal = "01" and DISPLAY_SELECTION = '1' then
				current_val <= min_val_right;
				if min_val_right = "0000" and min_val_left = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '1';
			elsif mux_signal = "10" and DISPLAY_SELECTION = '1' then
				current_val <= min_val_left;
				if min_val_left = "0000" then
									counter_empty <= '1';
				else
									counter_empty <= '0';
				end if;
				mux_signal <= mux_signal + 1;
				dot <= '0';
			end if;

		end if;
	end if;
	end process;
	
	mux_buffer <= "1111" when counter_empty = '1' else
						std_logic_vector(current_val);
					
	MUX_VALUE <= 	dot & "0111111" when mux_buffer = "0000" else
						dot & "0000110" when mux_buffer = "0001" else
						dot & "1011011" when mux_buffer = "0010" else
						dot & "1001111" when mux_buffer = "0011" else
						dot & "1100110" when mux_buffer = "0100" else
						dot & "1101101" when mux_buffer = "0101" else
						dot & "1111101" when mux_buffer = "0110" else
						dot & "0000111" when mux_buffer = "0111" else
						dot & "1111111" when mux_buffer = "1000" else
						dot & "1100111" when mux_buffer = "1001" else
						"00000000";
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
			if (counter_state = COUNTER_RUNNING or counter_state = COUNTER_RUNNING_SHOWING_LAP) and reset_btn_pulse = '1' then
				counter_state <= COUNTER_RUNNING_SHOWING_LAP;
				-- Store the current value
				sec_valold_left <= sec_val_left;
				sec_valold_right <= sec_val_right;
				min_valold_left <= min_valold_left;
				min_valold_right <= min_valold_right;
				load <= '0';
				ce <= '1';
			-- If lap time is showing and counter is running and we press stop then we should stop it
			elsif counter_state = COUNTER_RUNNING_SHOWING_LAP and start_stop_btn_pulse = '1' then
				ce <= '0';
				counter_state <= COUNTER_STOPPED_SHOWING_LAP;
				load <= '0';
			-- If lap time is showing and it is stopped, then on lap/reset btn press we should show final time
			elsif counter_state = COUNTER_STOPPED_SHOWING_LAP and reset_btn_pulse = '1' then
				counter_state <= COUNTER_STOPPED;	
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
				load <= '0';
			-- Start the time
			elsif counter_state = COUNTER_STOPPED and start_stop_btn_pulse = '1' then
				counter_state <= COUNTER_RUNNING;
				ce <= '1';
				load <= '0';
			-- reset it
			end if;
		end if;
	end process;
	
	LED_START_STOP <= counter_state(0);
	LED2 <= counter_state(1);
end rtl;
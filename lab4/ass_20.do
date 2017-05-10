vsim ass_20
add wave -position end  sim:/ass_20/CLK
add wave -position end  sim:/ass_20/SEC_CLK
add wave -position end  sim:/ass_20/MUX_CLK
add wave -position end  sim:/ass_20/BTN_START_STOP
add wave -position end  sim:/ass_20/BTN_RESET
add wave -position end  sim:/ass_20/LED_START_STOP
add wave -position end  sim:/ass_20/LED2
add wave -position end  sim:/ass_20/MUX_SELECTION
add wave -position end  sim:/ass_20/MUX_VALUE
add wave -position end  sim:/ass_20/start_stop_btn_pulse
add wave -position end  sim:/ass_20/reset_btn_pulse
force -freeze sim:/ass_20/CLK 1 0, 0 {5 ns} -r 10
force -freeze sim:/ass_20/SEC_CLK 1 0, 0 {500 ns} -r 1000
force -freeze sim:/ass_20/MUX_CLK 1 0, 0 {50 ns} -r 100
force -freeze sim:/ass_20/BTN_START_STOP 1 0, 0 {250 ns} -r 10000
force -freeze sim:/ass_20/BTN_RESET 1 0, 0 {250 ns} -r 7000
run 20000
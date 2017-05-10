vsim counter
add wave -position insertpoint  \
sim:/counter/CLK \
sim:/counter/CLR \
sim:/counter/LOAD \
sim:/counter/LOAD_VALUE \
sim:/counter/COUNT_TO \
sim:/counter/RCO \
sim:/counter/DATA
force -freeze sim:/counter/CLK 1 25, 0 {75 ns} -r 100
force -freeze sim:/counter/CLR 0 25
force -freeze sim:/counter/LOAD 0 25
force -freeze sim:/counter/COUNT_TO 8'h08 25

run 2000
vlib work
vlog validator_unit_test.v
vsim validator_test

log {/*}
add wave {/*}

force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
run 10ns

force {KEY[0]} 1
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 0
run 500ns

force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 1
force {KEY[3]} 1
run 10ns

force {KEY[0]} 1
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 1
run 10ns

force {KEY[0]} 1
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
run 1000ns
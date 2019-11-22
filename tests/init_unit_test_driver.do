vlib work
vlog init_unit_test.v
vsim init_test

log {/*}
add wave {/*}

force {KEY[0]} 0
force {KEY[1]} 1
run 10ns

force {KEY[0]} 1
force {KEY[1]} 0
run 500ns
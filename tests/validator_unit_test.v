`timescale 1ns / 1ns

module validator_test(
    input [9:0] SW,
    input [3:0] KEY,
    output [9:0] LEDR,
    // input [6:0] test_addr,
);

wire [6:0] addr_mem;
wire [1:0] data_mem;
wire wren_mem;
wire from_mem;

reg CLOCK_50;

initial CLOCK_50 = 1'b0;

initializer i0 (
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .start(~KEY[3]),
    .done(LEDR[3]),
    .addr(addr_mem),
    .data(data_mem),
    .wren(wren_mem)
);

gameboardRAM ram (
    .address(addr_mem),
    .clock(CLOCK_50),
    .data(data_mem),
    .wren(wren_mem),
    .q(from_mem)
);

validator v0 (
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .s_addr_in(7'b1000000),  //7'b1000000
    .player(1'b0),
    .step_in(4'b1010),
    .ld(~KEY[1]),
    .enable(~KEY[2]),
    .dir_status_o(LEDR[0]),
    .s_done_o(LEDR[1]),
    .addr_out(addr_mem),
    .wren_o(wren_mem),
    .data_in(from_mem)
);

always #1 CLOCK_50 = ~CLOCK_50;

endmodule // validator_test
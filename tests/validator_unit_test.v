module validator_test(
    input [9:0 SW,
    input [3:0] KEY,
    input CLOCK_50,
    output [9:0] LEDR
);

wire [7:0] addr_mem;
wire [1:0] data_mem;
wire wren_mem;

initializer i0 (
    .clock(CLOCK_50),
    .reset(~KEY[0]),
    .start(~KEY[1]),
    .done(LEDR[0]),
    .addr(addr_mem),
    .data(data_mem),
    .wren(wren_mem)
);

validator v0 (
    .clock(CLOCK_50),
    .reset(~KEY[0]),
    .s_addr_in(7'b100010),
    .player(1'b0),
    .step_in(4'b1010),
    .ld(~KEY[1]),
    .enable(~KEY[2]),
    .dir_status_o(LEDR[0]),
    .s_done_o(LEDR[1])
);

endmodule // validator_test
module validator_test(
    input SW[9:0],
    input [3:0] KEY,
    input CLOCK_50,
    output [9:0] LEDR;
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
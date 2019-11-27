`timescale 1ns / 1ns

module validator_test(
    input [9:0] SW,
    input [3:0] KEY,
    output [9:0] LEDR
    // input [6:0] test_addr,
);

reg [6:0] addr_mem;
wire [6:0] addr_mem_i;
wire [6:0] addr_mem_v;
reg [1:0] data_mem;
wire [1:0] data_mem_i;
wire [1:0] data_mem_v;
reg wren_mem;
wire wren_mem_i;
wire wren_mem_v;
wire [1:0] from_mem;
wire i_done;
reg i_done_reg;

reg CLOCK_50;

initial CLOCK_50 = 1'b0;

initializer i0 (
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .start(~KEY[3]),
    .done(i_done),
    .addr(addr_mem_i),
    .data(data_mem_i),
    .wren(wren_mem_i)
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
    .s_addr_in(7'b100011),  //7'b100011
    .player(1'b0),
    .step_in(5'b1010),
    .ld(~KEY[1]),
    .enable(~KEY[2]),
    .dir_status_o(LEDR[0]),
    .s_done_o(LEDR[1]),
    .addr_out(addr_mem_v),
    .wren_o(wren_mem_v),
    .data_in(from_mem)
);

assign LEDR[3] = i_done;
assign LEDR[4] = wren_mem;

always @(*) begin
	i_done_reg <= i_done;
	data_mem = i_done_reg == 1'b1 ? data_mem_v : data_mem_i;
	addr_mem = i_done_reg == 1'b1 ? addr_mem_v : addr_mem_i;
	wren_mem = i_done_reg == 1'b1 ? wren_mem_v : wren_mem_i;
end

always #1 CLOCK_50 = ~CLOCK_50;

endmodule // validator_test
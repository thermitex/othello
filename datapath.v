module datapath(
    input [5:0] e_addr_in,              // address loaded from switches
    input [6:0] i_addr_in,              // address given internally
    input [1:0] data_in,                // data to be written
    input ld_e_addr,                    // load external address from switches
    input ld_i_addr,                    // load from i_addr_in
    input player,                       // 0 when wait black, 1 white
    input ld_data_p,                    // load data according to player
    input ld_data,                      // load data from data_in
    input reset,
    input clock,
    // ---- for memory ----
    // data protocol:
    // null:    2'b00
    // black:   2'b01
    // white:   2'b10
    // wall:    2'b11
    input write_to_mem,                 // write to memory
    input read_fr_mem,                  // data got from memory
    output reg [6:0] addr_to_mem,       // address to the memory
    output reg [1:0] data_to_mem,       // data to be sent
    output reg wren,                    // write enable
    // --------------------
    output reg game_end,                // signaling end of the game
    // ------ vd ctl ------
    input mv_valid_in,
    output reg [6:0] s_addr_out,
    output reg done_out,
    output reg ack                      // acknowledge valid move
    // --------------------
);

// address of the current move
reg [6:0] addr;
// data of the move (using data protocol)
reg [1:0] data;

// read in addr
always @(posedge clock) begin
    if (!reset)
        addr <= 7'b0;
    else begin
        s_addr_out <= addr;
        if (ld_e_addr)
            addr <= 11 + (addr_in >> 3) << 1 + e_addr_in;
        if (ld_i_addr)
            addr <= i_addr_in;
    end
end

// get data to be written
always @(posedge clock) begin
    if (!reset)
        data <= 2'b0;
    else begin
        if (ld_data_p)
            data <= player ? 2'b10 : 2'b01;
        if (ld_data)
            data <= data_in;
    end
end

// ack out
always @(posedge clock) begin
    if (!reset)
        ack <= 1'b0;
    else begin
        if (mv_valid_in)
            ack <= 1'b1;
        else
            ack <= 1'b0;
    end
end

endmodule // datapath
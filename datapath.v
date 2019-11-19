module datapath(
    input [5:0] addr,                       // address loaded from switches
    input enable,                           // enable datapath to operate
    input player,                           // 0 when wait black, 1 white
    input reset,
    input clock,
    // ---- for memory ----
    // data protocol:
    // null:    2'b00
    // black:   2'b01
    // white:   2'b10
    // wall:    2'b11
    input data_get,                         // data got from memory
    output reg [6:0] addr_to_mem,           // address to the memory
    output reg [1:0] data_to_mem,           // data to be sent
    output reg wren,                        // write enable
    // --------------------
    output reg game_end,                    // signaling end of the game
    output reg ack                          // acknowledge valid move
);

endmodule // datapath
module main_controller(
    input go,                   // start the game
    input game_end,             // game ends
    input ack,                  // ack for making a valid move
    input clock,
    input reset,
    output reg new_move,        // enable new move controller
    output reg init_start,      // start initialization
    input init_done,
    output reg player           // 0 when wait black, 1 white
);

reg [2:0] current_state, next_state;

localparam  S_GAME_WELC         = 3'b0,
            S_WB_WAIT           = 3'b1,
            S_WB_VALI_WAIT      = 3'b10,
            S_WW_WAIT           = 3'b11,
            S_WW_VALI_WAIT      = 3'b100,
            S_GAME_INIT         = 3'b101,
            S_WAIT_BLACK        = 3'b110,
            S_WAIT_WHITE        = 3'b111;

always @(*)
begin: state_table 
    case (current_state)
        S_GAME_WELC:  next_state = go ? S_GAME_INIT : S_GAME_WELC;
        S_GAME_INIT: next_state = init_done ？ S_WAIT_BLACK : S_GAME_INIT；
        S_WAIT_BLACK: next_state = go ? S_WB_WAIT : S_WAIT_BLACK; 
        S_WB_WAIT: next_state = go ? S_WB_WAIT : S_WB_VALI_WAIT;
        S_WB_VALI_WAIT: next_state = ack ? S_WAIT_WHITE : S_WB_VALI_WAIT;
        S_WAIT_WHITE: next_state = go ? S_WW_WAIT : S_WAIT_WHITE;
        S_WW_WAIT: next_state = go ? S_WW_WAIT : S_WW_VALI_WAIT;
        S_WW_VALI_WAIT: next_state = ack ? S_WAIT_BLACK : S_WW_VALI_WAIT;
        default:      next_state = S_GAME_WELC;
    endcase
end // state_table

always @(*)
begin: enable_signals
    case (current_state)
        S_GAME_INIT: begin
            init_start = 1;
        end
        S_WAIT_BLACK: begin
            init_start = 0;
            new_move = 0;
            player = 0;
        end
        S_WB_VALI_WAIT: begin
            new_move = 1;
            player = 0;
        end
        S_WAIT_WHITE: begin
            new_move = 0;
            player = 1;
        end
        S_WW_VALI_WAIT: begin
            new_move = 1;
            player = 1;
        end
        default: player = 0;
    endcase
end // enable_signals

always @(posedge clock)
begin: state_FFs
    if(!reset)
        current_state <= S_GAME_WELC;
    else
        current_state <= next_state;
end // state_FFS

endmodule // main_controller
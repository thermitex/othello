module controller(
    input go,                   // start the game
    input game_end,             // game ends (from datapath)
    input ack,                  // ack for making a valid move
    input clock,
    input reset,
    output reg enable,          // enable datapath
    output reg player           // 0 when wait black, 1 white
);

reg [2:0] current_state, next_state;

wire init_start, init_done;

localparam  S_GAME_WELC         = 2'd0,
            S_GAME_WELC_WAIT    = 2'b1;
            S_GAME_INIT         = 3'b2
            S_WAIT_BLACK        = 3'd3,
            S_WAIT_WHITE        = 3'd4,

always @(*)
begin: state_table 
    case (current_state)
        S_GAME_WELC:  next_state = go ? S_GAME_INIT_WAIT : S_GAME_WELC;
        S_GAME_WELC_WAIT: next_state = go ? S_GAME_INIT : S_GAME_WELC_WAIT;
        S_GAME_INIT: next_state = init_done ？ S_WAIT_BLACK : S_GAME_INIT；
        S_WAIT_BLACK: next_state = ack ? S_WAIT_WHITE : S_WAIT_BLACK; 
        S_WAIT_WHITE: next_state = ack ? S_WAIT_BLACK : S_WAIT_WHITE;
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
            player = 0;
        end
        S_WAIT_WHITE: begin
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

endmodule // controller
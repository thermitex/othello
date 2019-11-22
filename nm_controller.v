module nm_controller(
    input enable,                   // new move signal
    input clock,
    input reset,
    input s_done,
    input dir_status_in,
    output reg ld_e_addr_o,
    // output reg ld_i_addr,
    output reg ld_data_p_o,
    // output reg ld_data,
    output reg write_to_mem_o
    output reg step_o,
    output reg ld_o,
    output reg mv_valid_o
);

reg [3:0] current_state, next_state;
reg [3:0] dir_status;

localparam  S_WAIT_MOVE         = 4'b8,
            S_VALIDATE_U        = 4'b0,
            S_VALIDATE_D        = 4'b1,
            S_VALIDATE_L        = 4'b2,
            S_VALIDATE_R        = 4'b3,
            S_VALIDATE_U_S      = 4'b4,
            S_VALIDATE_D_S      = 4'b5,
            S_VALIDATE_L_S      = 4'b6,
            S_VALIDATE_R_S      = 4'b7,
            S_FINAL             = 4'b9,
            S_DP_LOAD           = 4'b10;

always @(*)
begin: state_table 
    case (current_state)
        S_WAIT_MOVE:  next_state = enable ? S_DP_LOAD : S_WAIT_MOVE;
        S_DP_LOAD: next_state = S_VALIDATE_U;
        S_VALIDATE_U_S:  next_state = S_VALIDATE_U;
        S_VALIDATE_U:  next_state = s_done ? S_VALIDATE_D_S : S_VALIDATE_U;
        S_VALIDATE_D_S:  next_state = S_VALIDATE_D;
        S_VALIDATE_D:  next_state = s_done ? S_VALIDATE_L_S : S_VALIDATE_D;
        S_VALIDATE_L_S:  next_state = S_VALIDATE_L;
        S_VALIDATE_L:  next_state = s_done ? S_VALIDATE_R_S : S_VALIDATE_L;
        S_VALIDATE_R_S:  next_state = S_VALIDATE_R;
        S_VALIDATE_R:  next_state = s_done ? S_FINAL : S_VALIDATE_R;
        // S_FLIP_U:  next_state = s_done ? S_FLIP_D : S_FLIP_U;
        // S_FLIP_D:  next_state = s_done ? S_FLIP_L : S_FLIP_D;
        // S_FLIP_L:  next_state = s_done ? S_FLIP_R : S_FLIP_L;
        // S_FLIP_R:  next_state = s_done ? S_FINAL : S_FLIP_R;
        S_FINAL:   next_state = S_WAIT_MOVE;
        default:   next_state = S_WAIT_MOVE;
    endcase
end // state_table

begin: enable_signals
    case (current_state)
        S_WAIT_MOVE: begin
            mv_valid_o = 0;
        end
        S_DP_LOAD: begin
            ld_data_p_o = 1;    // -> ld_data_p
            ld_e_addr_o = 1;    // -> ld_e_addr
        end
        S_VALIDATE_U_S: begin
            step_o = -10;
            ld_o = 1;
            enable = 1;
        end
        S_VALIDATE_U: begin
            enable = 0;
        end
        S_VALIDATE_D_S: begin
            step_o = 10;
            ld_o = 1;
            enable = 1;
        end
        S_VALIDATE_D: begin
            enable = 0;
        end
        S_VALIDATE_L_S: begin
            step_o = -1;
            ld_o = 1;
            enable = 1;
        end
        S_VALIDATE_L: begin
            enable = 0;
        end
        S_VALIDATE_R_S: begin
            step_o = 1;
            ld_o = 1;
            enable = 1;
        end
        S_VALIDATE_R: begin
            enable = 0;
        end
        S_FINAL: begin
            mv_valid_o = 1;
        end
        default: enable = 0;
    endcase
end // enable_signals

always @(posedge clock)
begin: state_FFs
    if(!reset)
        current_state <= S_WAIT_MOVE;
    else
        current_state <= next_state;
end // state_FFS

endmodule // New Move Controller
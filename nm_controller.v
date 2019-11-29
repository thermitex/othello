module nm_controller(
    input enable,                   // <- new_move (main_controller)
    input clock,                    // <- CLOCK_50
    input reset,                    // <- reset
    input s_done_vali,              // <- s_done_o (validator)
    input s_done_flip,              // <- s_done_o (validator)
    input dir_status_in,            // <- dir_status_o (validator)
    output reg [4:0] step_o,        // -> step_in (validator)
    output reg ld_vali_o,           // -> ld (validator)
    output reg ld_flip_o,           // -> ld (flipper)
    output reg mv_valid_o,          // -> mv_valid_in (datapath)
    output reg start_vali,          // -> enable (validator)
    output reg start_flip           // -> enable (flipper)
    // output reg ld_e_addr_o,         // -> ld_e_addr (datapath)
    // output reg ld_data_p_o,         // -> ld_data_p (datapath)
    // output reg write_to_mem_o       // -> write_to_mem (datapath)
);

reg [4:0] current_state, next_state;
reg [3:0] dir_status;

localparam  S_WAIT_MOVE         = 5'b0,
            S_VALIDATE_U        = 5'b1,
            S_VALIDATE_D        = 5'b10,
            S_VALIDATE_L        = 5'b11,
            S_VALIDATE_R        = 5'b100,
            S_VALIDATE_U_S      = 5'b101,
            S_VALIDATE_D_S      = 5'b110,
            S_VALIDATE_L_S      = 5'b111,
            S_VALIDATE_R_S      = 5'b1000,
            S_FLIP_U            = 5'b1001,
            S_FLIP_D            = 5'b1010,
            S_FLIP_L            = 5'b1011,
            S_FLIP_R            = 5'b1100,
            S_FLIP_U_S          = 5'b1101,
            S_FLIP_D_S          = 5'b1110,
            S_FLIP_L_S          = 5'b1111,
            S_FLIP_R_S          = 5'b10000,
            S_FINAL             = 5'b10001,
            S_DP_LOAD           = 5'b10010;

always @(*)
begin: state_table 
    case (current_state)
        S_WAIT_MOVE:  next_state = enable ? S_DP_LOAD : S_WAIT_MOVE;
        S_DP_LOAD: next_state = S_VALIDATE_U;
        S_VALIDATE_U_S:  next_state = S_VALIDATE_U;
        S_VALIDATE_U:  next_state = s_done_vali ? S_VALIDATE_D_S : S_VALIDATE_U;
        S_VALIDATE_D_S:  next_state = S_VALIDATE_D;
        S_VALIDATE_D:  next_state = s_done_vali ? S_VALIDATE_L_S : S_VALIDATE_D;
        S_VALIDATE_L_S:  next_state = S_VALIDATE_L;
        S_VALIDATE_L:  next_state = s_done_vali ? S_VALIDATE_R_S : S_VALIDATE_L;
        S_VALIDATE_R_S:  next_state = S_VALIDATE_R;
        S_VALIDATE_R:  next_state = s_done_vali ? S_FLIP_U_S : S_VALIDATE_R;
        S_FLIP_U_S:  next_state = S_FLIP_U;
        S_FLIP_U:  next_state = s_done_flip ? S_FLIP_D_S : S_FLIP_U;
        S_FLIP_D_S:  next_state = S_FLIP_D;
        S_FLIP_D:  next_state = s_done_flip ? S_FLIP_L_S : S_FLIP_D;
        S_FLIP_L_S:  next_state = S_FLIP_L;
        S_FLIP_L:  next_state = s_done_flip ? S_FLIP_R_S : S_FLIP_L;
        S_FLIP_R_S:  next_state = S_FLIP_R;
        S_FLIP_R:  next_state = s_done_flip ? S_FINAL : S_FLIP_R;
        S_FINAL:   next_state = S_WAIT_MOVE;
        default:   next_state = S_WAIT_MOVE;
    endcase
end // state_table

always @(*)
begin: enable_signals
    case (current_state)
        S_WAIT_MOVE: begin
            mv_valid_o = 0;
        end
        S_VALIDATE_U_S: begin
            step_o = -5'b1010;
            ld_vali_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_U: begin
            start_vali = 0;
            if (s_done_vali)
                dir_status[3] <= dir_status_in;
        end
        S_VALIDATE_D_S: begin
            step_o = 5'b1010;
            ld_vali_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_D: begin
            start_vali = 0;
            if (s_done_vali)
                dir_status[2] <= dir_status_in;
        end
        S_VALIDATE_L_S: begin
            step_o = -5'b1;
            ld_vali_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_L: begin
            start_vali = 0;
            if (s_done_vali)
                dir_status[1] <= dir_status_in;
        end
        S_VALIDATE_R_S: begin
            step_o = 5'b1;
            ld_vali_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_R: begin
            start_vali = 0;
            if (s_done_vali)
                dir_status[0] <= dir_status_in;
        end
        S_FLIP_U_S: begin
            step_o = -5'b1010;
            ld_flip_o = 1;
            start_flip = 1;
        end
        S_FLIP_U: begin
            start_flip = 0;
        end
        S_FLIP_D_S: begin
            step_o = 5'b1010;
            ld_flip_o = 1;
            start_flip = 1;
        end
        S_FLIP_D: begin
            start_flip = 0;
        end
        S_FLIP_L_S: begin
            step_o = -5'b1;
            ld_flip_o = 1;
            start_flip = 1;
        end
        S_FLIP_L: begin
            start_flip = 0;
        end
        S_FLIP_R_S: begin
            step_o = 5'b1;
            ld_flip_o = 1;
            start_flip = 1;
        end
        S_FLIP_R: begin
            start_flip = 0;
        end
        S_FINAL: begin
            if (dir_status[3] | dir_status[2] | dir_status[1] | dir_status[0]) begin
                mv_valid_o = 1;
            end
        end
        default: begin
            start_vali = 0;
            start_flip = 0;
        end
    endcase
end // enable_signals

always @(posedge clock)
begin: state_FFs
    if(!reset)
        dir_status <= 4'b0;
        current_state <= S_WAIT_MOVE;
    else
        current_state <= next_state;
end // state_FFS

endmodule // New Move Controller
module nm_controller(
    input enable,                   // <- new_move (main_controller)
    input clock,                    // <- CLOCK_50
    input reset,                    // <- reset
    input s_done,                   // <- s_done_o (validator)
    input dir_status_in,            // <- dir_status_o (validator)
    output reg ld_e_addr_o,         // -> ld_e_addr (datapath)
    output reg ld_data_p_o,         // -> ld_data_p (datapath)
    output reg write_to_mem_o       // -> write_to_mem (datapath)
    output reg [4:0] step_o,        // -> step_in (validator)
    output reg ld_o,                // -> ld (validator)
    output reg mv_valid_o,          // -> mv_valid_in (datapath)
    output reg start_vali           // -> enable (validator)
);

reg [3:0] current_state, next_state;
reg [3:0] dir_status;

localparam  S_WAIT_MOVE         = 4'b0,
            S_VALIDATE_U        = 4'b1,
            S_VALIDATE_D        = 4'b10,
            S_VALIDATE_L        = 4'b11,
            S_VALIDATE_R        = 4'b100,
            S_VALIDATE_U_S      = 4'b101,
            S_VALIDATE_D_S      = 4'b110,
            S_VALIDATE_L_S      = 4'b111,
            S_VALIDATE_R_S      = 4'b1000,
            S_FINAL             = 4'b1001,
            S_DP_LOAD           = 4'b1010;

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

always @(*)
begin: enable_signals
    case (current_state)
        S_WAIT_MOVE: begin
            mv_valid_o = 0;
            write_to_mem_o = 0;
        end
        S_DP_LOAD: begin
            ld_data_p_o = 1;    // -> ld_data_p
            ld_e_addr_o = 1;    // -> ld_e_addr
        end
        S_VALIDATE_U_S: begin
            step_o = -10;
            ld_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_U: begin
            start_vali = 0;
            if (s_done)
                dir_status[3] <= dir_status_in;
        end
        S_VALIDATE_D_S: begin
            step_o = 10;
            ld_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_D: begin
            start_vali = 0;
            if (s_done)
                dir_status[2] <= dir_status_in;
        end
        S_VALIDATE_L_S: begin
            step_o = -1;
            ld_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_L: begin
            start_vali = 0;
            if (s_done)
                dir_status[1] <= dir_status_in;
        end
        S_VALIDATE_R_S: begin
            step_o = 1;
            ld_o = 1;
            start_vali = 1;
        end
        S_VALIDATE_R: begin
            start_vali = 0;
            if (s_done)
                dir_status[0] <= dir_status_in;
        end
        S_FINAL: begin
            if (dir_status[3] | dir_status[2] | dir_status[1] | dir_status[0]) begin
                mv_valid_o = 1;
                write_to_mem_o = 1;
            end
        end
        default: start_vali = 0;
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
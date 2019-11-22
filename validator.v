module validator(
    input clock,                    // <- clock (main_controller)
    input reset,                    // <- reset
    input [6:0] s_addr_in,          // <- s_addr_out (datapath)
    input player,                   // <- player (main_controller)
    input [3:0] step_in,            // <- step_o (nm_controller)
    input ld,                       // <- ld_o (nm_controller)
    input enable;                   // <- start_vali (nm_controller)
    output reg dir_status_o,        // -> dir_status_in (nm_controller)
    output reg s_done_o             // -> s_done (nm_controller)
);

reg [6:0] addr;
reg [3:0] step;
reg [1:0] data;
reg count;

// validator states
reg [1:0] current_state, next_state;

localparam  S_WAIT_EN           = 2'b0,
            S_VALIDATING        = 2'b1,
            S_VALI_SUCC         = 2'b2,
            S_VALI_FAIL         = 2'b3,

// load
always @(posedge clock) begin
    if (!reset) begin
        addr <= 7'b0;
        step <= 4'b0;
        data <= 2'b0;
    end
    else begin
        if (ld) begin
            addr <= s_addr_in + step;
            step <= step_in;
            data <= player ? 2'b10 : 2'b01;
        end
    end
end

always @(posedge clock)
begin: do_stuff
    case (current_state)
        S_WAIT_EN: begin
            next_state = enable ? S_VALIDATING : S_WAIT_EN;
            count <= 0;
            dir_status_o = 0;
            s_done_o = 0;
        end
        S_VALIDATING: begin
            // TODO: get value from ram
            if (player == 1'b0) begin
                // black move, detect white ones
                if (data == 2'b10)
                    next_state = S_VALIDATING;
                if (data == 2'b01) begin
                    if (count == 1'b0)
                        next_state = S_VALI_FAIL;
                    else 
                        next_state = S_VALI_SUCC;
                end
                if (data == 2'b00 || data == 2'b11)
                    next_state = S_VALI_FAIL;
            end
            else begin
                // white move, detect black ones
                if (data == 2'b01)
                    next_state = S_VALIDATING;
                if (data == 2'b10) begin
                    if (count == 1'b0)
                        next_state = S_VALI_FAIL;
                    else 
                        next_state = S_VALI_SUCC;
                end
                if (data == 2'b00 || data == 2'b11)
                    next_state = S_VALI_FAIL;
            end
            count <= count + 1;
            addr <= addr + step;
        end
        S_VALI_FAIL: begin
            dir_status_o = 0;
            s_done_o = 1;
            next_state = S_WAIT_EN;
        end
        S_VALI_SUCC: begin
            dir_status_o = 1;
            s_done_o = 1;
            next_state = S_WAIT_EN;
        end
        default: next_state = S_WAIT_EN;
    endcase
end // do_stuff

always @(posedge clock)
begin: state_FFs
    if(!reset)
        current_state <= S_WAIT_EN;
    else
        current_state <= next_state;
end // state_FFS

endmodule // validator
module validator(
    input clock,                    // <- clock (main_controller)
    input reset,                    // <- reset
    input [6:0] s_addr_in,          // <- s_addr_out (datapath)
    input player,                   // <- player (main_controller)
    input [4:0] step_in,            // <- step_o (nm_controller)
    input ld,                       // <- ld_o (nm_controller)
    input enable,                   // <- start_vali (nm_controller)
    output reg dir_status_o,        // -> dir_status_in (nm_controller)
    output reg s_done_o,            // -> s_done (nm_controller)
    output reg [6:0] addr_out,
    output reg wren_o,
    input [1:0] data_in
);

reg [6:0] addr;
reg [3:0] step;
reg [1:0] data;
reg [3:0] count;

// validator states
reg [2:0] current_state, next_state;

localparam  S_WAIT_EN           = 3'b0,
            S_VALIDATING_S      = 3'b01,
            S_VALIDATING        = 3'b10,
            S_VALI_SUCC         = 3'b11,
            S_VALI_FAIL         = 3'b100;

always @(posedge clock)
begin: do_stuff
    case (current_state)
        S_WAIT_EN: begin
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
            next_state = enable ? S_VALIDATING_S : S_WAIT_EN;
            count <= 0;
            dir_status_o = 0;
            s_done_o = 0;
        end
        S_VALIDATING_S: begin
            next_state = S_VALIDATING;
            addr_out = addr;
        end
        S_VALIDATING: begin
            data = data_in;
            if (player == 1'b0) begin
                // black move, detect white ones
                if (data == 2'b10)
                    next_state = S_VALIDATING;
                if (data == 2'b01) begin
                    if (count == 4'b0)
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
                    if (count == 4'b0)
                        next_state = S_VALI_FAIL;
                    else 
                        next_state = S_VALI_SUCC;
                end
                if (data == 2'b00 || data == 2'b11)
                    next_state = S_VALI_FAIL;
            end
            count <= count + 1'b1;
            addr <= addr + step;
            addr_out = addr + step;
            wren_o = 0;
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
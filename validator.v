module validator(
    input clock,
    input reset,
    input [6:0] s_addr_in,
    input player,
    input [3:0] step_in,
    input ld,
    input enable;
    output reg dir_status_o,
    output reg s_done_o
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
            addr <= s_addr_in;
            step <= step_in;
            data <= player ? 2'b10 : 2'b01;
        end
    end
end

always @(posedge clock) begin
    if (enable)
        addr <= addr + step;
    

end

always @(posedge clock)
begin: do_stuff
    case (current_state)
        S_WAIT_EN: begin
            if (enable) begin
                next_state = S_VALIDATING;
                addr <= addr + step;
            end
            else begin
                next_state = S_WAIT_EN;
            end
            count <= 0;
            dir_status_o = 0;
            s_done_o = 0;
        end
        S_VALIDATING: begin
            // get value from ram
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
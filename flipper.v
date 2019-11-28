module flipper(
    input clock,                    // <- clock (main_controller)
    input reset,                    // <- reset
    input [6:0] s_addr_in,          // <- s_addr_out (datapath)
    input player,                   // <- player (main_controller)
    input [4:0] step_in,            // <- step_o (nm_controller)
    input ld,                       // <- ld_o (nm_controller)
    input enable,                   // <- start_flip (nm_controller)
    output reg s_done_o,            // -> s_done (nm_controller)
    output reg [6:0] addr_out,
    output reg wren_o,
    output reg ctrl_mem,
    output reg [1:0] data_out,
    input [1:0] data_in
);

reg [6:0] addr;
reg [3:0] step;
reg [1:0] data;

// flipper states
reg [2:0] current_state, next_state;

localparam  S_WAIT_EN           = 3'b0,
            S_FLIPPING_S        = 3'b01,
            S_FLIPPING_READ     = 3'b10,
            S_FLIPPING_WRITE    = 3'b100,
            S_FLIPPING_WAIT     = 3'b101,
            S_FLIP_OVER         = 3'b11;

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
            next_state = enable ? S_FLIPPING_S : S_WAIT_EN;
            s_done_o = 0;
            ctrl_mem = 0;
        end
        S_FLIPPING_S: begin
            ctrl_mem = 1;
            next_state = S_FLIPPING_READ;
            addr_out = addr;
            wren_o = 0;
        end
        S_FLIPPING_READ: begin
            data = data_in;
            if (player == 1'b0) begin
                // black move, detect white ones
                if (data == 2'b10)
                    next_state = S_FLIPPING_WRITE;
                if (data == 2'b01)
                    next_state = S_FLIP_OVER;
            end
            else begin
                // white move, detect black ones
                if (data == 2'b01)
                    next_state = S_FLIPPING_WRITE;
                if (data == 2'b10) 
                    next_state = S_FLIP_OVER;
            end
        end
        S_FLIPPING_WRITE: begin
            data_out = player ? 2'b10 : 2'b01;
            wren_o = 1;
            next_state = S_FLIPPING_WAIT;
        end
        S_FLIPPING_WAIT: begin
            addr <= addr + step;
            addr_out = addr + step;
            wren_o = 0;
            next_state = S_FLIPPING_READ;
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

endmodule // flipper
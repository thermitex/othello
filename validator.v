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

// validator states
reg [1:0] current_state, next_state;

localparam  S_WAIT_EN           = 2'b0,
            S_VALIDATEING       = 2'b1,
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
begin: state_FFs
    if(!reset)
        current_state <= S_WAIT_EN;
    else
        current_state <= next_state;
end // state_FFS

endmodule // validator
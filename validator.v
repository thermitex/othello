module validator(
    input clock,
    input reset,
    input s_addr_in,
    input player,
    input [3:0] step_in,
    input ld,
    input start_vd;
    output reg dir_status_out,
    output reg s_done
);

reg [6:0] addr;
reg [3:0] step;
reg [1:0] data;

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
    if (step != 4'b0)
        addr <= addr + step;
end

endmodule // validator
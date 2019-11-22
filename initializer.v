module initializer(
    input clock,
    input start,
    output reg done,
    output reg [7:0] addr,
    output reg [1:0] data,
    output reg wren;
);

reg [7:0] counter;

always @(posedge clock) begin
    if (!reset) begin
        counter <= 8'b0;
        addr = 8'b0;
        data = 2'b0;
        wren = 0;
        done = 0;
    end
    else begin
        if (start && counter < 8'b1100100) begin
            wren = 1;
            addr = counter;
            if ((counter >= 8'b0 && counter <= 8'b1010) || counter >= 8'b1011010 || counter == 8'b1010 || counter == 8'b10011 || counter == 8'b10100 || counter == 8'b11101 || counter == 8'b11110 || counter == 8'b100111 || counter == 8'b101000 || counter == 8'b110001 || counter == 8'b110010 || counter == 8'b111011 || counter == 8'b111100 || counter == 8'b1000101 || counter == 8'b1000110 || counter == 8'b1001111 || counter == 8'b1010000 || counter == 8'b1011001)
                data = 2'b11;
            else
                data = 2'b00;
            counter <= counter + 1;
        end
        else begin
            wren = 0;
            if (counter >= 8'b1100100)
                done = 1;
        end
    end
end

endmodule // initializer
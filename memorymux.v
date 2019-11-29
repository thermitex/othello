module memorymux(
    input [6:0] addr_init,
    input [6:0] addr_vali,
    input [6:0] addr_flip,
    input [6:0] addr_vga,
    input [1:0] data_init,
    input [1:0] data_vali,
    input [1:0] data_flip,
    input [1:0] data_vga,
    input wren_init,
    input wren_vali,
    input wren_flip,
    input wren_vga,
    input init_ctrl,
    input vali_ctrl,
    input flip_ctrl,
    input vga_ctrl,
    output reg [6:0] addr_out,
    output reg [1:0] data_out,
    output reg wren_out
);

always @(*) begin
    if (init_ctrl) begin
        addr_out = addr_init;
        data_out = data_init;
        wren_out = wren_init;
    end
    else begin
        if (vali_ctrl) begin
            addr_out = addr_vali;
            data_out = data_vali;
            wren_out = wren_vali;
        end
        else begin
            if (flip_ctrl) begin
                addr_out = addr_flip;
                data_out = data_flip;
                wren_out = wren_flip;
            end
            else begin
                if (vga_ctrl) begin
                    addr_out = addr_vga;
                    data_out = data_vga;
                    wren_out = wren_vga;
                end
                else begin
                    wren_out = 0;
                end
            end
        end
    end
end

endmodule // memorymux
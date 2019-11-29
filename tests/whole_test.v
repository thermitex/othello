`timescale 1ns / 1ns

module othello(
    input [9:0] SW,
    input [3:0] KEY,
    // input CLOCK_50,
    output [9:0] LEDR
);

reg CLOCK_50;

initial CLOCK_50 = 1'b0;

wire valid_move;
wire enable_nmc;
wire enable_init;
wire init_finish;
wire player_info;
wire [1:0] from_mem;
wire vali_done;
wire flip_done;
wire vali_dir_status;
wire [4:0] check_step;
wire ld_vali;
wire ld_flip;
wire enable_flip;
wire enable_vali;
wire nm_finish;
wire step_sign;
wire skip_flip;

wire [6:0] addr_mem_init;
wire [6:0] addr_mem_vali;
wire [6:0] addr_mem_flip;
wire [6:0] addr_mem_vga;
wire [1:0] data_mem_init;
wire [1:0] data_mem_vali;
wire [1:0] data_mem_flip;
wire [1:0] data_mem_vga;
wire wren_mem_init;
wire wren_mem_vali;
wire wren_mem_flip;
wire wren_mem_vga;
wire init_mem_ctrl;
wire vali_mem_ctrl;
wire flip_mem_ctrl;
wire vga_mem_ctrl;
wire [6:0] addr_final;
wire [1:0] data_final;
wire wren_final;

memorymux mm(
    .addr_init(addr_mem_init),
    .addr_vali(addr_mem_vali),
    .addr_flip(addr_mem_flip),
    .addr_vga(addr_mem_vga),
    .data_init(data_mem_init),
    .data_vali(data_mem_vali),
    .data_flip(data_mem_flip),
    .data_vga(data_mem_vga),
    .wren_init(wren_mem_init),
    .wren_vali(wren_mem_vali),
    .wren_flip(wren_mem_flip),
    .wren_vga(wren_mem_vga),
    .init_ctrl(init_mem_ctrl),
    .vali_ctrl(vali_mem_ctrl),
    .flip_ctrl(flip_mem_ctrl),
    .vga_ctrl(vga_mem_ctrl),
    .addr_out(addr_final),
    .data_out(data_final),
    .wren_out(wren_final)
);

gameboardRAM ram(
    .address(addr_final),
    .clock(CLOCK_50),
    .data(data_final),
    .wren(wren_final),
    .q(from_mem)
);

// instantialize main controller
main_controller mc(
    .go(~KEY[1]),
    .game_end(~KEY[3]),
    .ack(valid_move),
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .new_move(enable_nmc),
    .nm_done(nm_finish),
    .init_start(enable_init),
    .init_done(init_finish),
    .player(player_info)
);

nm_controller nmc(
    .enable(enable_nmc),
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .s_done_vali(vali_done),
    .s_done_flip(flip_done),
    .dir_status_in(vali_dir_status),
    .step_o(check_step),
    .ld_vali_o(ld_vali),
    .ld_flip_o(ld_flip),
    .nm_done_o(nm_finish),
    .mv_valid_o(valid_move),
    .step_sign_o(step_sign),
    .skip_flip_o(skip_flip),
    .start_vali(enable_vali),
    .start_flip(enable_flip)
);

initializer init(
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .start(enable_init),
    .done(init_finish),
    .ctrl_mem(init_mem_ctrl),
    .addr(addr_mem_init),
    .data(data_mem_init),
    .wren(wren_mem_init)
);

validator vali(
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .s_addr_in(SW[6:0]),
    .player(player_info),
    .step_in(check_step),
    .ld(ld_vali),
    .enable(enable_vali),
    .dir_status_o(vali_dir_status),
    .s_done_o(vali_done),
    .addr_out(addr_mem_vali),
    .wren_o(wren_mem_vali),
    .ctrl_mem(vali_mem_ctrl),
    .step_sign_in(step_sign),
    .data_in(from_mem)
);

flipper flip(
    .clock(CLOCK_50),
    .reset(KEY[0]),
    .s_addr_in(SW[6:0]),
    .player(player_info),
    .step_in(check_step),
    .ld(ld_flip),
    .enable(enable_flip),
    .s_done_o(flip_done),
    .addr_out(addr_mem_flip),
    .wren_o(wren_mem_flip),
    .ctrl_mem(flip_mem_ctrl),
    .step_sign_in(step_sign),
    .skip_flip_in(skip_flip),
    .data_out(data_mem_flip),
    .data_in(from_mem)
);

always #1 CLOCK_50 = ~CLOCK_50;

endmodule // othello
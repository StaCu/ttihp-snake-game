/*
 * Copyright (c) 2024 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_snake_game (
	input  logic [7:0] ui_in,    // Dedicated inputs
	output logic [7:0] uo_out,   // Dedicated outputs
	input  logic [7:0] uio_in,   // IOs: Input path
	output logic [7:0] uio_out,  // IOs: Output path
	output logic [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
	input  logic       ena,      // always 1 when the design is powered, so you can ignore it
	input  logic       clk,      // clock
	input  logic       rst_n     // reset_n - low to reset
);

	// All output pins must be assigned. If not used, assign to 0.
	//assign uo_out       = 8'b0;
	assign uio_out[7:3] = 5'b0;
	assign uio_oe       = 8'b00000111;

	// List all unused inputs to prevent warnings
	logic _unused = &{ena, uio_in, ui_in[7:6], 1'b0};

	game game_inst (
		.clk(clk),
		.rst_n(rst_n),

		.i_up(ui_in[0]),
		.i_down(ui_in[1]),
		.i_left(ui_in[2]),
		.i_right(ui_in[3]),
		.i_phase(ui_in[4]),
		.i_restart(ui_in[5]),

		.o_vga_r({ uo_out[0], uo_out[4] }),
		.o_vga_g({ uo_out[1], uo_out[5] }),
		.o_vga_b({ uo_out[2], uo_out[6] }),
		.o_vga_vsync(uo_out[3]),
		.o_vga_hsync(uo_out[7]),

		.o_failure(uio_out[0]),
		.o_success(uio_out[1]),
		.o_eat(uio_out[2])
	);

endmodule

/*
* Copyright (c) 2024 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module vga (
	input  logic       clk,
	input  logic       rst_n,
	output logic [1:0] r,
	output logic [1:0] g,
	output logic [1:0] b,
	output logic       vsync,
	output logic       hsync,

	input  logic [4:0] apple_x,
	input  logic [3:0] apple_y,
	input  logic       apple_valid,

	input  logic [4:0] snake_x,
	input  logic [3:0] snake_y,
	input  logic [1:0] snake_dir,
	input  logic       snake_first,
	input  logic       snake_last,
	input  logic       snake_valid,

	input  logic       failure,
	input  logic       success,
	input  logic       eat
);

	logic visible;
	logic [9:0] px;
	logic [8:0] py;
	logic [4:0] tx;
	logic [3:0] ty;
	assign tx = px[9:5];
	assign ty = py[8:5];

	logic [5:0] rgb;
	assign r = rgb[5:4];
	assign g = rgb[3:2];
	assign b = rgb[1:0];

	vga_sync vga_sync_inst (
		.clk(clk),
		.rst_n(rst_n),
		.px(px),
		.py(py),
		.visible(visible),
		.vsync(vsync),
		.hsync(hsync)
	);

	logic [2:0] row_buffer [19:0];

	always @(*) begin
		rgb = 6'b000000;
		if (!visible) begin
			rgb = 6'b000000;
		end else if (tx == 0 || tx == 21) begin
			rgb = 6'b111111;
		end else begin
			case (row_buffer[tx-1])
				0: rgb = 6'b000000;
				1: rgb = 6'b000000;
				2: rgb = 6'b000000;
				3: rgb = 6'b110000;
				4: rgb = 6'b001100;
				5: rgb = 6'b001100;
				6: rgb = 6'b001100;
				7: rgb = 6'b001100;
			endcase
		end
	end

	always @(posedge clk) begin
		if (hsync || !rst_n) begin		
			for (int i = 0; i < 20; i = i + 1) begin
				row_buffer[i] <= 3'b0;
			end
		end
		if (ty == snake_y && snake_valid) begin
			row_buffer[snake_x-1] <= { 1'b1, snake_dir };
		end else if (ty == apple_y && apple_valid) begin
			row_buffer[apple_x-1] <= 3'b011;
		end
	end

endmodule

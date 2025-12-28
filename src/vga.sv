/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module vga (
	input  logic       clk,
	input  logic       rst_n,
	input  logic       game_rst_n,
	output logic [1:0] r,
	output logic [1:0] g,
	output logic [1:0] b,
	output logic       vsync,
	output logic       hsync,

	input  logic [4:0] apple_x,
	input  logic [3:0] apple_y,
	input  logic       apple_valid,

	input  logic [4:0] snake_head_x,
	input  logic [3:0] snake_head_y,
	input  logic [4:0] snake_x,
	input  logic [3:0] snake_y,
	input  logic [1:0] snake_dir,
	input  logic       snake_first,
	input  logic       snake_last,
	input  logic       snake_valid,

	input  logic       failure,
	input  logic       success,
	input  logic       eat,
	input  logic       colorblind
);

	logic visible;
	logic [9:0] px;
	logic [9:0] py;
	logic [9:0] next_px;
	logic [9:0] next_py;
	logic [4:0] tx;
	logic [3:0] ty;
	logic [4:0] next_tx;
	logic [3:0] next_ty;
	assign tx = px[9:5];
	assign ty = py[8:5];
	assign next_tx = next_px[9:5];
	assign next_ty = next_py[8:5];

	logic [5:0] rgb;
	assign r = rgb[5:4];
	assign g = colorblind ? rgb[1:0] : rgb[3:2];
	assign b = colorblind ? rgb[3:2] : rgb[1:0];

	vga_sync vga_sync_inst (
		.clk(clk),
		.rst_n(rst_n),
		.px(px),
		.py(py),
		.next_px(next_px),
		.next_py(next_py),
		.visible(visible),
		.vsync(vsync),
		.hsync(hsync)
	);

	parameter int BUFFER_WIDTH = (GAME_WIDTH/2);
	parameter [5:0] ROW_OFFSET = 25;

	logic [1:0] sx;
	logic [1:0] sy;
	logic [1:0] prev_dir;
	logic [3:0] decode_dir;
	logic [3:0] decode_prev_dir;
	logic [3:0] two_hot_dir;
	logic [3:0] row_buffer [BUFFER_WIDTH-1:0];

	always @(*) begin
		decode_dir = 0;
		decode_dir[snake_dir] = ~snake_last;
		decode_prev_dir = 0;
		decode_prev_dir[prev_dir] = ~snake_first;
		two_hot_dir = decode_prev_dir | decode_dir;
	end

	always @(*) begin
		rgb = 6'b000000;
		if (!visible) begin
			rgb = 6'b000000;
		end else if (tx == 0 || tx == GAME_WIDTH+1 || ty == 0 || ty == GAME_HEIGHT+1) begin
			case ({ success, failure })
				2'b10: rgb = 6'b001000;
				2'b01: rgb = 6'b100000;
				default: rgb = 6'b111111;
			endcase
		end else if ({sx, sy} == 4'b0101 && row_buffer[0] != 0) begin
			// snake center
			rgb = 6'b001100;
		end else if ({sx, sy} == 4'b0101 && tx == apple_x && ty == apple_y && apple_valid) begin
			// apple center
			rgb = 6'b110000;
		end else if ({sx, sy} == 4'b0110 && row_buffer[0][0]) begin
			// top-center
			rgb = 6'b001100;
		end else if ({sx, sy} == 4'b0100 && row_buffer[0][1]) begin
			// bottom-center
			rgb = 6'b001100;
		end else if ({sx, sy} == 4'b1001 && row_buffer[0][2]) begin
			// left-center
			rgb = 6'b001100;
		end else if ({sx, sy} == 4'b0001 && row_buffer[0][3]) begin
			// right-center
			rgb = 6'b001100;
		end else /*if (row_buffer[0] == 0 || {sx, sy} == 4'b0000 || {sx, sy} == 4'b1000 || {sx, sy} == 4'b0010 || {sx, sy} == 4'b1010)*/ begin
			// no snake or corner
			rgb = 6'b000000;
		end
	end

	always @(posedge clk) begin
		prev_dir <= { snake_dir[1], ~snake_dir[0] };
		case (px[4:0])
			3: sx <= 1;
			27: sx <= 2;
			31: sx <= 0;
		endcase
		case (py[4:0])
			0: sy <= 0;
			4: sy <= 1;
			28: sy <= 2;
		endcase
	end

	always @(posedge clk) begin
		if (snake_valid) begin
			if (snake_y == ty && snake_x > tx && snake_x < tx + BUFFER_WIDTH) begin
				// same row
				row_buffer[snake_x-tx] = two_hot_dir;
			end else if (snake_y == next_ty && snake_x + ROW_OFFSET > tx && snake_x + ROW_OFFSET < tx + BUFFER_WIDTH) begin
				// next row
				row_buffer[snake_x+ROW_OFFSET-tx] = two_hot_dir;
			end
		end
		if (px[4:0] == 31) begin
			for (int i = 0; i < BUFFER_WIDTH-1; i = i + 1) begin
				row_buffer[i] = row_buffer[i+1];
			end
			row_buffer[BUFFER_WIDTH-1] = 0;
		end
	end

endmodule

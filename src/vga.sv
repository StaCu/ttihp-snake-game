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
	assign g = rgb[3:2];
	assign b = rgb[1:0];
	logic s_vsync;
	logic s_hsync;

	vga_sync vga_sync_inst (
		.clk(clk),
		.rst_n(rst_n),
		.px(px),
		.py(py),
		.next_px(next_px),
		.next_py(next_py),
		.visible(visible),
		.vsync(s_vsync),
		.hsync(s_hsync)
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
	logic [1:0] color;

	always @(*) begin
		case (color)
			0: rgb = 6'b000000;
			1: rgb = colorblind ? 6'b001111 : 6'b001100;
			2: rgb = 6'b110000;
			3: rgb = 6'b111111;
		endcase
	end

	always @(*) begin
		decode_dir = 0;
		decode_dir[snake_dir] = ~snake_last;
		decode_prev_dir = 0;
		decode_prev_dir[prev_dir] = ~snake_first;
		two_hot_dir = decode_prev_dir | decode_dir;
	end

	always @(posedge clk) begin
		vsync <= s_vsync;
		hsync <= s_hsync;
	end

	always @(posedge clk) begin
		color = 0;
		if (!visible) begin
			color = 0;
		end else if (tx == 0 || tx == GAME_WIDTH+1 || ty == 0 || ty == GAME_HEIGHT+1) begin
			case ({ success, failure })
				2'b10: color = 1;
				2'b01: color = 2;
				default: color = 3;
			endcase
		end else casez ({sx, sy, row_buffer[0], |row_buffer[0], tx == apple_x && ty == apple_y && apple_valid})
			10'b0110_???1_?_?: color = 1; // top-center
			10'b0100_??1?_?_?: color = 1; // bottom-center
			10'b1001_?1??_?_?: color = 1; // left-center
			10'b0001_1???_?_?: color = 1; // right-center
			10'b0101_????_1_?: color = 1; // snake-center
			10'b0101_????_0_1: color = 2; // apple-center
			default: color = 0; // no snake or corner
		endcase
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

	logic [4:0] row_buffer_widx;
	logic       row_buffer_write;

	always @(*) begin
		row_buffer_widx = snake_x - tx;
		row_buffer_write = 0;
		if (snake_valid) begin
			if (snake_y == ty && snake_x > tx && snake_x < tx + BUFFER_WIDTH) begin
				// same row
				row_buffer_write = 1;
			end else if (snake_y == next_ty && snake_x + ROW_OFFSET > tx && snake_x + ROW_OFFSET < tx + BUFFER_WIDTH) begin
				// next row
				row_buffer_widx = snake_x + ROW_OFFSET - tx;
				row_buffer_write = 1;
			end
		end
	end

	always @(posedge clk) begin
		for (int i = 0; i < BUFFER_WIDTH; i = i + 1) begin
			if (px[4:0] == 31) begin
				if (i+1 == row_buffer_widx && row_buffer_write) begin
					row_buffer[i] <= two_hot_dir | row_buffer[i+1];
				end else if (i == BUFFER_WIDTH-1) begin
					row_buffer[i] <= 0;
				end else begin
					row_buffer[i] <= row_buffer[i+1];
				end
			end else if (i == row_buffer_widx && row_buffer_write) begin
				row_buffer[i] <= two_hot_dir | row_buffer[i];
			end else begin
				row_buffer[i] <= row_buffer[i];
			end
		end
	end

endmodule

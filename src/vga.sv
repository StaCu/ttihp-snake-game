/*
* Copyright (c) 2024 David Volz
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

	logic [1:0] pos_counter;
	logic [1:0] row_buffer [GAME_WIDTH-1:0];

	always @(*) begin
		rgb = 6'b000000;
		if (!visible) begin
			rgb = 6'b000000;
		end else if (tx == snake_head_x && ty == snake_head_y && game_rst_n) begin
			rgb = 6'b101000;
		end else if (tx == 0 || tx == GAME_WIDTH+1 || ty == 0 || ty == GAME_HEIGHT+1) begin
			rgb = 6'b111111;
		end else if (tx == apple_x && ty == apple_y && apple_valid) begin
			rgb = 6'b110000;
		end else begin
			case (row_buffer[tx-1])
				0: rgb = 6'b000000;
				1: rgb = 6'b000100;
				2: rgb = 6'b001000;
				3: rgb = 6'b001100;
			endcase
		end
	end

	always @(posedge clk) begin
		if (hsync) begin		
			for (int i = 0; i < GAME_WIDTH; i = i + 1) begin
				row_buffer[i] <= 2'b00;
			end
		end

		if (snake_first) begin
			pos_counter <= 1;
		end else if (pos_counter == 3) begin
			pos_counter <= 1;
		end else begin
			pos_counter <= pos_counter + 1;
		end

		if (ty == snake_y && snake_valid) begin
			row_buffer[snake_x-1] <= pos_counter;
		end
	end

endmodule

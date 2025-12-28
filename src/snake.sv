/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module snake (
	input  logic       clk,
	input  logic       rst_n,

	input  logic       i_tick,
	input  logic [1:0] i_dir,
	output logic [1:0] o_head_dir,
	output logic       o_tick_done,

	input  logic       i_eat,

	output logic [4:0] o_head_x,
	output logic [3:0] o_head_y,
	output logic [4:0] o_pos_x,
	output logic [3:0] o_pos_y,
	output logic [1:0] o_pos_dir,
	output logic       o_pos_first,
	output logic       o_pos_last,
	output logic       o_pos_valid,
	output logic       o_failure,
	output logic       o_success
);

	logic [1:0] dir_out;
	logic [1:0] dir_in;
	logic [1:0] dir_first;

	// The snake is stored in a shift register.
	// Every element holds the information of which direction to go next (head to tail).
	shiftreg #(
		.WIDTH(2),
		.DEPTH(MAX_LENGTH)
	) shiftreg_inst (
		.clk(clk),
		.out(dir_out),
		.in(dir_in),
		.first(dir_first)
	);

	logic [1:0] head_dir;
	logic [4:0] head_x;
	logic [3:0] head_y;
	logic [7:0] length;
	logic [1:0] next_head_dir;
	logic [4:0] next_head_x;
	logic [3:0] next_head_y;
	logic [7:0] next_length;
	assign o_head_x = head_x;
	assign o_head_y = head_y;
	assign o_head_dir = head_dir;

	logic [4:0] pos_x;
	logic [3:0] pos_y;
	logic [7:0] pos;
	logic       pos_valid;
	logic [4:0] next_pos_x;
	logic [3:0] next_pos_y;
	logic [7:0] next_pos;
	logic       next_pos_valid;

	assign o_pos_x = pos_x;
	assign o_pos_y = pos_y;
	assign o_pos_dir = dir_first;
	assign o_pos_first = pos == 0;
	assign o_pos_last  = pos == length;
	assign o_pos_valid = pos_valid;
	assign o_success = length == (MAX_LENGTH-1);
	assign o_failure = pos_valid && pos != 0 && ((head_x == pos_x && head_y == pos_y) || head_x == 0 || head_x == (GAME_WIDTH+1) || head_y == 0 || head_y == (GAME_HEIGHT+1));

	always @(*) begin
		dir_in = dir_out;
		o_tick_done = 0;

		next_head_dir = head_dir;
		next_head_x = head_x;
		next_head_y = head_y;
		next_length = length + { 7'b0, i_eat };

		next_pos_x = pos_x;
		next_pos_y = pos_y;
		next_pos_valid = pos_valid;

		if (pos == (MAX_LENGTH-2) && i_tick) begin
			case (i_dir)
				2'b00: next_head_y = head_y - 1;
				2'b01: next_head_y = head_y + 1;
				2'b10: next_head_x = head_x - 1;
				2'b11: next_head_x = head_x + 1;
			endcase
			dir_in = i_dir;
			next_head_dir = i_dir;
			next_pos_x = next_head_x;
			next_pos_y = next_head_y;
			next_pos = 0;
			next_pos_valid = 1;
			o_tick_done = 1;
		end else if (pos == (MAX_LENGTH-1)) begin
			next_pos_x = head_x;
			next_pos_y = head_y;
			next_pos = 0;
			next_pos_valid = 1;
		end else begin
			case (dir_first)
				2'b00: next_pos_y = pos_y + 1;
				2'b01: next_pos_y = pos_y - 1;
				2'b10: next_pos_x = pos_x + 1;
				2'b11: next_pos_x = pos_x - 1;
			endcase
			next_pos = pos + 1;
			if (pos == length) begin
				next_pos_valid = 0;
			end
		end
		if (!rst_n) begin
			dir_in = 2'b11;
		end
	end

	always @(posedge clk) begin
		if (!rst_n) begin
			head_dir <= 2'b11;
			head_x <= (GAME_WIDTH + 3) / 2;
			head_y <= (GAME_HEIGHT + 3) / 2;
			length <= 1;
			pos <= (MAX_LENGTH-1);
			pos_valid <= 0;
		end else begin
			head_dir <= next_head_dir;
			head_x <= next_head_x;
			head_y <= next_head_y;
			length <= next_length;
			pos <= next_pos;
			pos_valid <= next_pos_valid;
		end

		pos_x <= next_pos_x;
		pos_y <= next_pos_y;
	end

endmodule

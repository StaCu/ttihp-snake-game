/*
* Copyright (c) 2024 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module snake (
	input  logic       clk,
	input  logic       rst_n,

	input  logic       i_tick,
	input  logic [1:0] i_dir,
	output logic [1:0] o_dir,

	input  logic       i_eat,

	output logic [4:0] o_pos_x,
	output logic [3:0] o_pos_y,
	output logic       o_pos_first,
	output logic       o_pos_last,
	output logic       o_pos_valid,
	output logic       o_failure,
	output logic       o_success
);

	logic [1:0] prev_dir;
	logic [1:0] next_dir;

	shiftreg #(
		.WIDTH(2),
		.DEPTH(220)
	) shiftreg_inst (
		.clk(clk),
		.i_data(next_dir),
		.o_data(prev_dir)
	);

	assign o_dir = prev_dir;

	logic [4:0] head_x;
	logic [3:0] head_y;
	logic [7:0] length;
	logic [4:0] next_head_x;
	logic [3:0] next_head_y;
	logic [7:0] next_length;

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
	assign o_pos_first = pos == 0;
	assign o_pos_last  = pos == length;
	assign o_pos_valid = pos_valid;
	assign o_success = length == 220;
	assign o_failure = pos_valid && pos != 0 && ((head_x == pos_x && head_y == pos_y) || head_x == 0 || head_x == 21 || head_y == 0 || head_y == 21);

	always @(*) begin
		next_dir = prev_dir;

		next_head_x = head_x;
		next_head_y = head_y;
		next_length = length + { 7'b0, i_eat };

		next_pos_x = pos_x;
		next_pos_y = pos_y;
		next_pos = pos == 219 ? 0 : pos + 1;
		next_pos_valid = pos_valid;

		if (pos == 219) begin
			if (i_tick) begin
				case (i_dir)
					2'b00: next_head_y = head_y + 1;
					2'b01: next_head_y = head_y - 1;
					2'b10: next_head_x = head_x + 1;
					2'b11: next_head_x = head_x - 1;
				endcase
			end
			next_pos_x = head_x;
			next_pos_y = head_y;
			next_pos = 0;
			next_pos_valid = 1;
			next_dir = i_dir;
		end else begin
			case (prev_dir)
				2'b00: next_pos_y = pos_y - 1;
				2'b01: next_pos_y = pos_y + 1;
				2'b10: next_pos_x = pos_x - 1;
				2'b11: next_pos_x = pos_x + 1;
			endcase
			next_pos = pos + 1;
			if (pos == length) begin
				next_pos_valid = 0;
			end
		end
		if (!rst_n) begin
			next_dir = 0;
		end
	end

	always @(posedge clk) begin
		if (!rst_n) begin
			head_x <= 10;
			head_y <= 5;
			length <= 2;
			pos <= 219;
			pos_valid <= 0;
		end else begin
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

/*
* Copyright (c) 2024 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module apple (
	input  logic       clk,
	input  logic       rst_n,
	input  logic [4:0] i_snake_x,
	input  logic [3:0] i_snake_y,
	input  logic       i_snake_first,
	input  logic       i_snake_last,
	input  logic       i_snake_valid,
	output logic [4:0] o_apple_x,
	output logic [3:0] o_apple_y,
	output logic       o_ready,
	output logic       o_eat
);

	logic [8:0] rng;

	random random_inst (
		.clk(clk),
		.o_rng(rng)
	);

	logic [4:0] apple_x;
	logic [3:0] apple_y;
	logic ready;
	logic test;
	assign o_apple_x = apple_x;
	assign o_apple_y = apple_y;

	logic [4:0] next_apple_x;
	logic [3:0] next_apple_y;
	logic next_ready;
	logic next_test;

	logic equal_pos;
	logic snake_eat_apple;
	logic snake_on_apple;
	assign equal_pos = i_snake_x == apple_x && i_snake_y == apple_y;
	assign snake_eat_apple = i_snake_first && ready && equal_pos;
	assign snake_on_apple  = i_snake_valid && equal_pos;
	assign o_eat = snake_eat_apple;
	assign o_ready = ready;

	logic apple_x_oob = apple_x == 0 || apple_x > 20;
	logic apple_y_oob = apple_y == 0 || apple_y > 11;

	always @(*) begin
		next_test = test;
		next_ready = ready;
		next_apple_x = apple_x;
		next_apple_y = apple_y;
		if (snake_eat_apple || !rst_n) begin
			next_ready = 0;
			next_test = 0;
			next_apple_x = rng[8:4];
			next_apple_y = rng[3:0];
		end else if (snake_on_apple || apple_x_oob || apple_y_oob) begin
			next_ready = 0;
			next_test = 0;
			// the next increments ensure that the apple will eventually find a legal position
			// - it is not out of bounds
			// - it is not inside the snake
			// `apple.py` proves that this will hit every posible position.
			if (apple_x_oob || !apple_y_oob) begin
				next_apple_x = apple_x + 11;
			end
			if (apple_y_oob || !apple_x_oob) begin
				next_apple_y = apple_y + 7;
			end
		end else if (i_snake_first) begin
			next_test = 1;
		end else if (!i_snake_valid && test) begin
			next_ready = 1;
		end
	end

	always @(posedge clk) begin
		if (!rst_n) begin
			ready <= 0;
			test <= 0;
		end else begin
			ready <= next_ready;
			test <= next_test;
		end
		apple_x <= next_apple_x;
		apple_y <= next_apple_y;
	end

endmodule

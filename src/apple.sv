/*
* Copyright (c) 2024 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module apple (
	input  logic       clk,
	input  logic       rst_n,
	input  logic       rng_rst_n,
	input  logic       i_new_user_input,
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

	logic [3:0] rng4;
	logic [4:0] rng5;
	logic [4:0] rng_update;

	random random_inst (
		.clk(clk),
		.rst_n(rng_rst_n),
		.update(rng_update),
		.rng4(rng4),
		.rng5(rng5)
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

	// Test if the apple position is outside the game field (out of bounds).
	// => The galois rng will never return 0, so no need to check it
	logic apple_x_oob = /*apple_x == 0 ||*/apple_x > 20;
	logic apple_y_oob = /*apple_y == 0 ||*/apple_y > 11;

	always @(*) begin
		// Update the rng when the apple has a valid position.
		// If we are in the test-phase, we have a more specific rule when to update the rng.
		// Mix in user input for some extra randomness.
		rng_update = ready ^ i_new_user_input;
		next_test = test;
		next_ready = ready;
		next_apple_x = apple_x;
		next_apple_y = apple_y;
		if (snake_eat_apple || snake_on_apple || apple_x_oob || apple_y_oob || !rst_n) begin
			// We must ensure that the apple will always find an empty spot, even if only one is remaining.
			// The galois rngs have 15 and 31 iterations each and will only repeat pairs after 15*31 iterations,
			// because that is the smallest common multiple.
			// Since the only update the rngs once per test, we will therefore test every position eventually. 
			next_ready = 0;
			next_test = 0;
			next_apple_x = rng5;
			next_apple_y = rng4;
			rng_update = 1;
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

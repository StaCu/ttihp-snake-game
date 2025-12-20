/*
* Copyright (c) 2025 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module game (
	input  logic       clk,
	input  logic       rst_n,

	input  logic       i_up,
	input  logic       i_down,
	input  logic       i_left,
	input  logic       i_right,
	input  logic       i_phase,
	input  logic       i_restart,

	output logic [1:0] o_vga_r,
	output logic [1:0] o_vga_g,
	output logic [1:0] o_vga_b,
	output logic       o_vga_vsync,
	output logic       o_vga_hsync,

	output logic       o_failure,
	output logic       o_success,
	output logic       o_eat
);

	logic       tick;
	logic       next_tick;
	logic       phase;
	logic       next_phase;
	logic       start;
	logic	    failure;
	logic	    success;
	assign o_failure = failure;
	assign o_success = success;

	logic       restart;
	assign restart = i_restart || !rst_n;

	logic [1:0] curr_dir;
	logic [1:0] next_dir;

	control control_inst (
		.clk(clk),
		.rst_n(!restart),
		.i_up(i_up),
		.i_down(i_down),
		.i_left(i_left),
		.i_right(i_right),
		.i_dir(curr_dir),
		.o_dir(next_dir),
		.o_start(start)
	);

	logic [4:0] pos_x;
	logic [3:0] pos_y;
	logic       pos_first;
	logic       pos_last;
	logic       pos_valid;
	logic	    snake_failure;
	logic	    snake_success;
	logic	    snake_eat_apple;
	logic [4:0] apple_x;
	logic [3:0] apple_y;
	logic	    apple_ready;
	assign o_eat = snake_eat_apple;

	snake snake_inst (
		.clk(clk),
		.rst_n(!restart),
		.i_tick(tick),
		.i_dir(next_dir),
		.o_dir(curr_dir),
		.o_pos_x(pos_x),
		.o_pos_y(pos_y),
		.o_pos_first(pos_first),
		.o_pos_last(pos_last),
		.o_pos_valid(pos_valid),
		.o_failure(snake_failure),
		.o_success(snake_success),
		.i_eat(snake_eat_apple)
	);

	apple apple_inst (
		.clk(clk),
		.rst_n(!restart),
		.i_snake_x(pos_x),
		.i_snake_y(pos_y),
		.i_snake_first(pos_first),
		.i_snake_last(pos_last),
		.i_snake_valid(pos_valid),
		.o_apple_x(apple_x),
		.o_apple_y(apple_y),
		.o_ready(apple_ready),
		.o_eat(snake_eat_apple)
	);

	vga vga_inst (
		.clk(clk),
		.rst_n(rst_n),
		.r(o_vga_r),
		.g(o_vga_g),
		.b(o_vga_b),
		.vsync(o_vga_vsync),
		.hsync(o_vga_hsync),

		.apple_x(apple_x),
		.apple_y(apple_y),
		.apple_valid(apple_ready),

		.snake_x(pos_x),
		.snake_y(pos_y),
		.snake_dir(curr_dir),
		.snake_first(pos_first),
		.snake_last(pos_last),
		.snake_valid(pos_valid),

		.failure(failure),
		.success(success),
		.eat(snake_eat_apple)
	);

	always @(*) begin
		next_tick = tick;
		next_phase = phase;
		if (pos_first) begin
			next_tick = 0;
		end else if (phase != i_phase && apple_ready && !failure && !success && start) begin
			// the next game tick can only happen when the following conditions are met:
			// - the game has started
			// - the next phase is provided by input
			// - the game itself is ready for a tick
			// If the previous game tick has not been applied yet, we loose 1 tick
			next_tick = 1;
			next_phase = i_phase;
		end
	end

	always @(posedge clk) begin
		if (restart) begin
			tick <= 0;
			phase <= i_phase;
			failure <= 0;
			success <= 0;
		end else begin
			failure <= failure | snake_failure;
			success <= success | snake_success;
			tick <= next_tick;
			phase <= next_phase;
		end
	end

endmodule

/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module game (
	input  logic       clk,
	input  logic       rst_n,

	input  logic       i_up,
	input  logic       i_down,
	input  logic       i_left,
	input  logic       i_right,
	input  logic       i_pause,
	input  logic       i_restart,

	output logic [1:0] o_vga_r,
	output logic [1:0] o_vga_g,
	output logic [1:0] o_vga_b,
	output logic       o_vga_vsync,
	output logic       o_vga_hsync,

	output logic       o_failure,
	output logic       o_success,
	output logic       o_eat,
	output logic       o_tick
);

	logic       tick;
	logic       tick_done;
	logic       apply_tick;
	logic       tick_vsync;
	logic       start;
	logic	    failure;
	logic	    success;
	assign o_failure = failure;
	assign o_success = success;
	assign o_tick = tick_done;

	logic       restart;
	assign restart = i_restart || !rst_n;

	tickgen tickgen_inst (
		.clk(clk),
		.rst_n(rst_n),
		.i_up(i_up),
		.i_down(i_down),
		.i_restart(i_restart),
		.i_vsync(tick_vsync && !i_pause),
		.i_tick_done(tick_done || !apply_tick),
		.o_tick(tick)
	);

	logic [1:0] head_dir;
	logic [1:0] next_dir;
	logic new_user_input;

	control control_inst (
		.clk(clk),
		.rst_n(!restart),
		.i_up(i_up),
		.i_down(i_down),
		.i_left(i_left),
		.i_right(i_right),
		.i_head_dir(head_dir),
		.o_dir(next_dir),
		.o_start(start),
		.o_new_user_input(new_user_input)
	);

	logic [4:0] head_x;
	logic [3:0] head_y;
	logic [4:0] pos_x;
	logic [3:0] pos_y;
	logic [1:0] pos_dir;
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
		.i_tick(tick & apply_tick),
		.i_dir(next_dir),
		.o_head_dir(head_dir),
		.o_tick_done(tick_done),
		.o_head_x(head_x),
		.o_head_y(head_y),
		.o_pos_x(pos_x),
		.o_pos_y(pos_y),
		.o_pos_dir(pos_dir),
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
		.rng_rst_n(rst_n),
		.i_new_user_input(new_user_input),
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
		.game_rst_n(!restart),
		.r(o_vga_r),
		.g(o_vga_g),
		.b(o_vga_b),
		.vsync(o_vga_vsync),
		.hsync(o_vga_hsync),

		.apple_x(apple_x),
		.apple_y(apple_y),
		.apple_valid(apple_ready),

		.snake_head_x(head_x),
		.snake_head_y(head_y),
		.snake_x(pos_x),
		.snake_y(pos_y),
		.snake_dir(pos_dir),
		.snake_first(pos_first),
		.snake_last(pos_last),
		.snake_valid(pos_valid),

		.failure(failure),
		.success(success),
		.eat(snake_eat_apple)
	);

	always @(*) begin
		// the next game tick can only happen when the following conditions are met:
		// - the game has started
		// - the next phase is provided by input
		// - the game itself is ready for a tick
		// If the previous game tick has not been applied yet, we loose 1 tick
		apply_tick = apple_ready && !failure && !success && start;
	end

	always @(posedge clk) begin
		if (restart) begin
			failure <= 0;
			success <= 0;
		end else begin
			failure <= failure | snake_failure;
			success <= success | snake_success;
		end
	end

`ifdef RTL_SIMULATION
	// The normal vsync pulse only happens every 420000 cycles, which is just too slow for simulation purposes
	// This section links the vsync pulse for the tick generator to a much quicker counter.
	logic [15:0] rtl_simulation_tick_vsync_counter;

	always @(posedge clk) begin
		if (!rst_n) begin
			rtl_simulation_tick_vsync_counter <= 0;
			tick_vsync <= 0;
		end else if (rtl_simulation_tick_vsync_counter == 20) begin
			rtl_simulation_tick_vsync_counter <= 0;
			tick_vsync <= 1;
		end else begin
			rtl_simulation_tick_vsync_counter <= rtl_simulation_tick_vsync_counter + 1;
			tick_vsync <= 0;
		end
	end
`else
	assign tick_vsync = o_vga_vsync;
`endif

endmodule

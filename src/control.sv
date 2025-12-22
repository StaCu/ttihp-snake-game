/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module control (
	input  logic       clk,
	input  logic       rst_n,
	input  logic       i_up,
	input  logic       i_down,
	input  logic       i_left,
	input  logic       i_right,
	input  logic [1:0] i_head_dir,
	output logic [1:0] o_dir,
    output logic       o_start,
    output logic       o_new_user_input
);

    logic [1:0] backwards;
    assign backwards = { i_head_dir[1], ~i_head_dir[0] };

    logic [1:0] next_dir;
    logic [1:0] dir;
    assign o_dir = dir;

    logic start;
    assign o_start = start;

    assign o_new_user_input = dir != next_dir;

    always @(*) begin
        next_dir = dir;
        if (i_up && backwards != 2'b00 && (i_head_dir != 2'b00 || !start)) begin
            next_dir = 2'b00;
        end else if (i_down && backwards != 2'b01 && i_head_dir != 2'b01) begin
            next_dir = 2'b01;
        end else if (i_left && backwards != 2'b10 && i_head_dir != 2'b10) begin
            next_dir = 2'b10;
        end else if (i_right && backwards != 2'b11 && i_head_dir != 2'b11) begin
            next_dir = 2'b11;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            start <= 0;
            dir <= 2'b01;
        end else begin
            start <= start | dir != 2'b01;
            dir <= next_dir;
        end
    end

endmodule

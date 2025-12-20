/*
* Copyright (c) 2025 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module control (
	input  logic       clk,
	input  logic       rst_n,
	input  logic       i_up,
	input  logic       i_down,
	input  logic       i_left,
	input  logic       i_right,
	input  logic [1:0] i_dir,
	output logic [1:0] o_dir,
    output logic       o_start
);

    logic horizontal;
    assign horizontal = i_dir[1];

    logic [1:0] next_dir;
    assign o_dir = next_dir;

    logic start;
    assign o_start = start;

    always @(*) begin
        next_dir = i_dir;
        if (horizontal && i_up) begin
            next_dir = 2'b00;
        end else if (horizontal && i_down) begin
            next_dir = 2'b01;
        end else if (!horizontal && i_left) begin
            next_dir = 2'b10;
        end else if (!horizontal && i_right) begin
            next_dir = 2'b11;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            start <= 0;
        end else begin
            start <= start | i_up | i_left | i_right;
        end
    end

endmodule

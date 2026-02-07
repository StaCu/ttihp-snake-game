/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */
/*
`include "common.sv"

module shiftreg # (
    parameter WIDTH = 2,
    parameter DEPTH = 220
) (
	input  logic             clk,
	output logic [WIDTH-1:0] out,
	input  logic [WIDTH-1:0] in,
	output logic [WIDTH-1:0] first
);

	logic [WIDTH-1:0] memory [DEPTH-1:0];
    assign out = memory[DEPTH-1];
    assign first = memory[0];

	always @(posedge clk) begin
		for (int i = 1; i < DEPTH; i = i + 1) begin
			memory[i] <= memory[i-1];
		end
		memory[0] <= in;
	end

endmodule
*/
/*
* Copyright (c) 2024 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module shiftreg # (
    parameter WIDTH = 2,
    parameter DEPTH = 220
) (
	input  logic             clk,
	input  logic [WIDTH-1:0] i_data,
	output logic [WIDTH-1:0] o_data
);

	logic [WIDTH-1:0] memory [DEPTH-1:0];
    assign o_data = memory[DEPTH-1];

	always @(posedge clk) begin
		for (int i = 1; i < DEPTH; i = i + 1) begin
			memory[i] <= memory[i-1];
		end
		memory[0] <= i_data;
	end

endmodule

/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module shiftreg # (
    parameter WIDTH = 2,
    parameter DEPTH = 234
) (
	input  logic             clk,
	output logic [WIDTH-1:0] out,
	input  logic [WIDTH-1:0] in,
	output logic [WIDTH-1:0] first
);

	logic [WIDTH-1:0] memory [DEPTH-1:0];
    assign out = memory[DEPTH-1];
    assign first = memory[0];

generate
    genvar i;

    always @(posedge clk) begin
        memory[0] <= in;
    end

    for (i = 1; i < DEPTH; i = i + 1) begin
        always @(posedge clk) begin
            memory[i] <= memory[i-1];
        end
	end
endgenerate

endmodule

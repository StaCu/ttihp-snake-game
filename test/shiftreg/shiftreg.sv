/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

module shiftreg (
    input clk,
    input [1:0] in0,
    output [1:0] out0,
    output [1:0] out1,
    output [1:0] first0,
    output [1:0] first1
);

shiftreg_sv sr_sv (
    .clk(clk),
    .in(in0),
    .out(out0),
    .first(first0)
);

shiftreg_ihp sr_ihp (
    .clk(clk),
    .in(in0),
    .out(out1),
    .first(first1)
);

endmodule

module shiftreg_sv # (
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

module shiftreg_ihp # (
    parameter WIDTH = 2,
    parameter DEPTH = 234
) (
	input  logic             clk,
	output logic [WIDTH-1:0] out,
	input  logic [WIDTH-1:0] in,
	output logic [WIDTH-1:0] first
);

generate
    genvar i;
    genvar j;
    for (i = 0; i < WIDTH; i = i + 1) begin
        wire sreg_w[DEPTH-1:0];
        wire sreg_q[DEPTH-1:0];
        wire high[DEPTH/4:0];

        assign sreg_w[0] = in[i];
        assign out[i] = sreg_q[DEPTH-1];
        assign first[i] = sreg_q[0];

        for (j = 0; j < DEPTH; j = j + 1) begin
            if (j == 0) begin
                sg13g2_dfrbpq_2 sreg_dff (
                    .CLK(clk),
                    .RESET_B(high[j/4]),
                    .D(sreg_w[j]),
                    .Q(sreg_q[j])
                );
            end else begin
                sg13g2_dfrbpq_1 sreg_dff (
                    .CLK(clk),
                    .RESET_B(high[j/4]),
                    .D(sreg_w[j]),
                    .Q(sreg_q[j])
                );
            end
        end

        for (j = 0; j < DEPTH-1; j = j + 1) begin
            // we actually want sg13g2_dlygate4sd3_1, but OpenRoad keeps replacing it, so we change it afterwards in the flow
            sg13g2_buf_1 sreg_dly(
                .A(sreg_q[j]),
                .X(sreg_w[j+1])
            );
        end

        for (j = 0; j < DEPTH / 4 + 1; j = j + 1) begin
            wire tmp_high;
            sg13g2_tiehi sreg_high (
                .L_HI(tmp_high)
            );
            sg13g2_buf_1 sreg_bufhigh(
                .A(tmp_high),
                .X(high[j])
            );
        end
    end
endgenerate

endmodule

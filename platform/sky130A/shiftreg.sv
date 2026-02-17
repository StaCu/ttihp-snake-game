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

generate
    genvar i;
    genvar j;
    for (i = 0; i < WIDTH; i = i + 1) begin
        wire sreg_w[DEPTH-1:0];
        wire sreg_q[DEPTH-1:0];
        //wire clk_leaf[DEPTH/25-1:0];

        assign sreg_w[0] = in[i];
        assign out[i] = sreg_q[DEPTH-1];
        assign first[i] = sreg_q[1];

        for (j = 0; j < DEPTH; j = j + 1) begin
            if (j == 1) begin
                sky130_fd_sc_hd__dfxtp_2 sreg_dff (
                    .CLK(clk),//_leaf[j/25]),
                    .D(sreg_w[j]),
                    .Q(sreg_q[j])
                );
            end else begin
                sky130_fd_sc_hd__dfxtp_1 sreg_dff (
                    .CLK(clk),//_leaf[j/25]),
                    .D(sreg_w[j]),
                    .Q(sreg_q[j])
                );
            end
        end

        for (j = 0; j < DEPTH-1; j = j + 1) begin
            sky130_fd_sc_hd__dlygate4sd3_1 sreg_dly (
                .A(sreg_q[j]),
                .X(sreg_w[j+1])
            );
        end

        /*for (j = 0; j < DEPTH / 25; j = j + 1) begin
            sky130_fd_sc_hd__clkbuf_8 sreg_clkbuf (
                .A(clk),
                .X(clk_leaf[j])
            );
        end*/
    end
endgenerate

endmodule

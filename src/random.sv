/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module random (
	input  logic       clk,
	input  logic       rst_n,
	input  logic       update,
	output logic [3:0] rng4,
	output logic [4:0] rng5
);

	logic [3:0] lfsr4;
	logic [4:0] lfsr5;
	logic feedback4;
	logic feedback5;
	assign feedback4 = lfsr4[0] ^ lfsr4[3];
	assign feedback5 = lfsr5[2] ^ lfsr5[4];

	assign rng4 = lfsr4;
	assign rng5 = lfsr5;

	always @(posedge clk) begin
		if (!rst_n) begin
			lfsr4 <= 4'b1011;
			lfsr5 <= 5'b00111;
		end else if (update) begin
			lfsr4 <= { lfsr4[2:0], feedback4 };
			lfsr5 <= { lfsr5[3:0], feedback5 };
		end
	end

endmodule

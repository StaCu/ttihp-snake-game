/*
* Copyright (c) 2024 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module random (
	input  logic       clk,
	output logic [8:0] o_rng
);

	logic [8:0] data;
	assign o_rng = data;

	always @(posedge clk) begin
		data <= { data[0] ^ data[1], data[7], data[8] ^ data[4], data[2] ^ data[1], data[3], data[5],  data[8] ^ data[6], data[4] ^ data[6], !data[4] };
	end

`ifdef RTL_SIMULATION
	initial begin
		data = 0;
	end
`endif

endmodule

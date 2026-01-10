

DEPTH = 18*13
WIDTH = 2

text = """/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

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
"""

for w in range(WIDTH):
    for i in range(DEPTH):
        text += f"    (* keep *) wire manual_shiftreg_D_{w}_{i};\n"
        text += f"    (* keep *) wire manual_shiftreg_Q_{w}_{i};\n"

text += f"""
    assign manual_shiftreg_D_0_0 = in[0];
    assign manual_shiftreg_D_1_0 = in[1];
    assign out = {{manual_shiftreg_Q_1_{DEPTH-1}, manual_shiftreg_Q_0_{DEPTH-1}}};
    assign first = {{manual_shiftreg_Q_1_0, manual_shiftreg_Q_0_0}};

"""

for w in range(WIDTH):
    for i in range(DEPTH):
        text += f"""    (* keep, dont_touch *) sg13g2_dfrbpq_1 manual_shiftreg_dff_{w}_{i} (
        .CLK(clk),
        .RESET_B(1'b1),
        .D(manual_shiftreg_D_{w}_{i}),
        .Q(manual_shiftreg_Q_{w}_{i})
    );
"""
        if i != DEPTH-1:
            text += f"""    (* keep, dont_touch *) sg13g2_dlygate4sd3_1 manual_shiftreg_hold_{w}_{i} (
        .A(manual_shiftreg_Q_{w}_{i}),
        .X(manual_shiftreg_D_{w}_{i+1})
    );
"""

text += f"""
endmodule
"""

with open("src/shiftreg.sv", "w") as file:
    file.write(text)

/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module sound (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       vsync,
    input  logic       hsync,
    // all sound events are 1 cycle and only asserted once
    input  logic       failure,
    input  logic       success,
    input  logic       eat,
    input  logic       tick,
    output logic       audio
);

    assign audio = 0;

endmodule

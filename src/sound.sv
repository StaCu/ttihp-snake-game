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

    logic [1:0] mode;
    logic [1:0] next_mode;
    logic [7:0] counter;
    logic [7:0] next_counter;
    logic [7:0] max_counter;
    logic [7:0] next_max_counter;

    always @(*) begin
        next_mode = mode;
        casez ({ mode, vsync, tick, eat, success, failure })
        7'b00?_????: 
        endcase
    end

    always @(*) begin
        case (mode)
            1: begin

            end
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            mode <= 0;
            counter <= 0;
            max_counter <= 0;
            audio <= 0;
        end else begin
            counter <= (counter == max_counter) ? 0 : counter + 1;
            if (counter == max_counter) begin
                audio <= !audio;
            end
        end
    end

endmodule

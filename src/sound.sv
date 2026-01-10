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
    logic [7:0] max_counter;
    logic [7:0] next_max_counter;
    logic [3:0] phase;
    logic [3:0] next_phase;

    logic prev_hsync;
    logic prev_vsync;

    always @(*) begin
        next_max_counter = max_counter;
        next_phase = phase;
        if (vsync && !prev_vsync) begin
            next_phase = phase + 1;
        end
        next_mode = mode;
        if ((phase == 4 & mode == 1) | phase == 12) begin
            next_mode = 0;
        end
        casez ({ tick, eat, success, failure })
        4'b???1: begin
            next_max_counter = 150;
            next_phase = 0;
            next_mode = 3;
        end
        4'b??10: begin
            next_max_counter = 250;
            next_phase = 0;
            next_mode = 3;
        end
        4'b?100: begin
            next_max_counter = 200;
            next_phase = 0;
            next_mode = 2;
        end
        4'b1000: if (mode == 0) begin
            next_max_counter = 100;
            next_phase = 0;
            next_mode = 1;
        end
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            mode <= 0;
            phase <= 0;
            counter <= 0;
            max_counter <= 0;
            audio <= 0;
        end else begin
            if (hsync && !prev_hsync) begin
                counter <= (counter == max_counter) ? 0 : counter + 1;
                if (counter == max_counter) begin
                    audio <= !audio & !phase[2] & mode != 0;
                end
            end
            phase <= next_phase;
            mode <= next_mode;
            max_counter <= next_max_counter;
        end
        prev_hsync <= hsync;
        prev_vsync <= vsync;
    end

endmodule

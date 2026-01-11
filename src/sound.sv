/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module sound (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       vsync,
    input  logic       pwm_base,
    // sound sources (all single cycle events)
    input  logic       new_input,
    input  logic       failure,
    input  logic       success,
    input  logic       eat,
    input  logic       tick,
    // sound
    output logic       audio
);

    logic [1:0] mode;
    logic [1:0] next_mode;
    logic [3:0] counter;
    logic [3:0] max_counter;
    logic [3:0] next_max_counter;
    logic [4:0] phase;
    logic [4:0] next_phase;

    logic prev_pwm_base;
    logic prev_vsync;

    always @(*) begin
        next_max_counter = max_counter;
        next_phase = phase;
        if (vsync && !prev_vsync) begin
            next_phase = phase + 1;
            if (mode == 2) begin
                next_max_counter = phase < 12 ? max_counter + 1 : max_counter - 1;
            end
        end
        next_mode = mode;
        if ((phase == 4 && mode == 1) || (phase == 1 && mode == 1 && max_counter[0])|| phase == 24) begin
            next_mode = 0;
        end
        if (failure) begin
            next_max_counter = 9; // 9*16+15=159 | 198 Hz
            next_phase = 0;
            next_mode = 3;
        end else if (success) begin
            next_max_counter = 3; // 3*16+15=63 | 500 Hz
            next_phase = 0;
            next_mode = 3;
        end else if (eat) begin
            next_max_counter = 3; // 3*16+15=63 | 500 Hz
            next_phase = 0;
            next_mode = 2;
        end else if (new_input && mode == 0) begin
            next_max_counter = 4; // 4*16+15=79 | 398 Hz
            next_phase = 0;
            next_mode = 1;
        end else if (tick && mode == 0) begin
            next_max_counter = 5; // 5*16+15=95 | 331 Hz
            next_phase = 0;
            next_mode = 1;
        end
    end

    logic next_audio;

    always @(*) begin
        next_audio <= !audio && mode != 0 && !(mode == 3 && phase[2]);
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            mode <= 0;
            phase <= 0;
            counter <= 0;
            max_counter <= 0;
            audio <= 0;
        end else begin
            if (pwm_base && !prev_pwm_base) begin
                counter <= (counter == max_counter) ? 0 : counter + 1;
                if (counter == max_counter) begin
                    audio <= next_audio;
                end
            end
            phase <= next_phase;
            mode <= next_mode;
            max_counter <= next_max_counter;
        end
        prev_pwm_base <= pwm_base;
        prev_vsync <= vsync;
    end

endmodule

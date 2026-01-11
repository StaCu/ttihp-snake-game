/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module tickgen (
	input  logic       clk,
	input  logic       rst_n,

    input  logic       i_up,
    input  logic       i_down,
    input  logic       i_restart,
    input  logic       i_vsync,
    input  logic       i_tick_done,
    output logic       o_tick
);

    logic prev_vsync;
    logic prev_user_input;

    logic [3:0] counter_max;
    logic [3:0] counter;

    always @(posedge clk) begin
        if (!rst_n) begin
            counter_max <= DEFAULT_TICK_COUNTER_MAX;
        end else begin
            if (i_restart && !prev_user_input) begin
                if (i_up) begin
                    counter_max <= counter_max + 1;
                end else if (i_down) begin
                    counter_max <= counter_max - 1;
                end
            end
        end

        if (i_restart) begin
            counter <= 0;
            o_tick <= 0;
        end else begin
            if (i_vsync && !prev_vsync) begin
                counter <= counter == counter_max ? 0 : counter + 1;
                if (counter == counter_max) begin
                    o_tick <= 1;
                end
            end else if (i_tick_done) begin
                o_tick <= 0;
            end else begin
                o_tick <= o_tick;
            end
        end

        prev_vsync <= i_vsync;
        prev_user_input <= i_up | i_down;
    end

endmodule

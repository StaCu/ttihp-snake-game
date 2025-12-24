/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`include "common.sv"

module vga_sync (
	input  logic       clk,
	input  logic       rst_n,
	output logic [9:0] px,
	output logic [9:0] py,
	output logic [9:0] next_px,
	output logic [9:0] next_py,
	output logic       visible,
	output logic       vsync,
	output logic       hsync
);

	assign next_px = px + 1;
	assign next_py = py + 1;

	// declarations for TV-simulator sync parameters
	// horizontal constants
	parameter H_DISPLAY = 640;  // horizontal display width
	parameter H_BACK    =  48;  // horizontal left border (back porch)
	parameter H_FRONT   =  16;  // horizontal right border (front porch)
	parameter H_SYNC    =  96;  // horizontal sync width
	// vertical constants
	parameter V_DISPLAY = 480;  // vertical display height
	parameter V_BACK    =  33;  // vertical top border (back porch)
	parameter V_FRONT   =  10;  // vertical bottom border (front porch)
	parameter V_SYNC    =   2;  // vertical sync # lines
	// derived constants
	parameter H_SYNC_START = H_DISPLAY + H_FRONT;
	parameter H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC - 1;
	parameter H_MAX        = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
	parameter V_SYNC_START = V_DISPLAY + V_FRONT;
	parameter V_SYNC_END   = V_DISPLAY + V_FRONT + V_SYNC - 1;
	parameter V_MAX        = V_DISPLAY + V_BACK + V_FRONT + V_SYNC - 1;

	// horizontal position counter
	always @(posedge clk) begin
		if (!rst_n || px == H_MAX) begin
			px <= 0;
		end else begin
			px <= next_px;
		end
		hsync <= (px >= H_SYNC_START && px <= H_SYNC_END);
	end

	// vertical position counter
	always @(posedge clk) begin
		if (!rst_n) begin
			py <= 0;
		end else if (px == H_MAX) begin
			if (py == V_MAX) begin
				py <= 0;
			end else begin
				py <= next_py;
			end
		end
		vsync <= (py >= V_SYNC_START && py <= V_SYNC_END);
	end

	// visible is set when beam is in "safe" visible frame
	assign visible = (px < H_DISPLAY) && (py < V_DISPLAY);

endmodule

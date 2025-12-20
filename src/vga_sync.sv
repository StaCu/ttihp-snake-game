/*
* Copyright (c) 2024 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

module vga_sync (
	input  logic       clk,
	input  logic       rst_n,
	output logic [9:0] px,
	output logic [8:0] py,
	output logic       visible,
	output logic       vsync,
	output logic       hsync
);

	logic display_on;
	logic [9:0] hpos;
	logic [9:0] vpos;
	logic reset;

	assign px = hpos;
	assign py = vpos[8:0];
	assign visible = display_on;
	assign reset = !rst_n;

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

	wire hmaxxed = (hpos == H_MAX) || reset; // set when hpos is maximum
	wire vmaxxed = (vpos == V_MAX) || reset; // set when vpos is maximum

	// horizontal position counter
	always @(posedge clk) begin
		hsync <= (hpos >= H_SYNC_START && hpos <= H_SYNC_END);
		if (hmaxxed) hpos <= 0;
		else hpos <= hpos + 1;
	end

	// vertical position counter
	always @(posedge clk) begin
		vsync <= (vpos >= V_SYNC_START && vpos <= V_SYNC_END);
		if (hmaxxed)
			if (vmaxxed) vpos <= 0;
			else vpos <= vpos + 1;
	end

	// display_on is set when beam is in "safe" visible frame
	assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule

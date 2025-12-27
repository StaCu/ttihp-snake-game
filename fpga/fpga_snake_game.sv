/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype wire
`include "common.sv"

module fpga_snake_game (
	input  logic       CLK100MHZ,
	input  logic       CPU_RESETN,
	input  logic       BTNU,
	input  logic       BTND,
	input  logic       BTNL,
	input  logic       BTNR,
	input  logic [1:0] SW,
	output logic [3:0] LED,
	output logic [3:0] VGA_R,
	output logic [3:0] VGA_G,
	output logic [3:0] VGA_B,
	output logic       VGA_VS,
	output logic       VGA_HS
);

	assign VGA_R[1:0] = 0;
	assign VGA_G[1:0] = 0;
	assign VGA_B[1:0] = 0;

	logic [24:0] counter;
	logic [8:0] power_on_reset;

	logic CLKFBOUT;
	logic CLKFBOUTB;
	logic CLKOUT0;
	logic CLKOUT0B;
	logic CLKOUT1;
	logic CLKOUT1B;
	logic CLKOUT2;
	logic CLKOUT2B;
	logic CLKOUT3;
	logic CLKOUT3B;
	logic CLKOUT4;
	logic CLKOUT5;
	logic CLKOUT6;
	logic LOCKED;

	initial begin
		counter <= 0;
		power_on_reset <= 0;
	end

	always @(posedge CLKOUT0) begin
		counter <= counter == 25174013 ? 0 : counter + 1;
		LED[3] <= LED[3] ^ (counter == 25174013);

		if (power_on_reset < 256) begin
			power_on_reset <= power_on_reset + 1;
		end
	end

	logic vsync;
	logic hsync;
	assign VGA_VS = !vsync;
	assign VGA_HS = !hsync;

	game game_inst (
		.clk(CLKOUT0),
		.rst_n(CPU_RESETN && LOCKED && power_on_reset[8]),

		.i_up(BTNU),
		.i_down(BTND),
		.i_left(BTNL),
		.i_right(BTNR),
		.i_pause(SW[0]),
		.i_restart(SW[1]),

		.o_vga_r(VGA_R[3:2]),
		.o_vga_g(VGA_G[3:2]),
		.o_vga_b(VGA_B[3:2]),
		.o_vga_vsync(vsync),
		.o_vga_hsync(hsync),

		.o_failure(LED[0]),
		.o_success(LED[1]),
		.o_eat(LED[2])
	);

	// Vivado Design Suite 7 Series FPGA and Zynq 7000 SoC Libraries Guide (UG953)
	// https://docs.amd.com/r/en-US/ug953-vivado-7series-libraries/MMCME2_BASE
	// input clock is       100000000 Hz
	// output clock must be  25175000 Hz (VGA clock)
	// 100000000 * 27.125 / 53.875 / 2 = 25174014 Hz
	MMCME2_BASE #(
		.BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
		.CLKFBOUT_MULT_F(27.125),     // Multiply value for all CLKOUT (2.000-64.000).
		.CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
		.CLKIN1_PERIOD(10.0),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
		// CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
		.CLKOUT1_DIVIDE(1),
		.CLKOUT2_DIVIDE(1),
		.CLKOUT3_DIVIDE(1),
		.CLKOUT4_DIVIDE(1),
		.CLKOUT5_DIVIDE(1),
		.CLKOUT6_DIVIDE(1),
		.CLKOUT0_DIVIDE_F(53.875),    // Divide amount for CLKOUT0 (1.000-128.000).
		// CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT3_DUTY_CYCLE(0.5),
		.CLKOUT4_DUTY_CYCLE(0.5),
		.CLKOUT5_DUTY_CYCLE(0.5),
		.CLKOUT6_DUTY_CYCLE(0.5),
		// CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_PHASE(0.0),
		.CLKOUT3_PHASE(0.0),
		.CLKOUT4_PHASE(0.0),
		.CLKOUT5_PHASE(0.0),
		.CLKOUT6_PHASE(0.0),
		.CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
		.DIVCLK_DIVIDE(2),         // Master division value (1-106)
		.REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
		.STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
	) MMCME2_BASE_inst (
		// Clock Outputs: 1-bit (each) output: User configurable clock outputs
		.CLKOUT0(CLKOUT0),     // 1-bit output: CLKOUT0
		.CLKOUT0B(CLKOUT0B),   // 1-bit output: Inverted CLKOUT0
		.CLKOUT1(CLKOUT1),     // 1-bit output: CLKOUT1
		.CLKOUT1B(CLKOUT1B),   // 1-bit output: Inverted CLKOUT1
		.CLKOUT2(CLKOUT2),     // 1-bit output: CLKOUT2
		.CLKOUT2B(CLKOUT2B),   // 1-bit output: Inverted CLKOUT2
		.CLKOUT3(CLKOUT3),     // 1-bit output: CLKOUT3
		.CLKOUT3B(CLKOUT3B),   // 1-bit output: Inverted CLKOUT3
		.CLKOUT4(CLKOUT4),     // 1-bit output: CLKOUT4
		.CLKOUT5(CLKOUT5),     // 1-bit output: CLKOUT5
		.CLKOUT6(CLKOUT6),     // 1-bit output: CLKOUT6
		// Feedback Clocks: 1-bit (each) output: Clock feedback ports
		.CLKFBOUT(CLKFBOUT),   // 1-bit output: Feedback clock
		.CLKFBOUTB(CLKFBOUTB), // 1-bit output: Inverted CLKFBOUT
		// Status Ports: 1-bit (each) output: MMCM status ports
		.LOCKED(LOCKED),       // 1-bit output: LOCK
		// Clock Inputs: 1-bit (each) input: Clock input
		.CLKIN1(CLK100MHZ),       // 1-bit input: Clock
		// Control Ports: 1-bit (each) input: MMCM control ports
		.PWRDWN(1'b0),       // 1-bit input: Power-down
		.RST(!CPU_RESETN),             // 1-bit input: Reset
		// Feedback Clocks: 1-bit (each) input: Clock feedback ports
		.CLKFBIN(CLKFBOUT)      // 1-bit input: Feedback clock
	);

endmodule

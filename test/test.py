# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 ns (100 MHz)
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 300)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Run the game for a few iterations
    ctrl = [
        0b00000,
        0b10001,
        0b00001,
        0b10100,
        0b00100,
        0b10100,
        0b00100,
        0b10100,
        0b00100,
        0b10100,
        0b00100,
        0b10100,
        0b10010,
        0b00010,
        0b10010,
        0b00010,
        0b11000,
        0b01000,
    ]
    for i in range(100):
        dut.ui_in.value = ctrl[i % len(ctrl)]
        await ClockCycles(dut.clk, 300)

    # The game fails
    assert dut.uio_out.value == 0b001

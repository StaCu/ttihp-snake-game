# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test(dut):
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
    await ClockCycles(dut.clk, 250)
    dut.rst_n.value = 1

    # Change tickrate to once per frame
    dut._log.info("Change tickrate")
    dut.ui_in.value = 0b100000
    for _ in range(14):
        dut.ui_in.value = 0b100010
        await ClockCycles(dut.clk, 2)
        dut.ui_in.value = 0b100000
        await ClockCycles(dut.clk, 2)
    await ClockCycles(dut.clk, 250)
    dut.ui_in.value = 0b000000

    # wait for hsync
    dut._log.info("Wait for hsync")
    for _ in range(800):
        await ClockCycles(dut.clk, 1)
        if int(dut.uo_out.value[7]) != 0:
            break
    # hsync found
    assert int(dut.uo_out.value[7]) != 0

    # wait for vsync
    dut._log.info("Wait for vsync")
    for _ in range(800*525):
        await ClockCycles(dut.clk, 1)
        if int(dut.uo_out.value[3]) != 0:
            break
    # vsync found
    assert int(dut.uo_out.value[3]) != 0

    # Run the game for a few iterations
    dut._log.info("Start control sequence")
    ctrl = [    #  9, 6 (start pos), 11, 4 (apple pos)
        0b0001, #  9, 7
        0b0100, # 10, 7
        0b0100, # 11, 7
        0b0010, # 11, 6
        0b0010, # 11, 5
        0b0010, # 11, 4 (eat apple)
        0b1000, # 10, 4
        0b0010, # 10, 3
        0b0001, # 10, 2 (down -> up, results in down)
        0b0010, # 10, 1
        0b0010, # 10, 0 (wall)
    ]
    # start control sequence in the middle of the frame
    await ClockCycles(dut.clk, 800*200)
    for i in range(len(ctrl)):
        dut.ui_in.value = ctrl[i]
        dut._log.info(f"i[{i}]: {ctrl[i]} | {int(dut.uio_out.value)}")
        # the game has neither succeeded nor failed
        assert int(dut.uio_out.value) & 0b011 == 0

        if i == 5:
            # the snake eats the apple
            apple_eaten = False
            for _ in range(800*525):
                await ClockCycles(dut.clk, 1)
                if int(dut.uio_out.value) & 0b100 != 0:
                    apple_eaten = True
            assert apple_eaten
        else:
            await ClockCycles(dut.clk, 800*525)

    # the game has failed
    assert int(dut.uio_out.value) == 0b001

    # Restart game
    dut._log.info("Restart")
    dut.ui_in.value = 0b00100000
    await ClockCycles(dut.clk, 300)
    dut.ui_in.value = 0b00000000
    await ClockCycles(dut.clk, 1)

    # The game is no longer in failure state
    assert int(dut.uio_out.value) == 0b000


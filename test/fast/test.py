import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_game_over(dut):
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

    # Run the game for a few iterations
    dut._log.info("Start control sequence")
    ctrl = [
        0b0000,
        0b0001,
        0b0001,
        0b0100,
        0b0100,
        0b0100,
        0b0100,
        0b0010,
        0b0010,
        0b0010,
        0b0010,
        0b1000,
        0b1000,
    ]
    for i in range(100):
        dut.ui_in.value = ctrl[i % len(ctrl)]
        await ClockCycles(dut.clk, 300)

    # The game fails
    assert dut.uio_out.value == 0b001

    # Restart game
    dut._log.info("Restart")
    dut.ui_in.value = 0b100000
    await ClockCycles(dut.clk, 300)
    # The game is no longer in failure state
    assert dut.uio_out.value == 0b000

    # run again
    dut._log.info("Start control sequence")
    for i in range(100):
        dut.ui_in.value = ctrl[i % len(ctrl)]
        await ClockCycles(dut.clk, 300)

    # The game fails
    assert dut.uio_out.value == 0b0001


@cocotb.test()
async def test_success(dut):
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

    dut._log.info("Start hamiltonian cycle")

    # Run the game until the snake reaches the full lenght
    head_x = dut.user_project.game_inst.snake_inst.head_x
    head_y = dut.user_project.game_inst.snake_inst.head_y
    apple_x = dut.user_project.game_inst.apple_inst.apple_x
    apple_y = dut.user_project.game_inst.apple_inst.apple_y
    length = dut.user_project.game_inst.snake_inst.length

    prev_x = 0
    prev_y = 0
    iter = 0
    nochange = 0
    while nochange < 1000:
        # The snake algorithm used for testing follows a hamiltonian cycle (for better algorithms, see https://github.com/twanvl/snake/).
        # - Up-over-down-over-repeat
        # - When it reaches the end, use the bottom row to return to the first column
        # - Shortcut: early return to first column if the apple is on that side and the snake is short enough
        input = 0b0000
        x = int(head_x.value)
        y = int(head_y.value)
        ax = int(apple_x.value)
        l = int(length.value)
        if y == 13 and x != 18:
            input = 0b1000
        elif x % 2 == 0:
            if y == 1:
                input = 0b0100
            else:
                input = 0b0001
        else:
            if y == 12 and x != 1 and not (ax > x and l < (19-x)*12):
                input = 0b0100
            else:
                input = 0b0010
        dut.ui_in.value = input

        if prev_x != x or prev_y != y:
            iter += 1
            prev_x = x
            prev_y = y
            print(iter, ":", int(head_x.value), int(head_y.value), int(length.value), "|", int(apple_x.value), int(apple_y.value))
            nochange = 0
        else:
            nochange += 1
        await ClockCycles(dut.clk, 100)

    # The game succeeds (and apple eaten)
    assert dut.uio_out.value == 0b0110

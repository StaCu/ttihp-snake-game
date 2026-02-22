import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut._log.info("Reset")
    dut.in0.value = 0
    await ClockCycles(dut.clk, 250)

    dut._log.info("Toggle")

    for i in range(500):
        dut.in0.value = i % 4
        await ClockCycles(dut.clk, 1)
        assert dut.out0.value == dut.out1.value, f"{dut.out0.value} {dut.out1.value}"
        assert dut.first0.value == dut.first1.value, f"{dut.first0.value} {dut.first1.value}"

    dut._log.info("Done")
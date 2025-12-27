# Testbench for Tiny Tapeout Snake Game

Testbench for this Tiny Tapeout project.
It uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.

## How to run

To run the RTL simulation:

```sh
make -B
```

To run gatelevel simulation, first harden your project and copy `../runs/wokwi/results/final/verilog/gl/{your_module_name}.v` to `gate_level_netlist.v`.
Then run:

```sh
make -B GATES=yes
```

There are two additional tests in `test_fast.py` that use a slightly altered version of the RTL.
Here, the games tickrate is no longer coupled to the VGA display refresh rate and instead uses a timer with a much shorter interval.
This then allows for much longer tests including a full run of an entire successful game that ends with the snake filling the entire area.
To run, use:

```sh
make -B FAST=yes
```

You may need to delete the `sim_build` folder before/after running fast simulation.

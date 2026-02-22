# Testbench for Tiny Tapeout Snake Game

Testbench for this Tiny Tapeout project.
It uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.

## How to run

To run the RTL simulation:

```sh
make
```

To run the gatelevel simulation, first harden the project by following the build instructions.
Then run:

```sh
make GATES=yes
# If there are problems with the simulation, try the following instead.
# This uses a modified version of the pdk, because icarus can not simulate timing models.
make GATES=fake
```

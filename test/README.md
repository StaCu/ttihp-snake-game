# Tests for Tiny Tapeout Snake Game

These tests use [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.

## Setup

```sh
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Run

To run the simulations, source the cocotb `venv`, go into the test sub-directory and run the command specified in its `ReadMe.md`.

```sh
# run this before running any of the tests
source venv/bin/activate

# the `full` simulation can also be called from this directory
make
# or gate level simulation
make GATES=yes
```

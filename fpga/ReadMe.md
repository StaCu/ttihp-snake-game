# FPGA Implementation

The FPGA version exists for prototyping purposes and anyone who wants to play without Tiny Tapeout.
It is built around the Nexys 4 board using a Xilnix Artix-7 FPGA.

## Building and Playing

Make sure `vivado` is on your path, then run:

```sh
make
```

This will build the bitstream, which you can flash onto the FPGA.

After connecting a VGA display, you should immediately see some output.
The game starts after a button for a valid movement direction has been pressed.

Switch 0 pauses the game.
Switch 1 restarts the game.
While restart is asserted, pressing up and down will change the tickrate (a factor of 1-32 on top of the VGA display rate of 60Hz).
While restart is asserted, pressing right will enable colorblind mode, replacing the green snake with a blue one.

## Porting to other Platforms

Porting to other platforms requires a platform with VGA output and at least 4 input buttons.
Furthermore, the following files may require changes.

**`fpga_snake_game`:**
Contains a wrapper around the game logic.
Polarity of signals may be different on other platforms.
The clock conversion must convert whatever input clock frequency to the VGA clock of `25,175,000 Hz`.

**`Nexys-A7-100T-Master.xdc`**:
Contains the pin-out of the FPGA.

**`build.tcl`**:
Vivado build script.

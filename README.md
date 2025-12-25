![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Snake Game

The classic game "Snake" for Tiny Tapeout.

In "Snake" the player controls a snake within a limited area.
The player must prevent the snake from moving into the walls or biting itself.
Eating food increases the length of the snake, increasing the difficulty.

- [Read the documentation](docs/info.md)
- [View the GDS](https://stacu.github.io/ttihp-snake-game/)

## FPGA Version

The FPGA version exists for prototyping purposes and anyone who wants to play without Tiny Tapeout.
It is built around the Nexys 4 board using a Xilnix Artix-7 FPGA, but porting to other platforms requires little effort.

- [Read about the FPGA version](fpga/ReadMe.md)

## Implementation

In order to fit into as small an area as possible, the game uses a shift register to hold the current state of the snake.
The position its head is stored explicitly, but the position of every other part of the snake is only computed on-the-fly by following
the directions stored in the shift register.
Each entry in the shift register is 2bit, holding the direction to get to the next part of the snake.
As a result, detecting whether the snake bit itself requires iterating through the shift register once.

The game uses 18x13 dimensions (plus a 1 wide border on each side) in order to neatly fit onto a 640x480 VGA display.
VGA controller logic is included to play on the "big" screen.

The game uses 2 Tiny Tapeout tiles, one of which contains essentially just the giant shift register. 

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.


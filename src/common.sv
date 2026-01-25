/*
 * Copyright (c) 2025 David Volz
 * SPDX-License-Identifier: Apache-2.0
 */

`ifndef COMMON_SV
`define COMMON_SV

// Game dimensions
// Note: Many parts of the implementation stop working for other sizes

// Nokia Original
//parameter logic [4:0] GAME_WIDTH  = 20;
//parameter logic [3:0] GAME_HEIGHT = 11;

// VGA 32x32 pixel per tile
parameter logic [4:0] GAME_WIDTH  = 18;
parameter logic [3:0] GAME_HEIGHT = 13;

parameter logic [7:0] MAX_LENGTH = GAME_WIDTH * GAME_HEIGHT;

parameter logic [4:0] START_POS_X = 10;
parameter logic [3:0] START_POS_Y = 7;

// Tick rate
// The tick counter counts once per frame, i.e. 60 times per second
parameter logic [2:0] DEFAULT_TICK_COUNTER_MAX = 7; // 7*2+1 == 15 => 60Hz / 15 == 4 ticks per second

`endif

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
//parameter logic [4:0] DEFAULT_TICK_COUNTER_MAX = 29; // 29+1 ==  2 ticks per second
parameter logic [4:0] DEFAULT_TICK_COUNTER_MAX = 14; // 14+1 ==  4 ticks per second
//parameter logic [4:0] DEFAULT_TICK_COUNTER_MAX = 11; // 11+1 ==  5 ticks per second
//parameter logic [4:0] DEFAULT_TICK_COUNTER_MAX =  9; //  9+1 ==  6 ticks per second
//parameter logic [4:0] DEFAULT_TICK_COUNTER_MAX =  5; //  5+1 == 10 ticks per second

`endif

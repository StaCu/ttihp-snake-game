/*
* Copyright (c) 2025 David Volz
* SPDX-License-Identifier: Apache-2.0
*/

`ifndef COMMON_SV
`define COMMON_SV

// Game dimensions
// Note: Many parts of the implementation stop working for other sizes

// Nokia Original
//parameter int GAME_WIDTH  = 20;
//parameter int GAME_HEIGHT = 11;

// VGA 32x32 pixel per tile
parameter int GAME_WIDTH  = 18;
parameter int GAME_HEIGHT = 13;

parameter int MAX_LENGTH = GAME_WIDTH * GAME_HEIGHT;

`endif

# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../../src
PROJECT_SOURCES = tt_um_snake_game.sv common.sv game.sv tickgen.sv apple.sv random.sv control.sv snake.sv shiftreg.sv vga.sv vga_sync.sv sound.sv

# RTL simulation:
SIM_BUILD			 = sim_build
VERILOG_SOURCES		+= $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS		+= -I$(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES		+= $(PWD)/tb.v
TOPLEVEL			 = tb

SIM_BUILD			 = sim_build/fast
COMPILE_ARGS		+= -DRTL_SIMULATION
# List test modules to run, separated by commas and without the .py suffix:
COCOTB_TEST_MODULES	 = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

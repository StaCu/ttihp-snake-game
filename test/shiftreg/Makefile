SIM ?= icarus
FST ?= -fst
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/
VERILOG_SOURCES += shiftreg.sv ../pdk/sg13g2_stdcell.v
TOPLEVEL = shiftreg
WAVES=1
COMPILE_ARGS 		+= -I$(SRC_DIR)
SIM_BUILD			 = sim_build
COCOTB_TEST_MODULES  = test

include $(shell cocotb-config --makefiles)/Makefile.sim

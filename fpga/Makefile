
all: build

build: clean
	mkdir -p project
	cp build.tcl Nexys-A7-100T-Master.xdc project/
	mkdir -p project/verilog
	cp fpga_snake_game.sv ../src/*.sv project/verilog/
	cd project/ && vivado -mode batch -source build.tcl
	mv project/project_1.runs/impl_1/fpga_snake_game.bit project/

clean:
	rm -rf project/

.PHONY: all build clean

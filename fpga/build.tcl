set base_dir "."
create_project project_1 . -part xc7a100tcsg324-2
add_files -norecurse -scan_for_includes       \
    "$base_dir/verilog/shiftreg.sv"           \
    "$base_dir/verilog/common.sv"             \
    "$base_dir/verilog/snake.sv"              \
    "$base_dir/verilog/vga.sv"                \
    "$base_dir/verilog/random.sv"             \
    "$base_dir/verilog/vga_sync.sv"           \
    "$base_dir/verilog/game.sv"               \
    "$base_dir/verilog/control.sv"            \
    "$base_dir/verilog/apple.sv"              \
    "$base_dir/verilog/fpga_snake_game.sv"
import_files -force -norecurse
import_files -fileset constrs_1 -force -norecurse "$base_dir/Nexys-A7-100T-Master.xdc"
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

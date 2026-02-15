#!/usr/bin/env python3
import os
import cloup
import shutil
from librelane.common import mkdirp
from librelane.flows import cloup_flow_opts, Flow

@cloup.command()
@cloup_flow_opts(accept_config_files=False)
def main(
    pdk,
    scl,
    frm,
    to,
    skip,
    tag,
    last_run,
    with_initial_state,
    pdk_root,
    **kwargs,
):
    pdk = 'sky130A'
    scl = 'sky130_fd_sc_hd'
    design = 'tt_um_snake_game'

    build_dir = os.path.join("runs", f"{pdk}-{scl}", design)
    mkdirp(build_dir)

    shutil.copytree('src/', build_dir, dirs_exist_ok=True)
    shutil.copytree(f'platform/{pdk}/', build_dir, dirs_exist_ok=True)

    config = {
        "PL_TARGET_DENSITY_PCT": 75,
        "CLOCK_PERIOD": 20,
        "PL_RESIZER_HOLD_SLACK_MARGIN": 0.1,
        "GRT_RESIZER_HOLD_SLACK_MARGIN": 0.05,
        "RUN_LINTER": True,
        "LINTER_INCLUDE_PDK_MODELS": True,
        "CLOCK_PORT": "clk",
        "RUN_KLAYOUT_XOR": False,
        "RUN_KLAYOUT_DRC": False,
        "DESIGN_REPAIR_BUFFER_OUTPUT_PORTS": False,
        "TOP_MARGIN_MULT": 1,
        "BOTTOM_MARGIN_MULT": 1,
        "LEFT_MARGIN_MULT": 6,
        "RIGHT_MARGIN_MULT": 6,
        "FP_SIZING": "absolute",
        "GRT_ALLOW_CONGESTION": True,
        "FP_IO_HLENGTH": 2,
        "FP_IO_VLENGTH": 2,
        "FP_PDN_VPITCH": 38.87,
        "RUN_CTS": True,
        "FP_PDN_MULTILAYER": False,
        "MAGIC_DEF_LABELS": False,
        "MAGIC_WRITE_LEF_PINONLY": True,
        "DESIGN_NAME": "tt_um_snake_game",
        "VERILOG_FILES": [
            "dir::tt_um_snake_game.sv",
            "dir::common.sv",
            "dir::tickgen.sv",
            "dir::game.sv",
            "dir::control.sv",
            "dir::snake.sv",
            "dir::shiftreg.sv",
            "dir::apple.sv",
            "dir::random.sv",
            "dir::sound.sv",
            "dir::vga.sv",
            "dir::vga_sync.sv"
        ],
        "DIE_AREA": [0, 0, 161.00, 225.76],
        "FP_DEF_TEMPLATE": "dir::tt_block_1x2_pg.def",
        "VDD_PIN": "VPWR",
        "GND_PIN": "VGND",
        "RT_MAX_LAYER": "met4"
    }
    config['PDK'] = pdk

    TargetFlow = Flow.factory.get('ShiftregFlow')
    flow = TargetFlow(
        config,
        design_dir=os.path.abspath(build_dir),
        pdk_root=pdk_root,
    )

    final_state = flow.start(
        frm=frm,
        to=to,
        skip=skip,
        tag=tag,
        last_run=last_run,
        with_initial_state=with_initial_state,
    )

    out_path = os.path.join(os.path.abspath(build_dir), 'final')
    mkdirp(out_path)
    final_state.save_snapshot(out_path)


if __name__ == "__main__":
    main()

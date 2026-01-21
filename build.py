#!/usr/bin/env python3

#
# OpenLane2 build script to harden the tt_top macro inside
# the classic user_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse
import json
import os
from typing import List

from openlane.common import get_opdks_rev
from openlane.flows.misc import OpenInKLayout
from openlane.flows.classic import Classic
from openlane.steps.odb import OdbpyStep
from openlane.steps import OpenROAD
from librelane.steps import Step
from librelane.state import DesignFormat
from librelane.common import TclStepMixin
import volare

class ShiftRegStep(TclStepMixin, Step):
    id = "ShiftRegStep"
    name = "Run custom Tcl script"

    # Declare what design formats this step consumes and produces
    inputs = [DesignFormat.ODB]
    outputs = [DesignFormat.ODB]

    def get_tcl_script_path(self):
        return "src/shiftreg.tcl"

class ProjectFlow(Classic):
  pass

if __name__ == '__main__':
	# Argument processing
	parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument("--open-in-klayout", action="store_true", help="Open last run in KLayout")

  # Insert our custom step after the PDN generation
	ProjectFlow.Steps.insert(ProjectFlow.Steps.index(OpenROAD.GeneratePDN) + 1, CustomPower)

	args = parser.parse_args()
	config = vars(args)

	pdk_root =  volare.get_volare_home(os.getenv('PDK_ROOT'))
	volare.enable(pdk_root, "sky130", get_opdks_rev())

	# Load fixed required config for UPW
	flow_cfg = json.loads(open('config.json', 'r').read())

	# Run flow
	flow_class = OpenInKLayout if args.open_in_klayout else ProjectFlow
	flow = flow_class(
		flow_cfg,
		design_dir = ".",
		pdk_root   = pdk_root,
		pdk        = "sky130A",
	)

	flow.start(tag = "wokwi")
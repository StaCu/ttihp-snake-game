from librelane.steps import Step
from librelane.state import DesignFormat
from librelane.common import TclStepMixin

class ShiftRegStep(TclStepMixin, Step):
    id = "ShiftRegStep"
    name = "Run custom Tcl script"

    # Declare what design formats this step consumes and produces
    inputs = [DesignFormat.ODB]
    outputs = [DesignFormat.ODB]

    def get_tcl_script_path(self):
        return "src/shiftreg.tcl"

from librelane.flows import Flow, classic

from . import steps as Shiftreg


@Flow.factory.register()
class ShiftregFlow(classic.Classic):
    id = "ShiftregFlow"
    name = "ShiftregFlow"

    Substitutions = {
        "-OpenROAD.TapEndcapInsertion": Shiftreg.PlaceShiftreg,
    }

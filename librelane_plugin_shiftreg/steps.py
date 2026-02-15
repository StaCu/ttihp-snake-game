from pathlib import Path
from typing import List

from librelane.config import Variable, Config
from librelane.logging import warn
from librelane.state import DesignFormat
from librelane.steps import OpenROAD, OdbpyStep, Step

__file_dir__ = Path(__file__).absolute().parent


@Step.factory.register()
class PlaceShiftreg(OdbpyStep):
    id = "Shiftreg.PlaceShiftreg"

    def get_script_path(self):
        return "placeshiftreg"

    def get_command(self) -> List[str]:
        raw = super().get_command() 
        raw.insert(raw.index("placeshiftreg"), "-m")
        return raw

    def run(self, state_in, **kwargs):
        kwargs, env = self.extract_env(kwargs)
        env["PYTHONPATH"] = str(__file_dir__ / "scripts" / "odbpy")
        return super().run(state_in, env=env, **kwargs)

import argparse
import datetime
import os
from pathlib import Path

import buckpass
import libsbml
from biological_scenarios_generation.model import load_biological_model
from openbox import space
from openbox.utils.constants import SUCCESS

from blackbox import blackbox

OPENBOX_URL: buckpass.openbox_api.URL = buckpass.openbox_api.URL(
    host=os.getenv("OPENBOX_URL") or "", port=8000
)

ORCHESTRATOR_URL = f"http://{os.getenv('ORCHESTRATOR_URL')}:8080/"


def main() -> None:
    argument_parser: argparse.ArgumentParser = argparse.ArgumentParser()
    _ = argument_parser.add_argument("filename")
    filename: str = str(argument_parser.parse_args().filename)

    path = Path(filename)
    assert path.exists()
    assert path.is_file()

    task_id: buckpass.util.OpenBoxTaskId = buckpass.util.OpenBoxTaskId(filename)

    document: libsbml.SBMLDocument = libsbml.readSBML(filename)
    biological_model = load_biological_model(document)
    _space: space.Space = space.Space()
    _space.add_variables(
        [
            space.Real(kinetic_constant, -20.0, 20.0, 0)
            for kinetic_constant in biological_model.virtual_patient_generator.kinetic_constants
        ]
    )

    suggestion: dict[str, float] = buckpass.openbox_api.get_suggestion(
        url=OPENBOX_URL, task_id=task_id
    )

    blackbox_start_time = datetime.datetime.now(tz=datetime.UTC)
    observation = blackbox(
        document=biological_model.document,
        virtual_patient={
            kinetic_constant: 10**value
            for kinetic_constant, value in suggestion.items()
        },
        environment=biological_model.environment_generator(),
        constraints=set(),
    )
    blackbox_end_time = datetime.datetime.now(tz=datetime.UTC)

    trial_info = {
        "cost": (blackbox_end_time - blackbox_start_time).seconds,
        "worker_id": os.getenv("SLURM_JOB_ID"),
        "trial_info": None,
    }

    buckpass.openbox_api.update_observation(
        url=OPENBOX_URL,
        task_id=task_id,
        config_dict=suggestion,
        objectives=[observation],
        constraints=[],
        trial_info=trial_info,
        trial_state=SUCCESS,
    )


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(e, flush=True)


# import json
# import requests
# _ = requests.post(
#     ORCHESTRATOR_URL,
#     data=json.dumps(
#         {"worker_id": os.getenv("SLURM_JOB_ID"), "event": "START"}
#     ),
#     timeout=100,
# )

# _ = requests.post(
#     ORCHESTRATOR_URL,
#     data=json.dumps(
#         {"worker_id": os.getenv("SLURM_JOB_ID"), "event": "END"}
#     ),
#     timeout=100,
# )


# from example import SPACE
# from openbox.utils.config_space import Configuration
# from openbox.utils.constants import SUCCESS


# def blackbox(configuration: Configuration) -> float:
#     x = np.array(list(configuration.get_dictionary().values()))
#     return float(x[0] * x[1] + x[1] ** 2 - x[0] ** 2 * x[1])

# virtual
# machine
# compose

# configuration = Configuration(_space, suggestion)
# SPACE: space.Space = space.Space()
# SPACE.add_variables(
#     [
#         space.Real("x1", -2.5, 2.5, 0),
#         space.Real("x2", -2.4, 2.7, 0),
#     ],
# )

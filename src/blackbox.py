from typing import TYPE_CHECKING

import libsbml
import roadrunner
from biological_scenarios_generation.model import Environment, VirtualPatient

if TYPE_CHECKING:
    import numpy as np

# TODO: iper parameters, maybe a class with the actual names


def blackbox(
    document: libsbml.SBMLDocument,
    virtual_patient: VirtualPatient,
    environment: Environment,
) -> float:
    rr: roadrunner.RoadRunner = roadrunner.RoadRunner(
        libsbml.writeSBMLToString(document)
    )

    for k, value in virtual_patient.items():
        rr[k] = value

    for k, value in environment.items():
        rr[k] = value

    _: np.ndarray = rr.simulate(start=0, end=100, points=1000)

    # TODO: basically calculate loss function according to constraint!, yay

    return 0.0

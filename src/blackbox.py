from typing import TYPE_CHECKING

import libsbml
import matplotlib.pyplot as plt
import roadrunner
from biological_scenarios_generation.core import Interval
from biological_scenarios_generation.model import (
    Environment,
    PhysicalEntity,
    VirtualPatient,
)

if TYPE_CHECKING:
    import numpy as np

# TODO: iper parameters, maybe a class with the actual names


def blackbox(
    document: libsbml.SBMLDocument,
    virtual_patient: VirtualPatient,
    environment: Environment,
    constraints: set[tuple[PhysicalEntity, PhysicalEntity]],
) -> float:
    rr: roadrunner.RoadRunner = roadrunner.RoadRunner(
        libsbml.writeSBMLToString(document)
    )

    for k, value in virtual_patient.items():
        rr[k] = value

    result: np.ndarray = rr.simulate(start=0, end=1, points=1000)

    transitory_penalty: float = 0.0
    for species in range(1, len(rr.timeCourseSelections)):
        concentration_mean_trajectory = [0] * len(result[:, species])
        for i in range(1, len(concentration_mean_trajectory)):
            concentration_mean_trajectory[i] = result[:i, species].mean()

        transitory_penalty += abs(
            concentration_mean_trajectory[-1]
            - concentration_mean_trajectory[
                int(len(concentration_mean_trajectory) / 2)
            ]
        )

        # for concentration in result[:, species]:
        #     pass

    normalization_penalty: float = 0.0
    for species in range(1, len(rr.timeCourseSelections)):
        for concentration in result[:, species]:
            if concentration > 1:
                normalization_penalty += concentration - 1
            elif concentration < 0:
                normalization_penalty += -concentration

    return float(normalization_penalty + transitory_penalty)

    # print(rr.timeCourseSelections)

    # times = result[:, 0]
    # print(times)
    # print(result.shape)
    # print(result)
    # print(result[0])
    # print(rr["time"])
    # for item in environment:
    #     print(item, rr[item])
    # print(rr["species_202124"])
    # print(rr["species_30389"])
    # _ = rr.plot()

    # TODO: basically calculate loss function according to constraint!, yay

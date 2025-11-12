from typing import TYPE_CHECKING

import libsbml
import roadrunner
from biological_scenarios_generation.core import PartialOrder
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
    constraints: PartialOrder[PhysicalEntity],
) -> float:
    rr: roadrunner.RoadRunner = roadrunner.RoadRunner(
        libsbml.writeSBMLToString(document)
    )

    for k, value in virtual_patient.items():
        rr[k] = value

    result: np.ndarray = rr.simulate(start=0, end=20000, points=100000)

    normalization_penalty: float = 0.0
    for col_number, col_name in enumerate(rr.timeCourseSelections):
        if "time" not in col_name and "mean" not in col_name:
            for concentration in result[:, col_number]:
                if concentration > 1:
                    normalization_penalty += concentration - 1
                elif concentration < 0:
                    normalization_penalty += abs(concentration)

    transitory_penalty: float = 0.0
    for col_number, col_name in enumerate(rr.timeCourseSelections):
        if "mean" in col_name:
            transitory_penalty += abs(
                result[-1, col_number] - result[-1000, col_number]
            )

    return float(normalization_penalty + transitory_penalty)

    # import pylab
    #
    # time = result[:, 0]
    # for col_number, col_name in enumerate(rr.timeCourseSelections):
    #     if "time" not in col_name and "mean" not in col_name:
    #         # if result[-1, species] <= 1:
    #         name = col_name
    #         _ = pylab.plot(time, result[:, col_number], label=str(name))
    #         _ = pylab.legend()
    #
    # pylab.show()

    # for species in range(1, len(rr.timeCourseSelections)):
    #     concentration_mean_trajectory = [0] * len(result[:, species])
    #     for i in range(1, len(concentration_mean_trajectory)):
    #         concentration_mean_trajectory[species] = result[:i, species].mean()
    #
    #     transitory_penalty += abs(
    #         concentration_mean_trajectory[-1]
    #         - concentration_mean_trajectory[
    #             int(len(concentration_mean_trajectory) * 0.5)
    #         ]
    #     )

    # for species in range(1, len(rr.timeCourseSelections)):
    #     print(rr.timeCourseSelections[species], result[-1, species])

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

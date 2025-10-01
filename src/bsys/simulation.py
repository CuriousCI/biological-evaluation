""" """

import random

import numpy as np
import roadrunner

from src.bsys.model import Environment, VirtualPatient


def is_virtual_patient_valid(
    rr: roadrunner.RoadRunner,
    virtual_patient: VirtualPatient,
    environment: Environment,
) -> bool:
    """Check if the virtual patient satisfies the constraints imposed by the model."""
    for k, value in virtual_patient.items():
        rr[k] = value

    for _ in range(20):
        for physical_entity in environment.physical_entities:
            rr[repr(physical_entity)] = random.uniform(
                0.01,
                0.1,
                # physical_entity.known_range.lower_bound or 10e-6,
                # physical_entity.known_range.upper_bound or 10e6,
            )

        result: np.ndarray = rr.simulate(
            start=0,
            end=100,
            points=1000,
        )

        # TODO: check result

        # if not nitric_oxide.known_range.contains(result[-1][0]):
        #     return False

    return True

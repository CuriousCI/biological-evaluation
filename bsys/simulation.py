""" """

import random

from bsys.model import VirtualPatientDescription


# TODO: user roadrunner for this
def instantiate_virtual_patient(
    virtual_patient_description: VirtualPatientDescription,
) -> list[tuple[str, float]]:
    virtual_patient = []

    for parameter in virtual_patient_description.parameters:
        value = random.uniform(0.1, 1)
        virtual_patient.append((parameter.getId(), value))
        parameter.setValue(value)

    return virtual_patient

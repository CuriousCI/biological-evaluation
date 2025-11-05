import random
from dataclasses import dataclass
from typing import TypeAlias

import libsbml

from biological_scenarios_generation.core import (
    NormalizedReal,
    ValidRealParameter,
)
from biological_scenarios_generation.reactome import PhysicalEntity

SId: TypeAlias = str

VirtualPatient: TypeAlias = dict[SId, ValidRealParameter]


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class VirtualPatientYielder:
    """A virtual patient is described by the set of parameters."""

    parameters: set[SId]

    def __call__(self) -> VirtualPatient:
        virtual_patient = {}

        for parameter in self.parameters:
            value = random.uniform(-20, 20)
            virtual_patient[parameter] = value

        return virtual_patient


Environment: TypeAlias = dict[SId, NormalizedReal]


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class EnvironmentYielder:
    """An environment dictates the initial conditions of the simulation (initial amounts of the species)."""

    physical_entities: set[PhysicalEntity]

    def __call__(self) -> Environment:
        # TODO yield environment
        return {}


Model: TypeAlias = tuple[
    libsbml.SBMLDocument, VirtualPatientYielder, EnvironmentYielder
]


def load_document(document: libsbml.SBMLDocument) -> Model:
    sbml_model: libsbml.Model = document.getModel()

    return (
        document,
        VirtualPatientYielder(
            {
                parameter.getId()
                for parameter in sbml_model.getListOfParameters()
            }
        ),
        EnvironmentYielder(
            {
                physical_entity.getId()
                for physical_entity in sbml_model.getListOfSpecies()
            }
        ),
    )

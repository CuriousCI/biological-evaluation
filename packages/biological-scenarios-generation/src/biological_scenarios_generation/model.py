import random
from dataclasses import dataclass
from typing import TypeAlias

import libsbml

from biological_scenarios_generation.core import NormalizedReal, PartialOrder
from biological_scenarios_generation.reactome import PhysicalEntity

SId: TypeAlias = str

VirtualPatient: TypeAlias = dict[SId, float]


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class VirtualPatientGenerator:
    """A virtual patient is described by the set of parameters."""

    kinetic_constants: set[SId]

    def __call__(self) -> VirtualPatient:
        return {
            kinetic_constant: 10 ** random.uniform(-20, 0)
            if "half" in kinetic_constant or "k_h_" in kinetic_constant
            else 10 ** random.uniform(-20, 1)
            for kinetic_constant in self.kinetic_constants
            # kinetic_constant: 10 ** random.uniform(-20, 20)
        }


Environment: TypeAlias = dict[SId, NormalizedReal]


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class EnvironmentGenerator:
    """An environment dictates the initial conditions of the simulation (initial amounts of the species)."""

    physical_entities: set[PhysicalEntity]

    def __call__(self) -> Environment:
        return {
            repr(physical_entity): NormalizedReal(random.uniform(0, 1))
            for physical_entity in self.physical_entities
        }


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class BiologicalModel:
    document: libsbml.SBMLDocument
    virtual_patient_generator: VirtualPatientGenerator
    environment_generator: EnvironmentGenerator
    constraints: PartialOrder[PhysicalEntity]

    @staticmethod
    def load(document: libsbml.SBMLDocument) -> "BiologicalModel":
        sbml_model: libsbml.Model = document.getModel()

        return BiologicalModel(
            document=document,
            virtual_patient_generator=VirtualPatientGenerator(
                {
                    parameter.getId()
                    for parameter in sbml_model.getListOfParameters()
                    if "time" not in parameter.getId()
                }
            ),
            environment_generator=EnvironmentGenerator(
                {
                    physical_entity.getId()
                    for physical_entity in sbml_model.getListOfSpecies()
                }
            ),
            constraints=set(),
        )

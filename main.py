""""""

# TODO: https://open-box.readthedocs.io/en/latest/developers_guide/extend_openbox.html
# TODO: https://arxiv.org/abs/1703.03864
# TODO: https://open-box.readthedocs.io/en/latest/examples/ask_and_tell.html
# TODO: https://simgrid.org/doc/latest/Tutorial_MPI_Applications.html

import argparse
from pathlib import Path

import libsbml
import neo4j
import roadrunner

from src.bsys.model import (
    BiologicalScenarioDefinition,
    Environment,
    Interval,
    NonZeroNatural,
    Pathway,
    PhysicalEntity,
    ReactomeDbId,
    VirtualPatient,
    VirtualPatientDetails,
)
from src.bsys.simulation import is_virtual_patient_valid

NEO4J_URL_REACTOME = "neo4j://localhost:7687"
AUTH = ("noe4j", "neo4j")
REACTOME_DATABASE = "graph.db"


def main() -> None:
    """Find virtual patients for a simple biological scenario."""
    nitric_oxide = PhysicalEntity(
        ReactomeDbId(202124),
        Interval(0.000178, 0.00024),
    )
    signal_transduction = Pathway(ReactomeDbId(162582))
    immune_system = Pathway(ReactomeDbId(168256))
    adenosine_triphsphate = PhysicalEntity(ReactomeDbId(113592))
    adenosine_diphsphate = PhysicalEntity(ReactomeDbId(29370))

    biological_scenario_definition: BiologicalScenarioDefinition = (
        BiologicalScenarioDefinition(
            target_physical_entities={nitric_oxide},
            target_pathways={
                signal_transduction,
                immune_system,
            },
            denied_physical_entities={
                adenosine_triphsphate,
                adenosine_diphsphate,
            },
            constraints=[],
            max_depth=None,
        )
    )

    with neo4j.GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME,
        auth=AUTH,
        database=REACTOME_DATABASE,
    ) as driver:
        driver.verify_connectivity()

        sbml_document: libsbml.SBMLDocument
        virtual_patient_details: VirtualPatientDetails
        environment: Environment
        (sbml_document, virtual_patient_details, environment) = (
            biological_scenario_definition.yield_sbml_model(
                driver,
            )
        )

    # print(len(virtual_patient_details.parameters))
    # exit(0)
    sbml_str = libsbml.writeSBMLToString(sbml_document)
    rr: roadrunner.RoadRunner = roadrunner.RoadRunner(sbml_str)
    with Path("test.sbml").open("w") as file:
        _ = file.write(sbml_str)
    # exit(0)

    virtual_patients = []
    for _ in range(1):
        virtual_patient: VirtualPatient = virtual_patient_details()

        if is_virtual_patient_valid(rr, virtual_patient, environment):
            virtual_patients.append(virtual_patient)

    print(len(virtual_patients))


if __name__ == "__main__":
    main()

# TODO: https://www.proteomicsdb.org/
# TODO: which species are genes?
# TODO: the further the distance from a gene the slower the speed of the reaction
# TODO: One instance per physical entity per compartment?
# that's how I handle it! species X_(c_1) reaction converts into X_(c_2) (also X, but in compartment c_2)
# TODO: ReactionLikeEvent 'category' attribute
# - "dissociation"
# - "binding"
# - "transition"
# - "omitted"
# - "uncertain"
# TODO: add "debug/verbose mode" with additional annotations!
# TODO: interesting, there are multiple compartments when a PhysicalEntity is in multiple complexes

# TODO: rr.timeCourseSelections = [repr(nitric_oxide)]
# TODO: might be useful to pass reactome url as argument! for docker compose!
# TODO: add simulation time and steps to biological scenario definition
# TODO: add sbo terms
# TODO: handle "max_level" attribute in biological scenario
# TODO: PA1-1 (10766891 10797661 10840473)

# TODO: kinetic constant value in 10^-6 10^6 (review first stuff)
# TODO: this is a macroscopical + phenomenological approach (compared to microscopical simulation of single components)
# TODO: consider protein transportation too!!!!! How do you handle it better?
# TODO: maybe for transport reactions there are better laws to use

# TODO: can the kinetic law be part of the virtual patient? Like you can choose randomly a law, to describe the patient
# TODO: rename catalysts to "enzymes" in UML too!
# TODO: ok, find a way to tell if a entity is on the boundary and must be fueled! This is part of the environment!

# TODO: quantitative + deterministic + continuos (or discrete?) + some reactions are reversible (not the whoel process) + (it shouldn't be periodic, right?) + model
# TODO: Human Genome Project
# TODO: Taylor, C.F. et al. (2003) A systematic approach to modeling, capturing, and disseminating proteomics experimental data. Nat. Biotechnol., 21, 247-254.
# TODO: Gene Ontology
# TODO: SBGN (maybe generate graphical model from the actual sbml one?)
# TODO: MIRIAM could be useful, it defines standards for different types of systems biology models
# TODO: at some point the system reaches and equilibrium, even with wildly different initial conditions


# TODO: to construct models in such ways that the disregarded properties do not compromise the basic results of the model. TODO: stabilità
# TODO: integrate bionumbers for more useful models (from compartment sizes, with averages if undefined, to species quantities)
# TODO: handle modifiers in reactions
# TODO: possibile test... se prendo tutte le possibili medicazioni, tecnicamente se le levo, il set di pazienti virtuali si interseca con quello che prende medicinali
# TODO: exclude certain Physical Entities!
# TODO: maybe you should rename __model_objects with something better?
# TODO: treat Natural as an int
# TODO: createKineticLawParameter() ... instead of just createParameter(), at least check difference
# TODO: Well, I can just use this stuff repeatedly as long as I have a set of Parameter
# TODO: use libsbml.ASTNode instead of MathML for kinetic law __call__
# TODO: write constraints in terms of PhysicalEntity, a formula on PhysicalEntity, ReactionLikeEvent (somehow almost done)

# TODO: parallelize on cluster
# TODO: docs; DONE (at least started)

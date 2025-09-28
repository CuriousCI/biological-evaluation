"""Guacamole."""

from pathlib import Path

import libsbml
import neo4j
import numpy
import roadrunner

import bsys.simulation as sim
from bsys.model import (
    BiologicalScenarioDefinition,
    Interval,
    Pathway,
    PhysicalEntity,
    ReactomeDbId,
    VirtualPatientDescription,
)

NEO4J_URL_REACTOME = "neo4j://localhost:7687"
AUTH = ("noe4j", "neo4j")
REACTOME_DATABASE = "graph.db"

# TODO: integrate bionumbers for more useful models (from compartment sizes, with averages if undefined, to species quantities)
# TODO: handle modifiers in reactions
# TODO: download https://bionumbers.hms.harvard.edu/resources.aspx
# TODO: add parameters for species amounts?
# TODO: possibile test... se prendo tutte le possibili medicazioni, tecnicamente se le levo, il set di pazienti virtuali si interseca con quello che prende medicinali
# TODO: http://sys-bio.github.io/roadrunner/docs-build/tutorial/tutorial.html
# TODO: rename 'library' to 'Virtual patients' or stuff like that, and just fix the organization of the 'src' folder
# TODO: exclude certain Physical Entities!
# TODO: __repr__ for compartments etc... just to make it easier to display, maybe with handling of the default?
# TODO: there are too many 'compartment_default's
# TODO: maybe you should rename __model_objects with something better?
# TODO: treat Natural as an int
# TODO: in the biological scenario description, you say the "default law" (0..1, otherwise LawOfMassAction is used)
# TODO: parameterId instead of str for Environment
# TODO: other than parameters, I also need initial quantities in environemnt
# TODO: https://gasgasgas.uk/michaelis-menten-enzyme-kinetics/
# TODO: createKineticLawParameter() ... instead of just createParameter(), at least check difference
# TODO: set random value for kinetic law parameter! This is part of Env? No, but must be set! Wait: are you sure isn't part of env? Yes! it's part of "instance" somehow!
# TODO: Well, I can just use this stuff repeatedly as long as I have a set of Parameter
# TODO: use libsbml.ASTNode instead of MathML for kinetic law __call__
# TODO: write constraints in terms of PhysicalEntity, a formula on PhysicalEntity, ReactionLikeEvent (somehow almost done)
# TODO: parallelize on cluster


def main() -> None:
    """Simulate a simple biological scenario."""
    nitric_oxide = PhysicalEntity(
        ReactomeDbId(202124),
        Interval(0.000178, 0.00024),
    )
    signal_transduction = Pathway(ReactomeDbId(162582))
    immune_system = Pathway(ReactomeDbId(168256))

    biological_scenario_definition: BiologicalScenarioDefinition = (
        BiologicalScenarioDefinition(
            target_physical_entities={nitric_oxide},
            target_pathways={
                signal_transduction,
                immune_system,
            },
            constraints=[f"{nitric_oxide} > 10"],
        )
    )

    with neo4j.GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME,
        auth=AUTH,
        database=REACTOME_DATABASE,
    ) as driver:
        driver.verify_connectivity()

        sbml_document: libsbml.SBMLDocument
        virtual_patient_description: VirtualPatientDescription
        (sbml_document, virtual_patient_description, _) = (
            biological_scenario_definition.yield_sbml_model(
                driver,
            )
        )

        virtual_patients = []
        for _ in range(10):
            virtual_patient = sim.instantiate_virtual_patient(
                virtual_patient_description
            )

            sbml_str = libsbml.writeSBMLToString(sbml_document)
            with Path("test.sbml").open("w") as file:
                _ = file.write(sbml_str)

            rr = roadrunner.RoadRunner(sbml_str)
            rr.timeCourseSelections = ["species_202124"]
            result: numpy.ndarray = rr.simulate(start=0, end=100, points=100000)
            if result[-1] > 0.01:
                virtual_patients.append(virtual_patient)

        print(virtual_patients)


if __name__ == "__main__":
    main()

# bionumbers_table = pandas.read_csv("bionumbers.csv")
# units = set()
# keywords: set[str] = set()
# for _, row in bionumbers_table.iterrows():
#     # if (
#     #     difflib.SequenceMatcher(
#     #         None,
#     #         str(row["Properties"]).lower(),
#     #         "nitric oxide",
#     #     ).ratio()
#     #     > 0.6
#     # ):
#     # print(*str(row["Keywords"]).split(","), sep=" | ")
#     keywords = keywords | {
#         keyword.lower().strip()
#         for keyword in str(row["Keywords"]).split(",")
#     }
#
#     if "nitric oxide" in str(row["Properties"]).lower():
#         # print(row["Organism"], row["Range"], row["Units"])
#         print(
#             f"{row['Organism']} \n \t {row['Properties']} \n \t {row['Range']} {row['Units']}"
#         )
#     # print(line)
#
# print(*keywords, sep="\n")
# exit(0)

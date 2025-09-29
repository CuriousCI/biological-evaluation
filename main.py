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

# TODO: energetical supplying / demanding / neutral reactions
# TODO: this is a macroscopical + phenomenological approach (compared to microscopical simulation of single components)
# TODO: CatalystActivity has order and stoichiometry
# TODO: consider protein transportation too!!!!! How do you handle it better?
# TODO: maybe for transport reactions there are better laws to use

# TODO: can the kinetic law be part of the virtual patient? Like you can choose randomly a law, to describe the patient
# TODO: rename catalysts in "enzymes" in UML too!
# TODO: ok, find a way to tell if a entity is on the boundary and must be fueled! This is part of the environment!

# TODO: quantitative + deterministic + continuos (or discrete?) + some reactions are reversible (not the whoel process) + (it shouldn't be periodic, right?) + model
# TODO: Human Genome Project
# TODO: Taylor, C.F. et al. (2003) A systematic approach to modeling, capturing, and disseminating proteomics experimental data. Nat. Biotechnol., 21, 247–254.
# TODO: Gene Ontology
# TODO: SBGN (maybe generate graphical model from the actual sbml one?)
# TODO: MIRIAM could be useful, it defines standards for different types of systems biology models
# TODO: at some point the system reaches and equilibrium, even with wildly different initial conditions


# TODO: What question is the model supposed to answer?
# TODO: Is it built to explain a surprising observation?
# TODO: Is it built to relate separate observations with each other and with previous knowledge?
# TODO: Is it built to make predictions, for example, about the effect of specific perturbations?
# TODO: Often, a major function of models is to make assumptions about the underlying process explicit and, hence, testable.


# TODO: (this is basically my case, the other 2, boolean networks and stochastic descriptions do not really matter) Network-based models describe and analyze properties, states, or dynamics of networks, that is, components and their interactions. Typical and frequently used network- centered modeling frameworks are as follows: Systems of ordinary differential equations for bio­ chemical reaction networks

# TODO: maybe add other variables other than the mithical amount
# TODO: This can be kinetic laws for individual reactions or instructions for combining input information arriving at a node from different edges as in Boolean networks. (kinetic laws is my stuff!)
# TODO: ODE systems are deterministic

# TODO: 1) Define the question that the model shall help to answer.
# TODO: 2) Seek available information: Read the literature. Look at the available experimental data. Talk to experts in the field.
# TODO: 3) Formulate a mental model.
# TODO: 4) Decide on the modeling concept (network-based or rule-based, deterministic or stochastic, etc.)
# TODO: 5) Formulate the first (simple) mathematical model.
# TODO: 6) Test the model performance in comparison to the available data.
# TODO: 7) Refine the model, estimate parameters.
# TODO: 8) Analyze the system (parameter sensitivity, static and temporal behaviors, etc.)
# TODO: 9) Make predictions for scenarios not used to construct the model such as gene knockout or overexpression, application of different stimuli or perturbations.
# TODO: 10) Compare predictions and experimental results.


# TODO:  to construct models in such ways that the disregarded properties do not compromise the basic results of the model. TODO: stabilità
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
            constraints=[f"{nitric_oxide} > 0.00005"],
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
                virtual_patient_description,
            )

            sbml_str = libsbml.writeSBMLToString(sbml_document)
            with Path("test.sbml").open("w") as file:
                _ = file.write(sbml_str)

            # ....
            rr = roadrunner.RoadRunner(sbml_str)
            rr.timeCourseSelections = ["species_202124"]
            result: numpy.ndarray = rr.simulate(start=0, end=100, points=100000)
            if result[-1][0] > 0.01:
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

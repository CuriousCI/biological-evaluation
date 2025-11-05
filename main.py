import sys
from pathlib import Path

import libsbml
import neo4j
from biological_scenarios_generation.core import Interval, IntGTZ
from biological_scenarios_generation.model import load_document
from biological_scenarios_generation.reactome import (
    Pathway,
    PhysicalEntity,
    ReactomeDbId,
)
from biological_scenarios_generation.scenario import (
    BiologicalScenarioDefinition,
)

NEO4J_URL_REACTOME = "neo4j://localhost:7687"
AUTH = ("noe4j", "neo4j")
REACTOME_DATABASE = "graph.db"


def main() -> None:
    filename: str = "document.sbml"
    path = Path(filename)
    if path.exists() and path.is_file():
        doc: libsbml.SBMLDocument = libsbml.readSBML(filename)
        (doc, vp, env) = load_document(doc)
        print(vp.parameters)
        print(env.physical_entities)

        sys.exit()

        # with path.open("r") as file:
        # doc = libsbml.SBMLDocument(3, 1)
    nitric_oxide = PhysicalEntity(
        ReactomeDbId(202124), Interval(0.000178, 0.00024)
    )
    signal_transduction = Pathway(ReactomeDbId(162582))
    immune_system = Pathway(ReactomeDbId(168256))
    adenosine_triphsphate = PhysicalEntity(ReactomeDbId(113592))
    adenosine_diphsphate = PhysicalEntity(ReactomeDbId(29370))

    biological_scenario_definition: BiologicalScenarioDefinition = (
        BiologicalScenarioDefinition(
            target_physical_entities={nitric_oxide},
            target_pathways={signal_transduction, immune_system},
            excluded_physical_entities={
                adenosine_triphsphate,
                adenosine_diphsphate,
            },
            constraints=[],
            max_depth=IntGTZ(3),
        )
    )

    with neo4j.GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME, auth=AUTH, database=REACTOME_DATABASE
    ) as driver:
        driver.verify_connectivity()
        doc: libsbml.SBMLDocument
        (doc, _, _) = biological_scenario_definition.generate_model(driver)

    with Path(filename).open("w") as file:
        _ = file.write(libsbml.writeSBMLToString(doc))


if __name__ == "__main__":
    main()

from pathlib import Path

import libsbml
import neo4j
from biological_scenarios_generation.core import Interval
from biological_scenarios_generation.generation import (
    BiologicalScenarioDefinition,
)
from biological_scenarios_generation.reactome import (
    Pathway,
    PhysicalEntity,
    ReactomeDbId,
)

NEO4J_URL_REACTOME = "neo4j://localhost:7687"
AUTH = ("noe4j", "neo4j")
REACTOME_DATABASE = "graph.db"


def main() -> None:
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
            excluded_physical_entities={
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
        (sbml_document, _, _) = biological_scenario_definition.yield_sbml_model(
            driver,
        )

    with Path("x.sbml").open("w") as file:
        _ = file.write(libsbml.writeSBMLToString(sbml_document))


if __name__ == "__main__":
    main()

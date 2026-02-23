import os
from pathlib import Path

import libsbml
import neo4j
from biological_scenarios_generation.core import IntGTZ
from biological_scenarios_generation.model import BiologicalModel
from biological_scenarios_generation.reactome import (
    Pathway,
    PhysicalEntity,
    ReactomeDbId,
)
from biological_scenarios_generation.scenario import (
    BiologicalScenarioDefinition,
)

from core.lib import init

# from neo4j.exceptions import ServiceUnavailable

# from core.blackbox import objective_function_multi_objective, plot
# , openbox_config_multiobjective

_, logger = init()


def main() -> None:
    signal_transduction = Pathway(id=ReactomeDbId(162582))
    nitric_oxide = PhysicalEntity(id=ReactomeDbId(202124))
    cyclic_amp = PhysicalEntity(id=ReactomeDbId(30389))
    adenosine_triphsphate = PhysicalEntity(id=ReactomeDbId(113592))
    adenosine_diphsphate = PhysicalEntity(id=ReactomeDbId(29370))

    biological_scenario_definition: BiologicalScenarioDefinition = (
        BiologicalScenarioDefinition(
            physical_entities={nitric_oxide, cyclic_amp},
            pathways={signal_transduction},
            excluded_physical_entities={
                adenosine_triphsphate,
                adenosine_diphsphate,
            },
            constraints={(nitric_oxide, cyclic_amp)},
            max_depth=IntGTZ(2),
        )
    )

    filename = Path(f"{Path(__file__).stem}.sbml")

    with neo4j.GraphDatabase.driver(
        uri=os.getenv("REACTOME_URL", default=""),
        auth=(
            os.getenv("REACTOME_USERNAME", default=""),
            os.getenv("REACTOME_PASSWORD", default=""),
        ),
        database=os.getenv("REACTOME_DATABASE"),
    ) as driver:
        driver.verify_connectivity()
        biological_model: BiologicalModel = (
            biological_scenario_definition.generate_biological_model(driver)
        )

    with filename.open("w") as file:
        _ = file.write(
            libsbml.writeSBMLToString(biological_model.sbml_document)
        )


if __name__ == "__main__":
    main()

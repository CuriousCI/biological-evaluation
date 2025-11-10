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

from blackbox import blackbox

NEO4J_URL_REACTOME = "neo4j://localhost:7687"
AUTH = ("noe4j", "neo4j")
REACTOME_DATABASE = "graph.db"


def main() -> None:
    signal_transduction = Pathway(ReactomeDbId(162582))
    nitric_oxide = PhysicalEntity(ReactomeDbId(202124))
    cyclic_amp = PhysicalEntity(ReactomeDbId(30389))
    adenosine_triphsphate = PhysicalEntity(ReactomeDbId(113592))
    adenosine_diphsphate = PhysicalEntity(ReactomeDbId(29370))

    biological_scenario_definition: BiologicalScenarioDefinition = (
        BiologicalScenarioDefinition(
            physical_entities={nitric_oxide, cyclic_amp},
            pathways={signal_transduction},
            ignored_physical_entities={
                adenosine_triphsphate,
                adenosine_diphsphate,
            },
            constraints={(nitric_oxide, cyclic_amp)},
            max_depth=IntGTZ(2),
        )
    )

    # TODO: python, reflection, get current filename, strip ".py", add ".sbml"
    filename: str = "experiment1.sbml"

    try:
        with neo4j.GraphDatabase.driver(
            uri=NEO4J_URL_REACTOME, auth=AUTH, database=REACTOME_DATABASE
        ) as driver:
            driver.verify_connectivity()
            biological_model = (
                biological_scenario_definition.generate_biological_model(driver)
            )

        with Path(filename).open("w") as file:
            _ = file.write(libsbml.writeSBMLToString(biological_model.document))
    except Exception as e:
        path = Path(filename)
        assert path.exists()
        assert path.is_file()

        document: libsbml.SBMLDocument = libsbml.readSBML(filename)
        biological_model: BiologicalModel = BiologicalModel.load(document)

    # print(biological_model.virtual_patient_generator.kinetic_constants)

    objective_function_value = blackbox(
        document=biological_model.document,
        virtual_patient=biological_model.virtual_patient_generator(),
        environment=biological_model.environment_generator(),
        constraints=biological_scenario_definition.constraints,
    )

    print(objective_function_value)

    # TODO: store values in log
    # exit()
    # print(e)
    # exit()


if __name__ == "__main__":
    main()

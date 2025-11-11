import argparse
import os
from pathlib import Path

import buckpass
from biological_scenarios_generation.model import BiologicalModel, libsbml
from buckpass.policy.burst_policy import BurstPolicy
from openbox import space
from openbox.artifact.remote_advisor import RemoteAdvisor

policy: (
    None | BurstPolicy[buckpass.util.SlurmJobId, buckpass.util.OpenBoxTaskId]
) = None


def main() -> None:
    argument_parser: argparse.ArgumentParser = argparse.ArgumentParser()
    _ = argument_parser.add_argument("-f", "--file", required=True)
    args = argument_parser.parse_args()

    path = Path(args.file)
    assert path.exists()
    assert path.is_file()

    document: libsbml.SBMLDocument = libsbml.readSBML(args.file)
    biological_model = BiologicalModel.load(document)

    _space: space.Space = space.Space()
    _space.add_variables(
        [
            space.Real(kinetic_constant, -20.0, 0.0, 0.0)
            if "k_h_" in kinetic_constant
            else space.Real(kinetic_constant, -20.0, 20.0, 0.0)
            for kinetic_constant in biological_model.virtual_patient_generator.kinetic_constants
        ]
    )

    remote_advisor: RemoteAdvisor = RemoteAdvisor(
        config_space=_space,
        server_ip="localhost",
        port=8000,
        email="test@test.test",
        password=os.getenv("OPENBOX_PASSWORD"),
        task_name=args.file,
        num_objectives=1,
        num_constraints=0,
        sample_strategy="bo",
        surrogate_type="gp",
        acq_type="ei",
        max_runs=1000,
    )

    _ = BurstPolicy(
        args=f"--task {remote_advisor.task_id} --file {args.file}",
        batch_size=buckpass.IntGEZ(1000),
        submitter=buckpass.Uniroma1Submitter(),
    )


if __name__ == "__main__":
    main()

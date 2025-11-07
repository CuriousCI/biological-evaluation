"""submit a job with slurm via ssh to uniroma1 CS department cluster."""

import os
import subprocess

from typing_extensions import override

from buckpass.core import Submitter
from buckpass.core.util import OpenBoxTaskId, SlurmJobId


class Uniroma1Submitter(Submitter[SlurmJobId, OpenBoxTaskId]):
    """submit a job with slurm via ssh to uniroma1 CS department cluster."""

    @override
    def submit(self, args: OpenBoxTaskId) -> SlurmJobId:
        # ssh -i ~/.ssh/Uniroma1Cluster cicio_2048752@151.100.174.45 "echo 'hello'
        stdout: str = subprocess.run(
            [
                "ssh",
                "-i",
                "~/.ssh/Uniroma1Cluster",
                f"{os.getenv('CLUSTER_USER')}{os.getenv('FRONTEND_ADDRESS')}",
                f'"ssh submitter \\"sbatch {os.getenv("CLUSTER_PROJECT_PATH")}/src/job.sh {args}\\""',
            ],
            check=False,
            capture_output=True,
        ).stdout.decode()

        # `sbatch` prints "Submitted batch job 781422" to stdout
        return "".join(filter(str.isnumeric, stdout))

        # "/usr/bin/sshpass",
        # "-p",
        # "root",
        # "ssh",
        # "-o",
        # "StrictHostKeyChecking=no",
        # "slurmctld",
        # f'""sbatch /data/job.sh {args}""',
        # return ""

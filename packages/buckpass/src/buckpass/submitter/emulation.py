import subprocess

from typing_extensions import override

from buckpass.core import OpenBoxTaskId, SlurmJobId
from buckpass.core.submitter import Submitter


class EmulationSubmitter(Submitter[OpenBoxTaskId, SlurmJobId]):
    @override
    def submit(self, args: OpenBoxTaskId) -> SlurmJobId:
        completed_process = subprocess.run(
            [
                "/usr/bin/sshpass",
                "-p",
                "root",
                "ssh",
                "-o",
                "StrictHostKeyChecking=no",
                "slurmctld",
                f'""sbatch /data/job.sh {args}""',
            ],
            check=False,
            capture_output=True,
        )

        stdout: str = completed_process.stdout.decode()
        stderr: str = completed_process.stderr.decode()
        print(stdout, stderr, sep="\n")

        # `sbatch` prints "Submitted batch job 781422" to stdout
        return "".join(filter(str.isnumeric, stdout))

#!/bin/bash

#SBATCH --account=<account>
#SBATCH --array=<indexes>
#SBATCH --batch=<list>
#SBATCH --begin=<time>
#SBATCH --chdir=$HOME/director
#SBATCH --container=<path_to_container>
#SBATCH --container-id=<container_id>
#SBATCH --cores-per-socket=<cores>
#SBATCH --cpu-freq=<p1>[-p2][:p3]
#SBATCH --cpus-per-task=1
#SBATCH --deadline=<OPT>
#SBATCH --delay-boot=<minutes>
#SBATCH --dependency=<dependency_list>
#SBATCH --error=<filename_pattern>
#SBATCH --export={[ALL,]<environment_variables>|ALL|NIL|NONE}
#SBATCH --export-file={<filename>|<fd>}
#SBATCH --extra-node-info=<sockets>[:cores[:threads]]
#SBATCH --get-user-env
#SBATCH --gid=<group>
#SBATCH --gres=<list>
#SBATCH --gres-flags=<type>
#SBATCH --hint=compute_bound
#SBATCH --input=<filename_pattern>
#SBATCH --job-name="déjà vu"
#SBATCH --mail-type=END
#SBATCH --mail-user=cicio.2048752@studenti.uniroma1.it
#SBATCH --mem=<size>[units]
#SBATCH --mincpus=<n>
#SBATCH --network=<type>
#SBATCH --nice[=adjustment]
#SBATCH --no-kill[=off]
#SBATCH --no-requeue
#SBATCH --nodefile=<node_file>
#SBATCH --nodelist=<node_name_list>
#SBATCH --nodes=<minnodes>[-maxnodes]|<size_string>
#SBATCH --ntasks=<number>
#SBATCH --ntasks-per-core=<ntasks>
#SBATCH --ntasks-per-gpu=<ntasks>
#SBATCH --ntasks-per-node=<ntasks>
#SBATCH --ntasks-per-socket=<ntasks>
#SBATCH --oom-kill-step[={0|1}]
#SBATCH --open-mode={append|truncate}
#SBATCH --output=<filename_pattern>
#SBATCH --overcommit
#SBATCH --oversubscribe
#SBATCH --parsable
#SBATCH --partition=students
#SBATCH --prefer=<list>
#SBATCH --priority=<value>
#SBATCH --profile={all|none|<type>[,<type>...]}
#SBATCH --propagate[=rlimit[,rlimit...]]
#SBATCH --qos=<qos>
#SBATCH --quiet
#SBATCH --requeue[=expedited]
#SBATCH --reservation=<reservation_names>
#SBATCH --resources=<resource_names>
#SBATCH --resv-ports[=count]
#SBATCH --segment=<segment_size>
#SBATCH --signal=[{R|B}:]<sig_num>[@sig_time]
#SBATCH --sockets-per-node=<sockets>
#SBATCH --spread-job
#SBATCH --spread-segments
#SBATCH --stepmgr
#SBATCH --switches=<count>[@max-time]
#SBATCH --test-only
#SBATCH --thread-spec=<num>
#SBATCH --threads-per-core=<threads>
#SBATCH --time=<time>
#SBATCH --time-min=<time>
#SBATCH --tmp=<size>[units]
#SBATCH --tres-bind=<tres>:[verbose,]<type>[+<tres>:
#SBATCH --tres-per-task=<list>
#SBATCH --uid=<user>
#SBATCH --usage
#SBATCH --use-min-nodes
#SBATCH --wait TODO: useless in my case
#SBATCH --wait-all-nodes=<value>


# TODO: maybe array shouldn't be handled here, maybe externally based on the number of points
#SBATCH --array=0-15%2
#SBATCH --cpu-freq=<p1>[-p2][:p3]
#SBATCH --cpus-per-task=1
#SBATCH --hint=compute_bound
#SBATCH --job-name="déjà vu"

# from dataclasses import dataclass
# from enum import StrEnum, auto
#
# from ipaddress import IPv4Address
# import json
# import os
# import subprocess
# from typing import Callable, Generic, TypeVar, override
# from lib import IntGTZ, Policy, Submitter
# from subprocess import CompletedProcess


# type SlurmJobId = str
#
#
# class Port:
#     pass


# from abc import ABC, abstractmethod
# from typing import Generic, TypeVar

# Arguments = TypeVar(name="Arguments")
# ProcessId = TypeVar(name="ProcessId")
#
#
# class Submitter(ABC, Generic[Arguments, ProcessId]):
#     @abstractmethod
#     def submit(self, arguments: Arguments) -> ProcessId: ...


# Event = TypeVar(name="Event")
#
#
# class Policy(ABC, Generic[Event]):
#     @abstractmethod
#     def update(self, event: Event) -> None: ...

# @dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
# class SlurmJobArguments:
#     configurations: list[Configuration]
#
#     @override
#     def __repr__(self) -> str:
#         return json.dumps([])


# SBATCH --array=<indexes> # TODO
# SBATCH --chdir=~/logs # TODO where should it work? In the folder of the project? Yeah, it makes sense, just launch it from there
# SBATCH --container=<path_to_container>
# SBATCH --container-id=<container_id>

# TODO: how many points do I want

# sbatch --array=0-15:2
# run jobs 0 to 15 with at most 2 at the same time


# class SlurmSubmitter(Submitter[SlurmJobArguments, SlurmJobId]):
#     @override
#     def submit(self, arguments: SlurmJobArguments) -> SlurmJobId:
#         # TODO: mail
#
#         #   --container=<path_to_container>
#         #        Absolute path to OCI container bundle.
#         #
#         # --container-id=<container_id>
#         #        Unique name for OCI container.
#
#         # from ipaddress import IPv4Address
#         # director_node_address: IPv4Address
#         # director_port: Port
#
#         # TODO: handle requirements for job in job.sh
#
#         # -D, --chdir=<directory>
#         #       Set  the working directory of the batch script to directory before it is executed. The path can be specified as full path or relative path to
#         #       the directory where the command is executed.
#
#         # `sbatch` prints "Submitted batch job 781422" to stdout
#         return "".join(filter(str.isnumeric, submit_process.stdout.decode()))
#
#         # scontrol show node $SLURMD_NODENAME | grep -oP '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b '
#         # scontrol show node $SLURMD_NODENAME | grep -oP 'NodeAddr=([0-9\.]+)' | grep -oP '[0-9\.]+'
#         # scontrol show node $SLURMD_NODENAME | grep -oP "NodeAddr=\K[0-9\.]+"
#
#         # TODO: echo $SLURMD_NODENAME (for )
#         # TODO: echo $HOSTNAME
#         # TODO: $SLURM_LAUNCH_NODE_IPADDR
#         # TODO: call repr() on args, also it must be true that str converts to json
#
#         # ip_address =
#         # ip_address_process: CompletedProcess[bytes] = subprocess.run(
#         #     [
#         #         "scontrol",
#         #         "show",
#         #         "node",
#         #         f"{os.getenv('SLURMD_NODENAME')}",
#         #         "|",
#         #         "grep",
#         #         "-oP",
#         #         '"NodeAddr=\\K[0-9\\.]+"',
#         #     ],
#         #     check=False,
#         #     capture_output=True,
#         # )
#
#         # completed_process = subprocess.run(
#         #     [
#         #         "/usr/bin/ssh",
#         #         "-i",
#         #         "~/.ssh/Uniroma1Cluster",
#         #         f"{os.getenv('CLUSTER_USER')}@{os.getenv('FRONTEND_HOST')}",
#         #         f'""ssh submitter \\\\"sbatch -J {job_name} -c 1 /home/{os.getenv("CLUSTER_USER")}/{os.getenv("PROJECT_PATH")}/src/job.sh {args}\\\\" ""',
#         #     ],
#         #     check=False,
#         #     capture_output=True,
#         # )
#         #
#         # stdout: str = completed_process.stdout.decode()
#         # stderr: str = completed_process.stderr.decode()
#         # print(stdout, stderr, sep="\n")
#         #
#         # return "".join(filter(str.isnumeric, stdout))
#
#
# class SlurmEvent(StrEnum):
#     START = auto()
#     END = auto()
#     FAIL = auto()
#
#
# # ProcessIdentifier = TypeVar("ProcessIdentifier")
# # Arguments = TypeVar("Arguments")
#
#
# # @dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
# # class Event:
# #     worker_id: SlurmJobId
# #     event: SlurmEvent

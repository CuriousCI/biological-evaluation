from __future__ import annotations

from enum import Enum
from typing import Generic, TypeVar

from typing_extensions import override

from buckpass.core import IntGEZ, Policy, Submitter


class WorkerEvent(Enum):
    START = 0
    END = 1


WorkerId = TypeVar("WorkerId")
Args = TypeVar("Args")


class FixedBatchPolicy(
    Policy[tuple[WorkerId, WorkerEvent]],
    Generic[Args, WorkerId],
):
    __args: Args
    __workers_batch_size: IntGEZ
    __submitter: Submitter[WorkerId, Args]
    __submitted_workers: set[WorkerId]
    __running_workers: set[WorkerId]

    def __init__(
        self,
        args: Args,
        workers_batch_size: IntGEZ,
        submitter: Submitter[WorkerId, Args],
    ) -> None:
        super().__init__()

        self.__args = args
        self.__workers_batch_size = workers_batch_size
        self.__submitter = submitter
        self.__submitted_workers = set()
        self.__running_workers = set()

        for _ in range(workers_batch_size):
            worker_id = self.__submitter.submit(self.__args)
            self.__submitted_workers.add(worker_id)

    @override
    def update(self, event: tuple[WorkerId, WorkerEvent]) -> None:
        (job_id, job_event_type) = event

        if job_id not in self.__running_workers:
            return

        match job_event_type:
            case WorkerEvent.START:
                self.__submitted_workers.remove(job_id)
                self.__running_workers.add(job_id)
            case WorkerEvent.END:
                # A worker might be cancelled before running
                self.__submitted_workers.remove(job_id)
                self.__running_workers.remove(job_id)

        while len(self.__submitted_workers) < self.__workers_batch_size:
            worker_id = self.__submitter.submit(self.__args)
            self.__submitted_workers.add(worker_id)

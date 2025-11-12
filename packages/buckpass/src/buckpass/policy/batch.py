from __future__ import annotations

from enum import StrEnum, auto
from typing import TYPE_CHECKING, Generic, TypeVar

from typing_extensions import override

from buckpass.core.policy import Policy

if TYPE_CHECKING:
    from buckpass.core import IntGTZ
    from buckpass.core.submitter import Submitter


class WorkerEvent(StrEnum):
    START = auto()
    END = auto()
    FAIL = auto()


Id = TypeVar("Id")
Args = TypeVar("Args")


class BatchPolicy(Policy[tuple[Id, WorkerEvent]], Generic[Args, Id]):
    __args: Args
    __executions: IntGTZ
    __size: IntGTZ
    __submitter: Submitter[Args, Id]

    __waiting_workers: set[Id]
    __running_workers: set[Id]
    __completed_executions: int = 0

    def __init__(
        self,
        args: Args,
        executions: IntGTZ,
        size: IntGTZ,
        submitter: Submitter[Args, Id],
    ) -> None:
        super().__init__()

        self.__args = args
        self.__executions = executions
        self.__size = size
        self.__submitter = submitter
        self.__waiting_workers = set()
        self.__running_workers = set()

        self.__fill()

    @override
    def update(self, event: tuple[Id, WorkerEvent]) -> None:
        (worker_id, worker_event) = event

        match worker_event:
            case WorkerEvent.START:
                if worker_id in self.__waiting_workers:
                    self.__waiting_workers.remove(worker_id)
                    self.__running_workers.add(worker_id)
            case WorkerEvent.END:
                if worker_id in self.__waiting_workers:
                    self.__waiting_workers.remove(worker_id)
                if worker_id in self.__running_workers:
                    self.__running_workers.remove(worker_id)
                self.__completed_executions += 1
            case WorkerEvent.FAIL:
                if worker_id in self.__waiting_workers:
                    self.__waiting_workers.remove(worker_id)
                if worker_id in self.__running_workers:
                    self.__running_workers.remove(worker_id)

        self.__fill()

    def __fill(self) -> None:
        while (
            len(self.__waiting_workers) + len(self.__running_workers)
            < self.__size
            and self.__completed_executions < self.__executions
        ):
            worker_id = self.__submitter.submit(self.__args)
            self.__waiting_workers.add(worker_id)

    def is_completed(self) -> bool:
        return (
            len(self.__waiting_workers) == 0
            and self.__completed_executions >= self.__executions
        )

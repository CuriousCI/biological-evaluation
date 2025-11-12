from abc import ABC, abstractmethod
from typing import Generic, TypeVar

Args = TypeVar("Args")
Id = TypeVar("Id")


class Submitter(ABC, Generic[Args, Id]):
    @abstractmethod
    def submit(self, args: Args) -> Id:
        pass

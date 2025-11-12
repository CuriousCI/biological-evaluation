from abc import ABC, abstractmethod
from typing import Generic, TypeVar

Event = TypeVar("Event")


class Policy(ABC, Generic[Event]):
    @abstractmethod
    def update(self, event: Event) -> None:
        pass

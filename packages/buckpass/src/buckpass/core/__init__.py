from typing import TypeAlias

SlurmJobId: TypeAlias = str
OpenBoxTaskId: TypeAlias = str


class IntGEZ(int):
    """Int with value x >= 0."""

    def __new__(cls, value: int) -> "IntGEZ":
        assert value >= 0
        return super().__new__(cls, value)


class IntGTZ(int):
    """Int with value x >= 0."""

    def __new__(cls, value: int) -> "IntGTZ":
        assert value > 0
        return super().__new__(cls, value)

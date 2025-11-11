import math
from dataclasses import dataclass, field
from typing import Self, TypeAlias, TypeVar

T = TypeVar("T")
PartialOrder: TypeAlias = set[tuple[T, T]]


class IntGEZ(int):
    """int greater or equal to 0."""

    def __new__(cls, value: int) -> Self:
        assert value >= 0
        return super().__new__(cls, value)


class IntGTZ(int):
    """int greater than 0."""

    def __new__(cls, value: int) -> Self:
        assert value > 0
        return super().__new__(cls, value)


class NormalizedReal(float):
    """float in [0, 1]."""

    def __new__(cls, value: float) -> Self:
        assert Interval(0, 1).contains(value)
        return super().__new__(cls, value)


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class Interval:
    lower_bound: float = field(default=float("-inf"))
    upper_bound: float = field(default=float("+inf"))

    def __post_init__(self) -> None:
        assert not self.lower_bound or not math.isnan(self.lower_bound)
        assert not self.upper_bound or not math.isnan(self.upper_bound)
        # @[C.Interval.lower_bound_leq_upper_bound]
        assert (
            not self.lower_bound
            or not self.upper_bound
            or self.lower_bound <= self.upper_bound
        )

    def contains(self, value: float) -> bool:
        """Check if a value is contained within a the interval."""
        return (not self.lower_bound or value >= self.lower_bound) and (
            not self.upper_bound or value <= self.upper_bound
        )

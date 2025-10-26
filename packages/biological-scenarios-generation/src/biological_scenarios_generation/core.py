import math
from dataclasses import dataclass
from typing import Self


@dataclass(frozen=True, eq=False, repr=False)
class Interval:
    """open real interval."""

    lower_bound: float = float("-inf")
    upper_bound: float = float("inf")

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
        return (not self.lower_bound or value > self.lower_bound) and (
            not self.upper_bound or value < self.upper_bound
        )


class IntGEZ(int):
    """int >= 0."""

    def __new__(cls, value: int) -> Self:
        assert value >= 0
        return super().__new__(cls, value)


class IntGTZ(int):
    """int > 0."""

    def __new__(cls, value: int) -> Self:
        assert value > 0
        return super().__new__(cls, value)


# @dataclass
# class BiologicalNumber:
#     id: int
#     properties: str
#     organistm: str
#     value: Interval | float | None
#     units: str
#     keywords: set[str]


# @dataclass(frozen=True)
# class Parameter:
#     parameter: libsbml.Parameter
#
#     @override
#     def __hash__(self) -> int:
#         return self.parameter.getId().__hash__()
#
#     @override
#     def __eq__(self, value: object, /) -> bool:
#         return isinstance(value, Parameter) and self.parameter.getId().__eq__(
#             value.parameter.getId(),
#         )

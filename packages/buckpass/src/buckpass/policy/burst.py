from __future__ import annotations

from typing import TYPE_CHECKING, Generic, TypeVar

from typing_extensions import override

from buckpass.core.policy import Policy

if TYPE_CHECKING:
    from buckpass.core import IntGTZ
    from buckpass.core.submitter import Submitter


Id = TypeVar("Id")
Args = TypeVar("Args")


class BurstPolicy(Policy[None], Generic[Args, Id]):
    def __init__(
        self, args: Args, size: IntGTZ, submitter: Submitter[Args, Id]
    ) -> None:
        super().__init__()

        for _ in range(size):
            _ = submitter.submit(args)

    @override
    def update(self, event: None) -> None: ...

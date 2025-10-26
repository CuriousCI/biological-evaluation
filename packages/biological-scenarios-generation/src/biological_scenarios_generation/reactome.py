import re
from dataclasses import dataclass, field
from enum import Enum
from functools import cache
from typing import TypeAlias

from typing_extensions import override

from biological_scenarios_generation.core import (
    Interval,
    IntGEZ,
    IntGTZ,
)

MathML: TypeAlias = str

MathMLBool: TypeAlias = MathML

StableIdVersion: TypeAlias = str


class ReactomeDbId(IntGEZ):
    """Identifier for objects in Reactome.

    Objects in the Reactome Knowledgebase all have a `dbId` attribute as an
    identifier
    """

    @staticmethod
    def from_stable_id_version(st_id: StableIdVersion) -> "ReactomeDbId":
        """Convert from a StableIdVersion to a basic ReactomeDbId.

        In the "Reactome Pathway Browser" objects are identified with their full
        StableIdVersion, from which the corresponding ReactomeDbId can be found
        """
        match = re.search("R-[A-Z]{3}-([0-9]{1,8})([.][0-9]{1,3})?$", st_id)
        assert match
        return ReactomeDbId(int(match.group()))


class Stoichiometry(IntGTZ):
    """Relationships between the quantities of the reactants in a reaction."""


@dataclass(frozen=True)
class DatabaseObject:
    """The root term of the Reactome data model, parent to all classes of instances."""

    id: ReactomeDbId

    @override
    def __hash__(self) -> int:
        return self.id.__hash__()

    @override
    def __eq__(self, value: object, /) -> bool:
        return isinstance(value, DatabaseObject) and self.id.__eq__(value.id)

    def __int__(self) -> int:
        return self.id

    @override
    def __repr__(self) -> str:
        return f"{self.id}"


class CatalystActivity(DatabaseObject):
    pass


@dataclass(frozen=True, eq=False)
class Compartment(DatabaseObject):
    @override
    def __repr__(self) -> str:
        return f"compartment_{super().__repr__()}"


@dataclass(frozen=True, eq=False)
class PhysicalEntity(DatabaseObject):
    """PhysicalEntity is a physical substance that can interact with other substances.

    PhysicalEntities include all kinds of small molecules, proteins, nucleic
    acids, chemical compounds, complexes, larger macromolecular assemblies, atoms
    (including ionized atoms), electrons, and photons.
    """

    known_range: Interval = Interval()
    compartments: set[Compartment] = field(default_factory=set)

    @override
    def __repr__(self) -> str:
        return f"species_{super().__repr__()}"


class Event(DatabaseObject):
    pass


@dataclass(frozen=True)
class PhysicalEntityReactionLikeEvent:
    class Type(Enum):
        INPUT = 1
        OUTPUT = 2

    physical_entity: PhysicalEntity
    stoichiometry: Stoichiometry
    type: Type

    @override
    def __hash__(self) -> int:
        return self.physical_entity.__hash__()

    @override
    def __eq__(self, value: object, /) -> bool:
        return isinstance(
            value,
            PhysicalEntityReactionLikeEvent,
        ) and self.physical_entity.__eq__(value.physical_entity)

    @override
    def __repr__(self) -> str:
        return f"({self.physical_entity}^{self.stoichiometry})"


@dataclass(frozen=True, eq=False)
class ReactionLikeEvent(Event):
    """Used to organize other concrete reaction types (Reaction, Polymerization and BlackBoxEvent...).

    A molecular process in which one or more input physical entities are transformed
    in a single step into output physical entities, optionally mediated by a catalyst
    activity and subject to regulation
    """

    physical_entities: set[PhysicalEntityReactionLikeEvent]
    enzymes: set[PhysicalEntity] = field(default_factory=set)
    compartments: set[Compartment] = field(default_factory=set)
    is_reversible: bool = False
    is_fast: bool = False
    positive_regulators: set[PhysicalEntity] = field(default_factory=set)
    negative_regulators: set[PhysicalEntity] = field(default_factory=set)

    @cache
    def reactants(self) -> set[PhysicalEntityReactionLikeEvent]:
        return {
            relationship
            for relationship in self.physical_entities
            if relationship.type == PhysicalEntityReactionLikeEvent.Type.INPUT
        }

    @cache
    def products(self) -> set[PhysicalEntityReactionLikeEvent]:
        return self.physical_entities - self.reactants()

    @override
    def __repr__(self) -> str:
        return f"reaction_{super().__repr__()}"


class Pathway(Event):
    pass

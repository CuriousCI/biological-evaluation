import re
from collections.abc import Mapping
from dataclasses import dataclass, field
from enum import StrEnum, auto
from typing import TypeAlias

from typing_extensions import override

from biological_scenarios_generation.core import Interval, IntGEZ, IntGTZ

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


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class DatabaseObject:
    """Parent to all classes of instances in the Reactome Data Model."""

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


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class Compartment(DatabaseObject):
    @override
    def __repr__(self) -> str:
        return f"compartment_{super().__repr__()}"


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class PhysicalEntity(DatabaseObject):
    """PhysicalEntity is a physical substance that can interact with other substances.

    PhysicalEntities include all kinds of small molecules, proteins, nucleic
    acids, chemical compounds, complexes, larger macromolecular assemblies,
    atoms (including ionized atoms), electrons, and photons.
    """

    known_interval: Interval = field(default_factory=Interval)
    compartments: set[Compartment] = field(default_factory=set)

    @override
    def __repr__(self) -> str:
        return f"species_{super().__repr__()}"


class StandardRole(StrEnum):
    INPUT = auto()
    OUTPUT = auto()


class ModifierRole(StrEnum):
    ENZYME = auto()
    POSITIVE_REGULATOR = auto()
    NEGATIVE_REGULATOR = auto()


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class StandardRoleInformation:
    stoichiometry: Stoichiometry
    role: StandardRole


Role: TypeAlias = StandardRoleInformation | ModifierRole


class Event(DatabaseObject):
    pass


class Pathway(Event):
    pass


# POSITIVE_GENE_REGULATOR = auto()
# NEGATIVE_GENE_REGULATOR = auto()

# Role is not enough, I need to know if it's input or not, but it's not related to all reactions, just to model!
# Interesting... I still need to save the info somewhere
# Maybe I should go back to the drawing board for a moment


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class ReactionLikeEvent(Event):
    """Used to organize other concrete reaction types (Reaction, Polymerization, BlackBoxEvent...).

    A molecular process in which one or more input physical entities are
    transformed in a single step into output physical entities, optionally
    mediated by a catalyst activity and subject to regulation
    """

    physical_entities: Mapping[PhysicalEntity, Role]
    compartments: set[Compartment] = field(default_factory=set)
    is_reversible: bool = field(default=False)

    @override
    def __repr__(self) -> str:
        return f"reaction_{super().__repr__()}"

    def modifiers(
        self, modifier_role: ModifierRole | None = None
    ) -> set[tuple[PhysicalEntity, ModifierRole]]:
        return {
            (physical_entity, role)
            for physical_entity, role in self.physical_entities.items()
            if isinstance(role, ModifierRole)
            and (modifier_role is None or role == modifier_role)
        }

    def entities(
        self, standard_role: StandardRole | None = None
    ) -> set[tuple[PhysicalEntity, StandardRoleInformation]]:
        return {
            (physical_entity, role)
            for physical_entity, role in self.physical_entities.items()
            if isinstance(role, StandardRoleInformation)
            and (standard_role is None or role.role == standard_role)
        }

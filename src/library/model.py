"""
model stuff
"""

from dataclasses import dataclass, field
from enum import Enum
import re
from typing import TypeAlias

import libsbml
import neo4j
from libsbml import SBMLDocument


StableIdVersion: TypeAlias = str

MathML: TypeAlias = str


@dataclass(repr=False, eq=False, frozen=True)
class Interval:
    min: float | None
    max: float | None

    def __post_init__(self) -> None:
        """[C.Interval.min_leq_max]"""
        assert not self.min or not self.max or self.min <= self.max


@dataclass(frozen=True)
class Natural:
    value: int

    def __post_init__(self) -> None:
        """Integer >= 0"""
        assert self.value >= 0

    def __hash__(self) -> int:
        return self.value.__hash__()

    def __eq__(self, value: object, /) -> bool:
        return isinstance(value, 'Natural') and self.value.__eq__(value.value)


@dataclass(frozen=True)
class ReactomeDbId(Natural):
    @staticmethod
    def from_stable_id_version(id: StableIdVersion) -> 'ReactomeDbId':
        match = re.search('R-[A-Z]{3}-([0-9]{1,8})[.][0-9]{1,3}$', str(id))
        assert match
        return ReactomeDbId(int(match.group()))


class Stoichiometry(Natural):
    pass


@dataclass(frozen=True)
class DatabaseObject:
    id: ReactomeDbId

    def __hash__(self) -> int:
        return self.id.__hash__()

    def __eq__(self, value: object, /) -> bool:
        return isinstance(value, 'DatabaseObject') and self.id.__eq__(value.id)


class CatalystActivity(DatabaseObject):
    pass


class Compartment(DatabaseObject):
    pass


@dataclass(frozen=True)
class PhysicalEntity(DatabaseObject):
    known_range: Interval = Interval(None, None)
    compartments: set[Compartment] = field(default_factory=set)

    def __hash__(self) -> int:
        return super().__hash__()

    def __eq__(self, value: object, /) -> bool:
        return super().__eq__(value)


class Event(DatabaseObject):
    pass


@dataclass(frozen=True)
class EntityReaction:
    class Type(Enum):
        INPUT = 1
        OUTPUT = 2

    physical_entity: PhysicalEntity
    order: Natural
    stoichiometry: Stoichiometry | None
    type: Type

    def __hash__(self) -> int:
        return self.physical_entity.__hash__()

    def __eq__(self, value: object, /) -> bool:
        return isinstance(value, 'EntityReaction') and self.physical_entity.__eq__(
            value.physical_entity
        )


@dataclass(frozen=True)
class ReactionLikeEvent(Event):
    reactants: set[EntityReaction]
    catalysts: set[PhysicalEntity] = field(default_factory=set)
    compartments: set[Compartment] = field(default_factory=set)
    is_reversible: bool = False
    is_fast: bool = False


class Pathway(Event):
    pass


# TODO: parameterId instead of str
@dataclass(frozen=True)
class Environment:
    parameters: set[str]


@dataclass(repr=False, eq=False, frozen=True)
class BiologicalSituationDefinition:
    target_entities: set[PhysicalEntity]
    target_pathways: set[Pathway] | None
    constraints: list[MathML]

    def __post_init__(self) -> None:
        assert not self.target_pathways or len(self.target_pathways) > 0

    @staticmethod
    def from_sbml(sbml: SBMLDocument) -> 'BiologicalSituationDefinition':
        model: libsbml.Model = sbml.getModel()
        model.getSpecies()
        return BiologicalSituationDefinition(set(), None, [])

    # set[DatabaseObject
    def __model_objects(self, driver: neo4j.Driver) -> set[DatabaseObject]:
        try:
            # with driver.session() as session:
            # with session.begin_transaction() as transaction:
            #     transaction.run()
            # session.execute_write

            # TODO: transaction
            # with driver.session() as session:
            #     pass
            # try:
            # print(res)
            # except Exception as e:
            #     print(e)
            # print('test')

            _ = driver.execute_query(
                """
                MATCH (physicalEntity:PhysicalEntity)<-[:input]-(reactionLikeEvent:ReactionLikeEvent)
                MERGE (reactionLikeEvent)<-[:fixedPoint]-(physicalEntity);
                """
            )

            _ = driver.execute_query(
                """
                MATCH (physicalEntity:PhysicalEntity)<-[:output]-(reactionLikeEvent:ReactionLikeEvent)
                MERGE (physicalEntity)<-[:fixedPoint]-(reactionLikeEvent);
                """
            )

            _ = driver.execute_query(
                """
                MATCH (reactionLikeEvent:ReactionLikeEvent)-->(:CatalystActivity)-[:physicalEntity]->(physicalEntity:PhysicalEntity)
                MERGE (reactionLikeEvent)<-[:fixedPoint]-(physicalEntity);
                """
            )

            if self.target_pathways:
                _ = driver.execute_query(
                    """
                    MATCH (targetPathway:Pathway)
                    WHERE targetPathway.dbId IN $target_pathways
                    CALL
                        apoc.path.subgraphNodes(
                            targetPathway,
                            {
                                relationshipFilter: "hasEvent>",
                                labelFilter: ">ReactionLikeEvent",
                                bfs: true
                            }
                        )
                    YIELD node AS reactionLikeEvent
                    SET reactionLikeEvent:TargetReactionLikeEvent
                    """,
                    target_pathways=list(
                        map(lambda pathway: pathway.id.value, self.target_pathways)
                    ),
                )
            else:
                _ = driver.execute_query(
                    """
                    MATCH (reactionLikeEvent:ReactionLikeEvent)
                    SET reactionLikeEvent:TargetReactionLikeEvent;
                    """
                )

            records, _, _ = driver.execute_query(
                """
                MATCH (targetEntity)
                WHERE targetEntity.dbId IN $target_entities
                CALL
                    apoc.path.subgraphNodes(
                        targetEntity,
                        {
                            relationshipFilter: "<fixedPoint",
                            labelFilter: ">TargetReactionLikeEvent",
                            bfs: true,
                            maxLevel: 2
                        }
                    )
                YIELD node AS reaction
                CALL {
                    WITH reaction
                    MATCH 
                        (reaction)-[:input|output|catalyst]-(physicalEntity:PhysicalEntity),
                        (physicalEntity)-[:compartment]-(compartment:Compartment)

                }
                CALL {
                    WITH reaction
                    MATCH (reaction)-[r:input]->(e)
                    RETURN
                        COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS reactants
                }
                CALL {
                    WITH reaction
                    MATCH (reaction)-[r:output]->(e)
                    RETURN
                        COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS products
                }
                CALL {
                    WITH reaction
                    MATCH (reaction)-->(:CatalystActivity)-[:physicalEntity]->(e)
                    RETURN COLLECT({dbId: e.dbId})
                }
                RETURN COLLECT({reaction: reaction.dbId, reactants: reactants, products: products}) AS reactions;
                """,
                # RETURN apoc.convert.toJson(COLLECT({reaction: reaction.dbId, reactants: reactants, products: products})) AS reactions;
                # target_entities=list(self.target_entities),
                target_entities=list(map(lambda e: e.id.value, self.target_entities)),
            )

            print([record.keys() for record in records])

            print(records)

            _ = driver.execute_query(
                """
                MATCH (targetReactionLikeEvent:TargetReactionLikeEvent)
                REMOVE targetReactionLikeEvent:TargetReactionLikeEvent;
                """
            )
        except Exception as e:
            print(e)

        # TODO:
        # - NewUnitDefinitions
        # - CompartmentDefinition (for each PhysicalEntity)
        # - SpeciesDefinition (one per PhysicalEntity)
        # - ReactionDefinition (+ stuff it needs!)
        # -----------------
        # - Parameter
        # - Constraint

        return set()

    def yield_sbml_model(
        self, driver: neo4j.Driver
    ) -> tuple[SBMLDocument, Environment]:
        objects = self.__model_objects(driver)
        return (SBMLDocument(), Environment(set()))


# @staticmethod
# def from_json(json: Any) -> 'BiologicalSituationDefinition':
#     return BiologicalSituationDefinition(
#         set(json['target_entities']),
#         json['target_pathways'] if 'target_pathways' in json else None,
#         [],
#     )


# from libsbml import Math
#     def __hash__(self) -> int:
#         return self.standard_id.__hash__()
#
#     def __eq__(self, value: object, /) -> bool:
#         return 'standard_id' in value.__dict__ and self.standard_id.__eq__(
#             value.__dict__['standard_id']
#         )
#
#     def __repr__(self) -> str:
#         return f'{self.standard_id}'

# def __init__(
#     self,
# ) -> None:
#     pass


# Biological
# Model
# Definition
# class BiologicalModelDefinition:
#     pass


# class Model:
#     pass


# # [SBML 3.2.2 | ch. 3.1.7]
# class StandardId(UserString):
#     """Class docstrings go here."""
#
#     def __init__(self, value) -> None:
#         """Method docstrings go here."""
#         # a..z A..Z
#         # 0..9
#         # (letter | _) 'a..z A..Z 0..9' *
#         super().__init__(value.replace('-', '_'))
#
#
# PhysicalEntityStandardId: TypeAlias = StandardId
#
#
# class RationalGT0(float):
#     def __init__(self, value) -> None:
#         if value <= 0:
#             raise TypeError('Only reals > 0 allowed')
#         float.__init__(value)


# @dataclass(repr=False, eq=False, frozen=True)
# class PhysicalEntity:
#     standard_id: StandardId
#     display_name: str
#
#     def __hash__(self) -> int:
#         return self.standard_id.__hash__()
#
#     def __eq__(self, value: object, /) -> bool:
#         return 'standard_id' in value.__dict__ and self.standard_id.__eq__(
#             value.__dict__['standard_id']
#         )
#
#     def __repr__(self) -> str:
#         return f'{self.standard_id}'


# class PhysicalEntityInReaction(PhysicalEntity):
#     def __init__(
#         self, standard_id: StandardId, display_name: str, stoichiometry: RationalGT0
#     ) -> None:
#         super().__init__(standard_id, display_name)
#         self.stoichiometry = stoichiometry


# Reactant: TypeAlias = PhysicalEntityInReaction
# ReactionProduct: TypeAlias = PhysicalEntityInReaction


# class ReactionLikeEvent:
#     def __init__(
#         self, reactants: set[Reactant], products: set[ReactionProduct]
#     ) -> None:
#         self.reactants = reactants
#         self.products = products
# SBMLDocumentString: TypeAlias = str

# assert False, 'unreachable'


# class StableIdVersion(int):
#     pass
# database_id: ReactomeDbId

# def __init__(self, seq: str) -> None:
#     if not re.compile('^R-[A-Z]{3}-[0-9]{1,8}[.][0-9]{1,3}$').match(seq):
#         raise Exception()
#
#     super().__init__(seq)
#
# def to_database_id(self) -> ReactomeDbId:
#     match = re.search('R-[A-Z]{3}-([0-9]{1,8})[.][0-9]{1,3}$', str(self))
#     if match is not None:
#         return ReactomeDbId(match.group())
#
#     assert False, 'unreachable'
#


# class StableIdVersion(UserString):
#     def __init__(self, seq: str) -> None:
#         if not re.compile('^R-[A-Z]{3}-[0-9]{1,8}[.][0-9]{1,3}$').match(seq):
#             raise Exception()
#
#         super().__init__(seq)
#
#     def to_database_id(self) -> ReactomeDbId:
#         match = re.search('R-[A-Z]{3}-([0-9]{1,8})[.][0-9]{1,3}$', str(self))
#         if match is not None:
#             return ReactomeDbId(match.group())
#
#         assert False, 'unreachable'


# def __init__(self, id: ReactomeDbId | StableIdVersion) -> None:
#     # self.database_id = id
#     pass

# class SimpleDatabaseObject(DatabaseObject):
#     database_id: ReactomeDbId


# @dataclass(repr=False, eq=False, frozen=True)
# class DatabaseObjectWithStableId(DatabaseObject):
#     stable_id: StableIdVersion | None = None
#
#     def __post_init__(self) -> None:
#         """[C.DatabaseObjectWithStableId.either_database_id_or_stable_id_is_defined]"""
#         if self.database_id is None and self.stable_id is None:
#             raise Exception()
#
#     def __hash__(self) -> int:
#         if self.database_id is not None:
#             return self.database_id.__hash__()
#         elif self.stable_id is not None:
#             return self.stable_id.to_database_id().__hash__()
#
#         assert False, 'unreachable'
#
#         # return (
#         #     self.database_id.__hash__()
#         #     if self.database_id is not None
#         #     else  self.stable_id.to_database_id().__hash__()
#         # )
#
#     def __eq__(self, value: object, /) -> bool:
#         return 'database_id' in value.__dict__ and self.database_id.__eq__(
#             value.__dict__['database_id']
#         )


# match id:
#     case int():
#         return ReactomeDbId(id)
#     case _:

# if match is None:
#     return None


# class StableIdVersion(UserString):
#     def __init__(self, seq: str) -> None:
#         if not re.compile('^R-[A-Z]{3}-[0-9]{1,8}[.][0-9]{1,3}$').match(seq):
#             raise Exception()
#
#         super().__init__(seq)
#
#     def to_database_id(self) -> ReactomeDbId:
#         match = re.search('R-[A-Z]{3}-([0-9]{1,8})[.][0-9]{1,3}$', str(self))
#         if match is not None:
#             return ReactomeDbId(match.group())
#
#         assert False, 'unreachable'


# def into_reactome_id(id: StableIdVersion) -> ReactomeDbId:
#     match = re.search('R-[A-Z]{3}-([0-9]{1,8})[.][0-9]{1,3}$', str(id))
#     assert match is not None
#     return ReactomeDbId(match.group())

# ReactomeDbId: TypeAlias = int

# val: int
#
# def __post_init__(self) -> None:
#     """ReactomeDbId = Integer >= 0"""
#     assert self.val >= 0


# @dataclass(frozen=True)
# val: int
#
# def __post_init__(self) -> None:
#     """Stoichiometry = Integer >= 0"""
#     assert self.val >= 0

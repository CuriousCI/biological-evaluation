"""
model stuff
"""

import re
import random
from dataclasses import dataclass, field
from enum import Enum
from functools import reduce
from operator import attrgetter
from typing import TypeAlias

import libsbml
import neo4j
from libsbml import SBMLDocument

FIRST = 0

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
        assert int(self) >= 0

    def __int__(self) -> int:
        return self.value


# TODO: treat Natural as an int
# return super().__int__()
# def __new__(cls, value):
#     return int.__new__(cls, int(value))
# def __init__(self, value) -> None:
#     super().__init__()


@dataclass(frozen=True)
class ReactomeDbId(Natural):
    @staticmethod
    def from_stable_id_version(id: StableIdVersion) -> 'ReactomeDbId':
        match = re.search('R-[A-Z]{3}-([0-9]{1,8})[.][0-9]{1,3}$', str(id))
        assert match
        return ReactomeDbId(int(match.group()))


class Stoichiometry(Natural):
    def __int__(self) -> int:
        return super().__int__()


@dataclass(frozen=True)
class DatabaseObject:
    id: ReactomeDbId

    def __hash__(self) -> int:
        return self.id.__hash__()

    def __eq__(self, value: object, /) -> bool:
        return isinstance(value, DatabaseObject) and self.id.__eq__(value.id)


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
        return isinstance(value, EntityReaction) and self.physical_entity.__eq__(
            value.physical_entity
        )


@dataclass(frozen=True)
class ReactionLikeEvent(Event):
    reactants: set[EntityReaction]
    catalysts: set[PhysicalEntity] = field(default_factory=set)
    compartments: set[Compartment] = field(default_factory=set)
    is_reversible: bool = False
    is_fast: bool = False

    def __hash__(self) -> int:
        return super().__hash__()

    def __eq__(self, value: object, /) -> bool:
        return super().__eq__(value)

    # def __


class Pathway(Event):
    pass


# TODO: parameterId instead of str
@dataclass(frozen=True)
class Environment:
    parameters: set[str]


# @dataclass(frozen=True)
# class BiologicalModel:
#     reaction_like_events: set[ReactionLikeEvent]
#     physical_entities: set[PhysicalEntity]
#     compartments: set[Compartment]


@dataclass(frozen=True)
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

    def __model_objects(
        self, driver: neo4j.Driver
    ) -> set[PhysicalEntity | ReactionLikeEvent | Compartment]:
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

        # TODO: not a Drug!
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
                target_pathways=list(map(lambda p: int(p.id), self.target_pathways)),
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
                        bfs: true
                    }
                )
            YIELD node AS reactionLikeEvent
            CALL {
                WITH reactionLikeEvent
                MATCH (reactionLikeEvent)-[r:input]->(e)
                CALL {
                    WITH e
                    MATCH (e)-[:compartment]-(compartment:Compartment)
                    RETURN COLLECT({ dbId: compartment.dbId }) as compartments
                }
                RETURN
                    COLLECT({
                        dbId: e.dbId,
                        stoichiometry: r.stoichiometry,
                        order: r.order,
                        compartments: compartments
                    }) AS reactants
            }
            CALL {
                WITH reactionLikeEvent
                MATCH (reactionLikeEvent)-[r:output]->(e)
                CALL {
                    WITH e
                    MATCH (e)-[:compartment]-(compartment:Compartment)
                    RETURN COLLECT({ dbId: compartment.dbId }) as compartments
                }
                RETURN
                    COLLECT({
                        dbId: e.dbId, 
                        stoichiometry: r.stoichiometry, 
                        order: r.order,
                        compartments: compartments
                    }) AS products
            }
            CALL {
                WITH reactionLikeEvent
                MATCH (reactionLikeEvent)-->(:CatalystActivity)-[:physicalEntity]->(e)
                RETURN COLLECT({ dbId: e.dbId }) AS catalysts
            }
            CALL {
                WITH reactionLikeEvent
                MATCH (reactionLikeEvent)-[:compartment]-(compartment:Compartment)
                RETURN COLLECT({ dbId: compartment.dbId }) AS compartments
            }
            RETURN COLLECT({
                dbId: reactionLikeEvent.dbId, 
                reactants: reactants, 
                products: products, 
                catalysts: catalysts, 
                compartments: compartments
            }) AS reactions;
            """,
            target_entities=list(map(lambda e: int(e.id), self.target_entities)),
        )

        val = records[FIRST][FIRST]
        reaction_like_events: set[ReactionLikeEvent] = set(
            map(
                lambda reaction: ReactionLikeEvent(
                    id=reaction['dbId'],
                    reactants=set(
                        map(
                            lambda entity: EntityReaction(
                                physical_entity=PhysicalEntity(
                                    ReactomeDbId(entity['dbId']),
                                    compartments=set(
                                        map(
                                            lambda c: Compartment(
                                                ReactomeDbId(c['dbId'])
                                            ),
                                            entity['compartments'],
                                        )
                                    ),
                                ),
                                stoichiometry=Stoichiometry(entity['stoichiometry']),
                                order=Natural(entity['order']),
                                type=EntityReaction.Type.INPUT,
                            ),
                            reaction['products'],
                        )
                    )
                    | set(
                        map(
                            lambda entity: EntityReaction(
                                physical_entity=PhysicalEntity(
                                    ReactomeDbId(entity['dbId'])
                                ),
                                stoichiometry=Stoichiometry(entity['stoichiometry']),
                                order=Natural(entity['order']),
                                type=EntityReaction.Type.OUTPUT,
                            ),
                            reaction['reactants'],
                        )
                    ),
                    catalysts=set(
                        map(
                            lambda entity: PhysicalEntity(ReactomeDbId(entity['dbId'])),
                            reaction['catalysts'],
                        )
                    ),
                    compartments=set(
                        map(
                            lambda entity: Compartment(ReactomeDbId(entity['dbId'])),
                            reaction['compartments'],
                        )
                    ),
                ),
                val,
            ),
        )

        physical_entities: set[PhysicalEntity] = reduce(
            set.union,
            map(
                lambda reaction_like_event: reaction_like_event.catalysts
                | set(
                    map(attrgetter('physical_entity'), reaction_like_event.reactants)
                ),
                reaction_like_events,
            ),
            set(),
        )

        # print(list(map(vars, physical_entities)))

        reaction_like_events_compartmensts = reduce(
            set.union, map(attrgetter('compartments'), reaction_like_events), set()
        )

        physical_entities_compartments = reduce(
            set.union, map(attrgetter('compartments'), physical_entities), set()
        )

        compartments: set[Compartment] = (
            reaction_like_events_compartmensts | physical_entities_compartments
        )

        _ = driver.execute_query(
            """
            MATCH (targetReactionLikeEvent:TargetReactionLikeEvent)
            REMOVE targetReactionLikeEvent:TargetReactionLikeEvent;
            """
        )

        return physical_entities | reaction_like_events | compartments

    def yield_sbml_model(
        self, driver: neo4j.Driver
    ) -> tuple[SBMLDocument, Environment]:
        objects = self.__model_objects(driver)

        sbml_document: libsbml.SBMLDocument = SBMLDocument(3, 1)
        sbml_model: libsbml.Model = sbml_document.createModel()
        sbml_model.setTimeUnits('second')
        sbml_model.setExtentUnits('mole')
        sbml_model.setSubstanceUnits('mole')

        default_compartment: libsbml.Compartment = sbml_model.createCompartment()
        default_compartment.setId('cd')
        default_compartment.setConstant(True)
        default_compartment.setSize(1)
        default_compartment.setSpatialDimensions(3)
        default_compartment.setUnits('litre')

        # TODO: __repr__ for compartments etc... just to make it easier to display, maybe with handling of the default?
        # TODO: there are too many 'cd's
        for obj in objects:
            match obj:
                case PhysicalEntity():
                    species: libsbml.Species = sbml_model.createSpecies()
                    species.setId(f's{obj.id}')
                    species_compartment = (
                        int(list(obj.compartments)[0].id)
                        if len(list(obj.compartments)) > 0
                        else 'd'
                    )
                    species.setCompartment(f'c{species_compartment}')
                    species.setConstant(False)
                    species.setInitialAmount(random.randint(5, 100))
                    species.setSubstanceUnits('mole')
                    species.setBoundaryCondition(False)
                    species.setHasOnlySubstanceUnits(False)
                case Compartment():
                    compartment: libsbml.Compartment = sbml_model.createCompartment()
                    compartment.setId(f'c{int(obj.id)}')
                    # print(f'c{obj.id}')
                    compartment.setConstant(True)
                    compartment.setSize(1)
                    compartment.setSpatialDimensions(3)
                    compartment.setUnits('litre')
                case ReactionLikeEvent():
                    reaction: libsbml.Reaction = sbml_model.createReaction()
                    reaction.setId(f'r{obj.id}')
                    reaction.setReversible(obj.is_reversible)
                    reaction.setFast(obj.is_fast)

                    for entity in obj.reactants:
                        species_ref: libsbml.SpeciesReference

                        match entity.type:
                            case EntityReaction.Type.INPUT:
                                species_ref = sbml_model.createReactant()
                            case EntityReaction.Type.OUTPUT:
                                species_ref = sbml_model.createProduct()

                        species_ref.setSpecies(f's{entity.physical_entity.id}')
                        species_ref.setConstant(False)
                        species_ref.setStoichiometry(int(entity.stoichiometry or 0))

                    kinetic_law: libsbml.KineticLaw = reaction.createKineticLaw()
                    kinetic_law.setMath(libsbml.parseL3Formula(''))

        return (sbml_document, Environment(set()))

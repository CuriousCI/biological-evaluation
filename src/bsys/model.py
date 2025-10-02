""""""

import math
import random
import re
from collections.abc import Callable
from dataclasses import dataclass, field
from enum import Enum
from functools import cache, reduce
from operator import attrgetter
from typing import override

import libsbml
import neo4j

FIRST = 0

type StableIdVersion = str

type MathML = str

type MathMLBool = MathML


@dataclass(frozen=True, eq=False, repr=False)
class Interval:
    """Open real interval."""

    lower_bound: float = float("-inf")
    upper_bound: float = float("inf")

    def __post_init__(self) -> None:
        assert not self.lower_bound or not math.isnan(self.lower_bound)
        assert not self.upper_bound or not math.isnan(self.upper_bound)
        # TODO: [C.Interval.lower_bound_leq_upper_bound]
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


@dataclass(frozen=True, eq=False, repr=False)
class Natural:
    """Natural number n such that n >= 0."""

    value: int

    def __post_init__(self) -> None:
        assert self.value >= 0

    def __int__(self) -> int:
        return self.value

    @override
    def __repr__(self) -> str:
        return self.value.__repr__()


@dataclass
class BiologicalNumber:
    id: int
    properties: str
    organistm: str
    value: Interval | float | None
    units: str
    keywords: set[str]


class NonZeroNatural(Natural):
    """Natural number n such that n > 0."""

    def __post_init__(self) -> None:
        assert self.value > 0


class ReactomeDbId(Natural):
    """Identifier for objects in Reactome.

    Objects in the Reactome Knowledgebase all have a `dbId` attribute as an
    identifier
    """

    @staticmethod
    def from_stable_id_version(full_id: StableIdVersion) -> "ReactomeDbId":
        """Convert from a StableIdVersion to a basic ReactomeDbId.

        In the "Reactome Pathway Browser" objects are identified with their full
        StableIdVersion, from which the corresponding ReactomeDbId can be extracted
        """
        match = re.search("R-[A-Z]{3}-([0-9]{1,8})[.][0-9]{1,3}$", full_id)
        assert match
        return ReactomeDbId(int(match.group()))

    @override
    def __hash__(self) -> int:
        return self.value.__hash__()

    @override
    def __eq__(self, value: object, /) -> bool:
        return isinstance(value, ReactomeDbId) and self.value.__eq__(
            value.value
        )


class Stoichiometry(NonZeroNatural):
    """Stoichiometry is the relationships between the quantities of reactants."""


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
        return self.id.value

    @override
    def __repr__(self) -> str:
        return f"{self.id}"


class CatalystActivity(DatabaseObject):
    pass


@dataclass(frozen=True, eq=False)
class Compartment(DatabaseObject):
    display_name: str

    @override
    def __repr__(self) -> str:
        return f"compartment_{super().__repr__()}"


# @override
# def __hash__(self) -> int:
#     return super().__hash__()
#
# @override
# def __eq__(self, value: object, /) -> bool:
#     return super().__eq__(value)


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
    physical_entities: set[PhysicalEntityReactionLikeEvent]
    enzymes: set[PhysicalEntity] = field(default_factory=set)
    compartments: set[Compartment] = field(default_factory=set)
    is_reversible: bool = False
    is_fast: bool = False

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


type SId = str

type VirtualPatient = dict[SId, float]


@dataclass(frozen=True)
class VirtualPatientDetails:
    """A virtual patient is described by the set of parameters."""

    # TODO: set()
    parameters: list[libsbml.Parameter]

    def __call__(self) -> VirtualPatient:
        virtual_patient = {}

        for parameter in self.parameters:
            # value = random.uniform(10e-6, 10e6)
            value = random.uniform(0.01, 0.1)
            virtual_patient[parameter.getId()] = value
            parameter.setValue(value)

        return virtual_patient

    # species: set[Parameter]


@dataclass(frozen=True)
class Environment:
    """An environment dictates the initial conditions of the simulation (initial amounts of the species)."""

    physical_entities: set[PhysicalEntity]


class BaseKineticLaw(Enum):
    """Well known kinetic laws."""

    LAW_OF_MASS_ACTION = 1
    CONVENIENCE_KINETIC_LAW = 2

    def __call__(
        self,
        sbml_model: libsbml.Model,
        reaction_like_event: ReactionLikeEvent,
    ) -> tuple[MathML, list[libsbml.Parameter]]:
        """Return reaction law and generate parameters."""
        parameters = []

        match self:
            case BaseKineticLaw.LAW_OF_MASS_ACTION:
                forward_parameter: libsbml.Parameter = (
                    sbml_model.createParameter()
                )
                forward_parameter.setId(f"k_forward_{reaction_like_event}")
                forward_parameter.setConstant(True)
                forward_parameter.setValue(1.0)
                parameters.append(forward_parameter)

                if reaction_like_event.is_fast:
                    pass

                reverse_reaction_formula: str | None = None
                if reaction_like_event.is_reversible:
                    reverse_parameter: libsbml.Parameter = (
                        sbml_model.createParameter()
                    )
                    reverse_parameter.setId(
                        f"k_reverse_{reaction_like_event}",
                    )
                    reverse_parameter.setConstant(True)
                    reverse_parameter.setValue(1.0)
                    parameters.append(reverse_parameter)

                    reverse_reaction_formula = f"(k_reverse_{reaction_like_event} * {'*'.join(map(repr, reaction_like_event.products()))})"

                hill_component: str | None = None
                if reaction_like_event.enzymes:
                    # if(sbo == SBO_ACTIVATOR || sbo == SBO_ENZYME || sbo == SBO_STIMULATOR) positive
                    # elif (sbo == SBO_INHIBITOR) negative
                    # h = 10
                    hill_component = "1"

                reaction_formula = f"(k_forward_{reaction_like_event} * {'*'.join(map(repr, reaction_like_event.reactants()))})"

                formula = f"{reaction_formula}"

                if reverse_reaction_formula:
                    formula = f"{formula} - {reverse_reaction_formula}"

                if hill_component:
                    formula = f"{hill_component} * {formula}"

                return (formula, parameters)
            case BaseKineticLaw.CONVENIENCE_KINETIC_LAW:
                return ("", [])


type CustomKineticLaw = Callable[
    [libsbml.Model, ReactionLikeEvent],
    tuple[MathML, list[libsbml.Parameter]],
]

type KineticLaw = BaseKineticLaw | CustomKineticLaw


@dataclass(frozen=True)
class BiologicalScenarioDefinition:
    """Definition of a target scenario to expand for simulations."""

    target_physical_entities: set[PhysicalEntity]
    target_pathways: set[Pathway] | None
    constraints: list[MathMLBool]
    max_depth: NonZeroNatural | None = None
    excluded_physical_entities: set[PhysicalEntity] = field(default_factory=set)
    default_kinetic_law: KineticLaw = BaseKineticLaw.LAW_OF_MASS_ACTION
    kinetic_laws: dict[ReactionLikeEvent, KineticLaw] = field(
        default_factory=dict,
    )

    def __post_init__(self) -> None:
        assert len(self.target_physical_entities) > 0
        assert not self.target_pathways or len(self.target_pathways) > 0

    @staticmethod
    def from_sbml(sbml: libsbml.SBMLDocument) -> "BiologicalScenarioDefinition":
        # model: libsbml.Model = sbml.getModel()
        # model.getSpecies()
        return BiologicalScenarioDefinition(set(), None, [])

    def __model_objects(
        self,
        driver: neo4j.Driver,
    ) -> set[PhysicalEntity | ReactionLikeEvent | Compartment]:
        _ = driver.execute_query(
            """
            MATCH (physicalEntity:PhysicalEntity)<-[:input]-(reactionLikeEvent:ReactionLikeEvent)
            MERGE (reactionLikeEvent)<-[:fixedPoint]-(physicalEntity);
            """,
        )

        # TODO: relOfInterest

        _ = driver.execute_query(
            """
            MATCH (physicalEntity:PhysicalEntity)<-[:output]-(reactionLikeEvent:ReactionLikeEvent)
            MERGE (physicalEntity)<-[:fixedPoint]-(reactionLikeEvent);
            """,
        )

        _ = driver.execute_query(
            """
            MATCH (reactionLikeEvent:ReactionLikeEvent)-->(:CatalystActivity)-[:physicalEntity]->(physicalEntity:PhysicalEntity)
            MERGE (reactionLikeEvent)<-[:fixedPoint]-(physicalEntity);
            """,
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
                WHERE reactionLikeEvent.speciesName = 'Homo sapiens'
                SET reactionLikeEvent:TargetReactionLikeEvent
                """,
                target_pathways=list(map(int, self.target_pathways)),
            )
            # TODO: ReactionOfInterest
        else:
            _ = driver.execute_query(
                """
                MATCH (reactionLikeEvent:ReactionLikeEvent)
                SET reactionLikeEvent:TargetReactionLikeEvent;
                """,
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
                        maxLevel: 3
                    }
                )
            YIELD node AS reactionLikeEvent
            CALL {
                WITH reactionLikeEvent
                MATCH (reactionLikeEvent)-[r:input]->(e)
                CALL {
                    WITH e
                    MATCH (e)-[:compartment]-(compartment:Compartment)
                    RETURN COLLECT({
                        id: compartment.dbId,
                        display_name: compartment.displayName
                    }) as compartments
                }
                RETURN
                    COLLECT({
                        id: e.dbId,
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
                    RETURN COLLECT({
                        id: compartment.dbId,
                        display_name: compartment.displayName
                    }) as compartments
                }
                RETURN
                    COLLECT({
                        id: e.dbId,
                        stoichiometry: r.stoichiometry,
                        order: r.order,
                        compartments: compartments
                    }) AS products
            }
            CALL {
                WITH reactionLikeEvent
                MATCH (reactionLikeEvent)-->(:CatalystActivity)-[:physicalEntity]->(e)
                CALL {
                    WITH e
                    MATCH (e)-[:compartment]-(compartment:Compartment)
                    RETURN COLLECT({
                        id: compartment.dbId,
                        display_name: compartment.displayName
                    }) as compartments
                }
                RETURN COLLECT({
                    id: e.dbId,
                    compartments: compartments
                }) AS enzymes
            }
            CALL {
                WITH reactionLikeEvent
                MATCH (reactionLikeEvent)-[:compartment]-(compartment:Compartment)
                RETURN COLLECT({
                    id: compartment.dbId,
                    display_name: compartment.displayName
                }) AS compartments
            }
            CALL {
                WITH reactionLikeEvent
                OPTIONAL MATCH (reactionLikeEvent)-[:reverseReaction]->(reverseReactionLikeEvent)
                RETURN reverseReactionLikeEvent
            }
            RETURN COLLECT({
                id: reactionLikeEvent.dbId,
                reactants: reactants,
                products: products,
                enzymes: enzymes,
                compartments: compartments,
                is_reversible: reverseReactionLikeEvent
            }) AS reactions;
            """,
            target_entities=list(map(int, self.target_physical_entities)),
        )

        val = records[FIRST][FIRST]
        reaction_like_events: set[ReactionLikeEvent] = {
            ReactionLikeEvent(
                id=reaction["id"],
                physical_entities={
                    PhysicalEntityReactionLikeEvent(
                        physical_entity=PhysicalEntity(
                            ReactomeDbId(entity["id"]),
                            compartments={
                                Compartment(
                                    ReactomeDbId(
                                        compartment["id"],
                                    ),
                                    compartment["display_name"],
                                )
                                for compartment in entity["compartments"]
                            },
                        ),
                        stoichiometry=Stoichiometry(
                            entity["stoichiometry"],
                        ),
                        # order=Natural(entity["order"]),
                        type=PhysicalEntityReactionLikeEvent.Type.INPUT,
                    )
                    for entity in reaction["products"]
                }
                | {
                    PhysicalEntityReactionLikeEvent(
                        physical_entity=PhysicalEntity(
                            ReactomeDbId(entity["id"]),
                        ),
                        stoichiometry=Stoichiometry(
                            entity["stoichiometry"],
                        ),
                        # order=Natural(entity["order"]),
                        type=PhysicalEntityReactionLikeEvent.Type.OUTPUT,
                    )
                    for entity in reaction["reactants"]
                },
                enzymes={
                    PhysicalEntity(
                        ReactomeDbId(entity["id"]),
                        compartments={
                            Compartment(
                                ReactomeDbId(entity["id"]),
                                entity["display_name"],
                            )
                            for entity in reaction["compartments"]
                        },
                    )
                    for entity in reaction["enzymes"]
                },
                compartments={
                    Compartment(
                        ReactomeDbId(entity["id"]), entity["display_name"]
                    )
                    for entity in reaction["compartments"]
                },
                is_reversible=bool(reaction["is_reversible"]),
            )
            for reaction in val
        }

        physical_entities: set[PhysicalEntity] = reduce(
            set.union,
            (
                reaction_like_event.enzymes
                | set(
                    map(
                        attrgetter("physical_entity"),
                        reaction_like_event.physical_entities,
                    ),
                )
                for reaction_like_event in reaction_like_events
            ),
            set(),
        )

        reaction_like_events_compartmensts = reduce(
            set.union,
            map(attrgetter("compartments"), reaction_like_events),
            set(),
        )

        physical_entities_compartments = reduce(
            set.union,
            map(attrgetter("compartments"), physical_entities),
            set(),
        )

        compartments: set[Compartment] = (
            reaction_like_events_compartmensts | physical_entities_compartments
        )

        _ = driver.execute_query(
            """
            MATCH (targetReactionLikeEvent:TargetReactionLikeEvent)
            REMOVE targetReactionLikeEvent:TargetReactionLikeEvent;
            """,
        )

        return physical_entities | reaction_like_events | compartments

    def yield_sbml_model(
        self,
        driver: neo4j.Driver,
    ) -> tuple[libsbml.SBMLDocument, VirtualPatientDetails, Environment]:
        """Produce a model by enriching the described BiologicalScenarioDefinition with external databases."""
        sbml_document: libsbml.SBMLDocument = libsbml.SBMLDocument(3, 1)

        sbml_model: libsbml.Model = sbml_document.createModel()
        sbml_model.setTimeUnits("second")
        sbml_model.setExtentUnits("mole")
        sbml_model.setSubstanceUnits("mole")

        default_compartment: libsbml.Compartment = (
            sbml_model.createCompartment()
        )
        default_compartment.setId("default_compartment")
        default_compartment.setConstant(True)
        default_compartment.setSize(1)
        default_compartment.setSpatialDimensions(3)
        default_compartment.setUnits("litre")

        virtual_patient_details: list[libsbml.Parameter] = []
        env_physical_entities: set[PhysicalEntity] = set()

        for obj in self.__model_objects(driver):
            match obj:
                case Compartment():
                    compartment: libsbml.Compartment = (
                        sbml_model.createCompartment()
                    )
                    compartment.setId(repr(obj))
                    compartment.setConstant(True)
                    compartment.setSize(1)
                    compartment.setSpatialDimensions(3)
                    compartment.setUnits("litre")
                    compartment.appendNotes(
                        f'<body xmlns="http://www.w3.org/1999/xhtml"><p>{obj.display_name}</p></body>',
                    )
                case PhysicalEntity():
                    species: libsbml.Species = sbml_model.createSpecies()
                    species.setId(repr(obj))
                    species_compartment = (
                        repr(next(iter(obj.compartments)))
                        if len(list(obj.compartments)) > 0
                        else "default_compartment"
                    )
                    species.setCompartment(species_compartment)
                    species.setConstant(False)
                    species.setSubstanceUnits("mole")
                    species.setBoundaryCondition(False)
                    species.setHasOnlySubstanceUnits(False)
                    env_physical_entities.add(obj)
                case ReactionLikeEvent():
                    reaction: libsbml.Reaction = sbml_model.createReaction()
                    reaction.setId(repr(obj))
                    reaction.setReversible(obj.is_reversible)
                    reaction_compartment = (
                        repr(next(iter(obj.compartments)))
                        if len(list(obj.compartments)) > 0
                        else "default_compartment"
                    )
                    reaction.setCompartment(reaction_compartment)

                    for relationship in obj.physical_entities:
                        species_ref: libsbml.SpeciesReference

                        match relationship.type:
                            case PhysicalEntityReactionLikeEvent.Type.INPUT:
                                species_ref = sbml_model.createReactant()
                            case PhysicalEntityReactionLikeEvent.Type.OUTPUT:
                                species_ref = sbml_model.createProduct()

                        species_ref.setSpecies(
                            repr(relationship.physical_entity)
                        )
                        species_ref.setConstant(False)
                        species_ref.setStoichiometry(
                            int(relationship.stoichiometry),
                        )

                    kinetic_law: libsbml.KineticLaw = (
                        reaction.createKineticLaw()
                    )

                    fn = self.kinetic_laws.get(obj, self.default_kinetic_law)
                    formula, parameters = fn(sbml_model, obj)
                    virtual_patient_details.extend(parameters)
                    kinetic_law.setMath(
                        libsbml.parseL3Formula(formula),
                    )
        for formula in self.constraints:
            constraint: libsbml.Constraint = sbml_model.createConstraint()
            constraint.setId("constraint_test")
            constraint.setMath(libsbml.parseL3Formula(formula))

        return (
            sbml_document,
            VirtualPatientDetails(virtual_patient_details),
            Environment(env_physical_entities),
        )


# time_param: libsbml.Parameter = sbml_model.createParameter()
# time_param.setId("t_time")
# time_param.setConstant(False)
# time_param.setValue(0.0)
#
# time_rule: libsbml.Rule = sbml_model.createRateRule()
# time_rule.setVariable("t_time")
# time_rule.setFormula("1")


# class SId:
#     pass
# @dataclass(frozen=True)
# class narameter:
#     id: SId

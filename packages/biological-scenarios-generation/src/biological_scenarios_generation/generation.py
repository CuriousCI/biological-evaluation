from functools import reduce
from operator import attrgetter
import random
from collections.abc import Callable
from dataclasses import dataclass, field
from enum import Enum
from typing import TypeAlias

import libsbml
import noe4j

from biological_scenarios_generation.core import IntGTZ
from biological_scenarios_generation.reactome import (
    Compartment,
    MathML,
    MathMLBool,
    Pathway,
    PhysicalEntity,
    PhysicalEntityReactionLikeEvent,
    ReactionLikeEvent,
    ReactomeDbId,
    Stoichiometry,
)
from biological_scenarios_generation.sbml import SId

VirtualPatient = dict[SId, float]

# TODO: magic, basically annotate with k_ virtual patient parameters (or "v_")
# TODO: magic, basically annotate with e_ environment vars


@dataclass(frozen=True)
class VirtualPatientDetails:
    """A virtual patient is described by the set of parameters."""

    # TODO: set()
    # min max
    parameters: list[libsbml.Parameter]

    def __call__(self) -> VirtualPatient:
        virtual_patient = {}

        for parameter in self.parameters:
            # value = random.uniform(10e-6, 10e6)
            value = random.uniform(0.01, 0.1)
            virtual_patient[parameter.getId()] = value
            parameter.setValue(value)

        return virtual_patient

    @staticmethod
    def from_sbml(sbml: str) -> None:
        pass

    # species: set[Parameter]


@dataclass(frozen=True)
class Environment:
    """An environment dictates the initial conditions of the simulation (initial amounts of the species)."""

    physical_entities: set[PhysicalEntity]

    @staticmethod
    def from_sbml(sbml: str) -> None:
        pass


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
                    hill_component = "1"

                if reaction_like_event.positive_regulators:
                    pass

                if reaction_like_event.negative_regulators:
                    pass

                reaction_formula = f"(k_forward_{reaction_like_event} * {'*'.join(map(repr, reaction_like_event.reactants()))})"

                formula = f"{reaction_formula}"

                if reverse_reaction_formula:
                    formula = f"{formula} - {reverse_reaction_formula}"

                if hill_component:
                    formula = f"{hill_component} * {formula}"

                return (formula, parameters)
            case BaseKineticLaw.CONVENIENCE_KINETIC_LAW:
                return ("", [])


CustomKineticLaw: TypeAlias = Callable[
    [libsbml.Model, ReactionLikeEvent],
    tuple[MathML, list[libsbml.Parameter]],
]

KineticLaw: TypeAlias = BaseKineticLaw | CustomKineticLaw


@dataclass(frozen=True)
class BiologicalScenarioDefinition:
    """Definition of a target scenario to expand for simulations."""

    target_physical_entities: set[PhysicalEntity]
    target_pathways: set[Pathway] | None
    constraints: list[MathMLBool]
    max_depth: IntGTZ | None = None
    excluded_physical_entities: set[PhysicalEntity] = field(default_factory=set)
    default_kinetic_law: KineticLaw = BaseKineticLaw.LAW_OF_MASS_ACTION
    kinetic_laws: dict[ReactionLikeEvent, KineticLaw] = field(
        default_factory=dict,
    )

    def __post_init__(self) -> None:
        assert len(self.target_physical_entities) > 0
        assert not self.target_pathways or len(self.target_pathways) > 0

    def __model_objects(
        self,
        driver: neo4j.Driver,
    ) -> set[PhysicalEntity | ReactionLikeEvent | Compartment]:
        compute_reaction_like_events_in_transitive_closure = """
        MATCH (targetPhysicalEntity:PhysicalEntity)
        WHERE targetPhysicalEntity.dbId IN $target_physical_entities
        CALL
            apoc.path.subgraphNodes(
                targetPhysicalEntity,
                {
                    relationshipFilter: "<output|input>|catalystActivity>|physicalEntity>|<regulatedBy|regulator>",
                    labelFilter: ">ReactionLikeEvent",
                    maxLevel: $max_level,
                    denylistNodes: $excluded_physical_entities
                }
            )
            YIELD node
        """

        expand_reaction_like_events = """
            CALL {
                WITH node
                MATCH (node)-[r:input]->(e)
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
                WITH node
                MATCH (node)-[r:output]->(e)
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
                WITH node
                MATCH (node)-->(:CatalystActivity)-[:physicalEntity]->(e)
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
                WITH node
                MATCH (node)-[:compartment]-(compartment:Compartment)
                RETURN COLLECT({
                    id: compartment.dbId,
                    display_name: compartment.displayName
                }) AS compartments
            }
            CALL {
                WITH node
                MATCH (node)-[:regulatedBy]->(:PositiveRegulation)-[:regulator]->(p:PhysicalEntity)
                RETURN COLLECT({ id: p.dbId }) AS positiveRegulators
            }
            CALL {
                WITH node
                MATCH (node)-[:regulatedBy]->(:NegativeRegulation)-[:regulator]->(p:PhysicalEntity)
                RETURN COLLECT({ id: p.dbId }) AS negativeRegulators
            }
            CALL {
                WITH node
                OPTIONAL MATCH (node)-[:reverseReaction]->(reverseReactionLikeEvent)
                RETURN reverseReactionLikeEvent
            }
            RETURN COLLECT({
                id: node.dbId,
                reactants: reactants,
                products: products,
                enzymes: enzymes,
                compartments: compartments,
                is_reversible: reverseReactionLikeEvent,
                positive_regulators: positiveRegulators,
                negative_regulators: negativeRegulators
            }) AS reactions;
        """

        records: list[neo4j.Record]
        target_physical_entities = list(map(int, self.target_physical_entities))
        excluded_physical_entities = list(
            map(int, self.excluded_physical_entities),
        )

        if self.target_pathways:
            records, _, _ = driver.execute_query(
                """
                MATCH (targetPathway:Pathway)
                WHERE targetPathway.dbId IN $target_pathways
                CALL
                    apoc.path.subgraphNodes(
                        targetPathway,
                        {relationshipFilter: "hasEvent>", labelFilter: ">ReactionLikeEvent"}
                    )
                    YIELD node
                WITH COLLECT(DISTINCT node) AS reactionsSubsetOfInterest
                """
                + compute_reaction_like_events_in_transitive_closure
                + "WHERE node IN reactionsSubsetOfInterest"
                + expand_reaction_like_events,
                max_level=int(self.max_depth) if self.max_depth else -1,
                target_pathways=list(map(int, self.target_pathways)),
                target_physical_entities=target_physical_entities,
                excluded_physical_entities=excluded_physical_entities,
            )
        else:
            records, _, _ = driver.execute_query(
                compute_reaction_like_events_in_transitive_closure
                + expand_reaction_like_events,
                max_level=self.max_depth or -1,
                target_physical_entities=target_physical_entities,
            )

        val = records[0]["reactions"]
        reaction_like_events: set[ReactionLikeEvent] = {
            ReactionLikeEvent(
                id=reaction["id"],
                physical_entities={
                    PhysicalEntityReactionLikeEvent(
                        physical_entity=PhysicalEntity(
                            e["id"],
                            compartments={
                                Compartment(**c) for c in e["compartments"]
                            },
                        ),
                        stoichiometry=e["stoichiometry"],
                        type=PhysicalEntityReactionLikeEvent.Type.INPUT,
                    )
                    for e in reaction["products"]
                }
                | {
                    PhysicalEntityReactionLikeEvent(
                        physical_entity=PhysicalEntity(e["id"]),
                        stoichiometry=Stoichiometry(e["stoichiometry"]),
                        type=PhysicalEntityReactionLikeEvent.Type.OUTPUT,
                    )
                    for e in reaction["reactants"]
                },
                enzymes={
                    PhysicalEntity(
                        ReactomeDbId(entity["id"]),
                        compartments={
                            Compartment(**c) for c in entity["compartments"]
                        },
                    )
                    for entity in reaction["enzymes"]
                },
                compartments={
                    Compartment(**c) for c in reaction["compartments"]
                },
                positive_regulators={
                    PhysicalEntity(**p) for p in reaction["positive_regulators"]
                },
                negative_regulators={
                    PhysicalEntity(**p) for p in reaction["negative_regulators"]
                },
                is_reversible=bool(reaction["is_reversible"]),
            )
            for reaction in val
        }

        physical_entities: set[PhysicalEntity] = reduce(
            set.union,
            (
                reaction_like_event.enzymes
                | reaction_like_event.positive_regulators
                | reaction_like_event.negative_regulators
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
                    # compartment.appendNotes(
                    #     f'<body xmlns="http://www.w3.org/1999/xhtml"><p>{obj.display_name}</p></body>',
                    # )
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
                            repr(relationship.physical_entity),
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

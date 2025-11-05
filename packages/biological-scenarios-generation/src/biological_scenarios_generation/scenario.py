from collections.abc import Callable
from dataclasses import dataclass, field
from enum import Enum, auto
from functools import reduce
from operator import attrgetter
from typing import Any, LiteralString, TypeAlias

import libsbml
import neo4j

from biological_scenarios_generation.core import IntGTZ
from biological_scenarios_generation.model import (
    EnvironmentGenerator,
    Model,
    SId,
    VirtualPatientGenerator,
)
from biological_scenarios_generation.reactome import (
    Compartment,
    MathML,
    MathMLBool,
    ModifierRole,
    Pathway,
    PhysicalEntity,
    ReactionLikeEvent,
    ReactomeDbId,
    Role,
    StandardRole,
    StandardRoleInformation,
    Stoichiometry,
)


class BaseKineticLaw(Enum):
    """Well known kinetic laws."""

    LAW_OF_MASS_ACTION = auto()
    CONVENIENCE_KINETIC_LAW = auto()

    def __call__(
        self, sbml_model: libsbml.Model, reaction_like_event: ReactionLikeEvent
    ) -> tuple[MathML, list[libsbml.Parameter]]:
        """Return reaction law and generate parameters."""
        parameters: list[libsbml.Parameter] = []

        def repr_stoichiometry(
            entity_role: tuple[PhysicalEntity, StandardRoleInformation],
        ) -> str:
            (physical_entity, role) = entity_role
            return f"({physical_entity}^{role.stoichiometry})"

        match self:
            case BaseKineticLaw.LAW_OF_MASS_ACTION:
                forward_parameter: libsbml.Parameter = (
                    sbml_model.createParameter()
                )
                forward_parameter.setId(f"k_forward_{reaction_like_event}")
                forward_parameter.setConstant(True)
                forward_parameter.setValue(1.0)
                parameters.append(forward_parameter)
                formula_forward_reaction = f"(k_forward_{reaction_like_event} * {'*'.join(map(repr_stoichiometry, reaction_like_event.entities(StandardRole.INPUT)))})"

                formula_reverse_reaction: str = ""
                if reaction_like_event.is_reversible:
                    reverse_parameter: libsbml.Parameter = (
                        sbml_model.createParameter()
                    )
                    reverse_parameter.setId(f"k_reverse_{reaction_like_event}")
                    reverse_parameter.setConstant(True)
                    reverse_parameter.setValue(1.0)
                    parameters.append(reverse_parameter)
                    formula_reverse_reaction = f"- (k_reverse_{reaction_like_event} * {'*'.join(map(repr_stoichiometry, reaction_like_event.entities(StandardRole.OUTPUT)))})"

                formula_hill_component: str = ""
                modifiers_functions: list[str] = []
                for modifier_id, (modifier, role) in enumerate(
                    reaction_like_event.modifiers()
                ):
                    hill_function: str
                    match role:
                        case ModifierRole.NEGATIVE_REGULATOR:
                            pass
                        case _:
                            half_saturation_constant: libsbml.Parameter = (
                                sbml_model.createParameter()
                            )

                            constant_id: str = (
                                f"k_half_{modifier_id}_{reaction_like_event}"
                            )
                            half_saturation_constant.setId(constant_id)
                            half_saturation_constant.setValue(1.0)
                            parameters.append(half_saturation_constant)
                            hill_function = (
                                f"({modifier} / ({constant_id} + {modifier}))"
                            )
                            modifiers_functions.append(hill_function)

                if modifiers_functions:
                    formula_hill_component = (
                        f"* ({'*'.join(modifiers_functions)})"
                    )

                formula_regulation: str = ""

                return (
                    f"""
                        ({formula_forward_reaction}
                        {formula_reverse_reaction})
                        {formula_hill_component if formula_hill_component else ""}
                        {formula_regulation}
                    """,
                    parameters,
                )

            case BaseKineticLaw.CONVENIENCE_KINETIC_LAW:
                return ("", [])


CustomKineticLaw: TypeAlias = Callable[
    [libsbml.Model, ReactionLikeEvent], tuple[MathML, list[libsbml.Parameter]]
]

KineticLaw: TypeAlias = BaseKineticLaw | CustomKineticLaw


@dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
class BiologicalScenarioDefinition:
    """Definition of a target scenario to expand for simulations."""

    target_physical_entities: set[PhysicalEntity]
    target_pathways: set[Pathway] | None
    constraints: list[MathMLBool]
    max_depth: IntGTZ | None = field(default=None)
    excluded_physical_entities: set[PhysicalEntity] = field(default_factory=set)
    default_kinetic_law: KineticLaw = field(
        default=BaseKineticLaw.LAW_OF_MASS_ACTION
    )
    kinetic_laws: dict[ReactionLikeEvent, KineticLaw] = field(
        default_factory=dict
    )

    def __post_init__(self) -> None:
        assert self.target_physical_entities
        assert self.target_pathways is None or len(self.target_pathways) > 0

    def __model_objects(
        self, driver: neo4j.Driver
    ) -> set[PhysicalEntity | ReactionLikeEvent | Compartment]:
        reaction_node: LiteralString = "reactionLikeEvent"
        physical_entity_node: LiteralString = "physicalEntity"
        compartment_node: LiteralString = "compartment"
        reference: LiteralString = "reference"

        query_transitive_closure: LiteralString = """
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

        query_reaction_like_events_in_transitive_closure: LiteralString = f"""
            MATCH (targetPhysicalEntity:PhysicalEntity)
            WHERE targetPhysicalEntity.dbId IN $target_physical_entities
            CALL
                apoc.path.subgraphNodes(
                    targetPhysicalEntity,
                    {{
                        relationshipFilter: "<output|input>|catalystActivity>|physicalEntity>|<regulatedBy|regulator>",
                        labelFilter: ">ReactionLikeEvent",
                        maxLevel: $max_level,
                        denylistNodes: $excluded_physical_entities
                    }}
                )
                YIELD node AS {reaction_node}
            WHERE {reaction_node} IN reactionsSubsetOfInterest
        """

        # TODO: compute compartments at the end, ids at the end, and match type

        query_inputs: LiteralString = f"""
            CALL {{
                WITH {reaction_node}
                MATCH ({reaction_node})-[relationship:input]->({physical_entity_node})
                RETURN
                    COLLECT({{
                        physicalEntity: {physical_entity_node},
                        stoichiometry: relationship.stoichiometry,
                        role: "input"
                    }}) AS inputs
            }}
        """

        query_outputs: LiteralString = f"""
            CALL {{
                WITH {reaction_node}
                MATCH ({reaction_node})-[relationship:output]->({physical_entity_node})
                RETURN
                    COLLECT({{
                        physicalEntity: {physical_entity_node},
                        stoichiometry: relationship.stoichiometry,
                        role: "output"
                    }}) AS outputs
            }}
        """

        query_enzymes: LiteralString = f"""
            CALL {{
                WITH {reaction_node}
                MATCH ({reaction_node})-->(:CatalystActivity)-[:physicalEntity]->({physical_entity_node})
                RETURN
                    COLLECT({{
                        physicalEntity: {physical_entity_node},
                        role: "enzyme"
                    }}) AS enzymes
            }}
        """

        def query_regulators(
            label: LiteralString, role: LiteralString, collection: LiteralString
        ) -> LiteralString:
            return f"""
                CALL {{
                    WITH {reaction_node}
                    MATCH ({reaction_node})-[:regulatedBy]->(:{label})-[:regulator]->({physical_entity_node}:PhysicalEntity)
                    RETURN COLLECT({{
                        physicalEntity: {physical_entity_node},
                        role: "{role}"
                    }}) AS {collection}
                }}
            """

        query_reaction_compartments: LiteralString = f"""
            CALL {{
                WITH {reaction_node}
                MATCH ({reaction_node})-[:compartment]-({compartment_node}:Compartment)
                RETURN COLLECT({compartment_node}.dbId) AS compartments
            }}
        """

        query_is_reaction_reversible = f"""
            CALL {{
                WITH {reaction_node}
                OPTIONAL MATCH ({reaction_node})-[:reverseReaction]->(reverseReactionLikeEvent)
                RETURN reverseReactionLikeEvent
            }}
        """

        query_expand_physical_entities_with_compartments: LiteralString = f"""
            WITH *, inputs + outputs + enzymes + positiveRegulators + negativeRegulators AS references
            CALL {{
                WITH references
                UNWIND references AS {reference}
                CALL {{
                    WITH {reference}
                    WITH {reference}.physicalEntity AS {physical_entity_node}
                    MATCH ({physical_entity_node})-[:compartment]-({
            compartment_node
        }:Compartment)
                    RETURN COLLECT({compartment_node}.dbId) as compartments
                }}
                RETURN COLLECT({{
                    id: {reference}.physicalEntity.dbId,
                    role: {reference}.role,
                    stoichiometry: {reference}.stoichiometry,
                    compartments: compartments
                }}) as physicalEntities
            }}
        """

        records: list[neo4j.Record]
        target_physical_entities = list(map(int, self.target_physical_entities))
        excluded_physical_entities = list(
            map(int, self.excluded_physical_entities)
        )

        query: LiteralString = f"""
        {query_transitive_closure}
        {
            query_reaction_like_events_in_transitive_closure
            if self.target_pathways
            else ""
        }
        {query_inputs}
        {query_outputs}
        {query_enzymes}
        {
            query_regulators(
                label="PositiveRegulation",
                role="positive_regulator",
                collection="positiveRegulators",
            )
        }
        {
            query_regulators(
                label="NegativeRegulation",
                role="negative_regulator",
                collection="negativeRegulators",
            )
        }
        {query_is_reaction_reversible}
        {query_reaction_compartments}
        {query_expand_physical_entities_with_compartments}
        RETURN COLLECT({{
            id: {reaction_node}.dbId,
            physical_entities: physicalEntities,
            reverse_reaction: reverseReactionLikeEvent,
            compartments: compartments
        }}) AS reactions;
        """

        records, _, _ = driver.execute_query(
            query,
            max_level=int(self.max_depth) if self.max_depth else -1,
            target_pathways=list(map(int, self.target_pathways))
            if self.target_pathways
            else None,
            target_physical_entities=target_physical_entities,
            excluded_physical_entities=excluded_physical_entities,
        )

        def match_role(obj: dict[str, str]) -> Role:
            match obj["role"]:
                case "input" | "output":
                    return StandardRoleInformation(
                        stoichiometry=Stoichiometry(int(obj["stoichiometry"])),
                        role=StandardRole(obj["role"]),
                    )
                case _:
                    return ModifierRole(obj["role"])

        rows: list[dict[str, Any]] = records[0]["reactions"]
        reaction_like_events: set[ReactionLikeEvent] = {
            ReactionLikeEvent(
                id=ReactomeDbId(reaction["id"]),
                physical_entities={
                    PhysicalEntity(
                        id=ReactomeDbId(obj["id"]),
                        compartments=set(map(Compartment, obj["compartments"])),
                    ): match_role(obj)
                    for obj in reaction["physical_entities"]
                },
                compartments=set(map(Compartment, reaction["compartments"])),
                is_reversible=bool(reaction["reverse_reaction"]),
            )
            for reaction in rows
        }

        physical_entities: set[PhysicalEntity] = reduce(
            set[PhysicalEntity].union,
            (
                reaction_like_event.physical_entities
                for reaction_like_event in reaction_like_events
            ),
            set[PhysicalEntity](),
        )

        compartments: set[Compartment] = reduce(
            set[Compartment].union,
            map(attrgetter("compartments"), reaction_like_events),
            set[Compartment](),
        ) | reduce(
            set[Compartment].union,
            map(attrgetter("compartments"), physical_entities),
            set[Compartment](),
        )

        return physical_entities | reaction_like_events | compartments

    def generate_model(self, driver: neo4j.Driver) -> Model:
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

        virtual_patient_details = set[SId]()
        env_physical_entities = set[PhysicalEntity]()

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

                    for physical_entity, information in obj.entities():
                        species_ref: libsbml.SpeciesReference
                        match information.role:
                            case StandardRole.INPUT:
                                species_ref = sbml_model.createReactant()
                            case StandardRole.OUTPUT:
                                species_ref = sbml_model.createProduct()

                        species_ref.setSpecies(repr(physical_entity))
                        species_ref.setConstant(False)
                        species_ref.setStoichiometry(
                            int(information.stoichiometry)
                        )

                    kinetic_law_procedure = self.kinetic_laws.get(
                        obj, self.default_kinetic_law
                    )
                    l3_formula, parameters = kinetic_law_procedure(
                        sbml_model, obj
                    )
                    for parameter in parameters:
                        virtual_patient_details.add(parameter.getId())
                    kinetic_law: libsbml.KineticLaw = (
                        reaction.createKineticLaw()
                    )
                    kinetic_law.setMath(libsbml.parseL3Formula(l3_formula))

        return (
            sbml_document,
            VirtualPatientGenerator(virtual_patient_details),
            EnvironmentGenerator(env_physical_entities),
        )

import itertools
from collections.abc import Callable
from dataclasses import dataclass, field
from enum import Enum, auto
from functools import reduce
from operator import attrgetter
from typing import Any, LiteralString, TypeAlias

import libsbml
import neo4j

from biological_scenarios_generation.core import IntGTZ, PartialOrder
from biological_scenarios_generation.model import (
    BiologicalModel,
    EnvironmentGenerator,
    SId,
    VirtualPatientGenerator,
)
from biological_scenarios_generation.reactome import (
    Compartment,
    MathML,
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
                forward_parameter.setValue(0.0)
                forward_parameter.setConstant(True)
                parameters.append(forward_parameter)
                formula_forward_reaction = f"(k_forward_{reaction_like_event} * {'*'.join(map(repr_stoichiometry, reaction_like_event.entities(StandardRole.INPUT)))})"

                formula_reverse_reaction: str = ""
                if reaction_like_event.is_reversible:
                    reverse_parameter: libsbml.Parameter = (
                        sbml_model.createParameter()
                    )
                    reverse_parameter.setValue(0.0)
                    reverse_parameter.setId(f"k_reverse_{reaction_like_event}")
                    reverse_parameter.setConstant(True)
                    parameters.append(reverse_parameter)
                    formula_reverse_reaction = f"- (k_reverse_{reaction_like_event} * {'*'.join(map(repr_stoichiometry, reaction_like_event.entities(StandardRole.OUTPUT)))})"

                formula_hill_component: str = ""
                modifiers_functions: list[str] = []
                for modifier_id, (modifier, role) in enumerate(
                    reaction_like_event.modifiers()
                ):
                    # TODO: hmmm.... think better about this one, give references to book to anything!
                    half_saturation_constant: libsbml.Parameter = (
                        sbml_model.createParameter()
                    )
                    half_saturation_constant_id: str = (
                        f"k_half_{modifier_id}_{reaction_like_event}"
                    )
                    half_saturation_constant.setId(half_saturation_constant_id)
                    half_saturation_constant.setValue(1.0)
                    hill_function: str = ""
                    match role:
                        case ModifierRole.NEGATIVE_REGULATOR:
                            hill_function = f"({half_saturation_constant_id} / ({half_saturation_constant_id} + {modifier}^10))"
                        case _:
                            hill_function = f"({modifier}^10 / ({half_saturation_constant_id} + {modifier}^10))"
                    modifiers_functions.append(hill_function)
                    parameters.append(half_saturation_constant)

                if modifiers_functions:
                    formula_hill_component = (
                        f"* ({'*'.join(modifiers_functions)})"
                    )

                formula_regulation: str = ""

                return (
                    f"({formula_forward_reaction} {formula_reverse_reaction}) {formula_hill_component} {formula_regulation}",
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

    physical_entities: set[PhysicalEntity]
    pathways: set[Pathway]
    constraints: PartialOrder[PhysicalEntity]
    max_depth: IntGTZ | None = field(default=None)
    ignored_physical_entities: set[PhysicalEntity] = field(default_factory=set)
    default_kinetic_law: KineticLaw = field(
        default=BaseKineticLaw.LAW_OF_MASS_ACTION
    )
    kinetic_laws: dict[ReactionLikeEvent, KineticLaw] = field(
        default_factory=dict
    )

    def __post_init__(self) -> None:
        assert self.physical_entities

    @dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
    class _BiologicalNetwork:
        input_physical_entities: set[ReactomeDbId]
        output_physical_entities: set[ReactomeDbId]
        network: set[PhysicalEntity | ReactionLikeEvent | Compartment]

        def __post_init__(self) -> None:
            assert self.network
            assert self.input_physical_entities

    def __biological_network(
        self, neo4j_driver: neo4j.Driver
    ) -> _BiologicalNetwork:
        _network_reaction: LiteralString = "networkReactionLikeEvent"
        _network_physical_entity: LiteralString = "networkPhysicalEntity"
        _network_compartment: LiteralString = "networkCompartment"
        physical_entity_reference: LiteralString = (
            "networkPhysicalEntityReference"
        )

        query_reactions_of_interest_subset: LiteralString = """
        MATCH (pathway:Pathway)
        WHERE pathway.dbId IN $scenario_pathways
        CALL
            apoc.path.subgraphNodes(
                pathway,
                {relationshipFilter: "hasEvent>", labelFilter: ">ReactionLikeEvent"}
            )
            YIELD node
        WITH COLLECT(DISTINCT node) AS reactionsOfInterest
        """

        query_transitive_closure_of_scenario: LiteralString = f"""
        MATCH (physicalEntity:PhysicalEntity)
        WHERE physicalEntity.dbId IN $scenario_physical_entities
        CALL
            apoc.path.subgraphNodes(
                physicalEntity,
                {{
                    relationshipFilter: "<output|input>|catalystActivity>|physicalEntity>|<regulatedBy|regulator>",
                    labelFilter: ">ReactionLikeEvent",
                    maxLevel: $max_depth,
                    denylistNodes: $ignored_physical_entities
                }}
            )
            YIELD node AS {_network_reaction}
        """

        filter_reactions_of_interest: LiteralString = (
            f"WHERE {_network_reaction} IN reactionsOfInterest"
        )

        collect_network_reactions: LiteralString = f"""
        WITH COLLECT(DISTINCT {_network_reaction}) AS networkReactions
        UNWIND networkReactions AS {_network_reaction}
        """

        query_network_reaction_inputs: LiteralString = f"""
        CALL {{
            WITH {_network_reaction}
            MATCH ({_network_reaction})-[relationship:input]->({_network_physical_entity}:PhysicalEntity)
            RETURN
                COLLECT({{
                    physicalEntity: {_network_physical_entity},
                    stoichiometry: relationship.stoichiometry,
                    role: "input"
                }}) AS inputs
        }}
        """

        query_network_reaction_outputs: LiteralString = f"""
        CALL {{
            WITH {_network_reaction}
            MATCH ({_network_reaction})-[relationship:output]->({_network_physical_entity}:PhysicalEntity)
            RETURN
                COLLECT({{
                    physicalEntity: {_network_physical_entity},
                    stoichiometry: relationship.stoichiometry,
                    role: "output"
                }}) AS outputs
        }}
        """

        query_network_reaction_enzymes: LiteralString = f"""
        CALL {{
            WITH {_network_reaction}
            MATCH ({_network_reaction})-[:catalystActivity]->(:CatalystActivity)-[:physicalEntity]->({_network_physical_entity}:PhysicalEntity)
            RETURN
                COLLECT({{
                    physicalEntity: {_network_physical_entity},
                    role: "enzyme"
                }}) AS enzymes
        }}
        """

        def query_network_reaction_regulators(
            label: LiteralString, role: LiteralString, collection: LiteralString
        ) -> LiteralString:
            return f"""
            CALL {{
                WITH {_network_reaction}
                MATCH ({_network_reaction})-[:regulatedBy]->(:{label})-[:regulator]->({_network_physical_entity}:PhysicalEntity)
                RETURN
                    COLLECT({{
                        physicalEntity: {_network_physical_entity},
                        role: "{role}"
                    }}) AS {collection}
            }}
            """

        query_network_reaction_positive_regulators: LiteralString = (
            query_network_reaction_regulators(
                label="PositiveRegulation",
                role="positive_regulator",
                collection="positiveRegulators",
            )
        )

        query_network_reaction_negative_regulators: LiteralString = (
            query_network_reaction_regulators(
                label="NegativeRegulation",
                role="negative_regulator",
                collection="negativeRegulators",
            )
        )

        query_network_reaction_compartments: LiteralString = f"""
        CALL {{
            WITH {_network_reaction}
            MATCH ({_network_reaction})-[:compartment]->({_network_compartment}:Compartment)
            RETURN COLLECT({_network_compartment}.dbId) AS compartments
        }}
        """

        query_network_reaction_inputs_which_are_network_inputs: LiteralString = f"""
        CALL {{
            WITH {_network_reaction}, networkReactions
            MATCH ({_network_reaction})-[:input]->({_network_physical_entity}:PhysicalEntity)
            WHERE NOT EXISTS {{
                MATCH ({_network_physical_entity})<-[:output]-(frontierReactionLikeEvent:ReactionLikeEvent)
                WHERE frontierReactionLikeEvent IN networkReactions
            }}
            RETURN COLLECT({_network_physical_entity}.dbId) AS reactionNetworkInputs
        }}
        """

        query_network_reaction_outputs_which_are_network_outputs: LiteralString = f"""
        CALL {{
            WITH {_network_reaction}, networkReactions
            MATCH ({_network_reaction})-[:output]->({_network_physical_entity}:PhysicalEntity)
            WHERE NOT EXISTS {{
                MATCH ({_network_physical_entity})<-[:input]-(frontierReactionLikeEvent:ReactionLikeEvent)
                WHERE frontierReactionLikeEvent IN networkReactions
            }}
            RETURN COLLECT({_network_physical_entity}.dbId) AS reactionNetworkOutputs
        }}
        """

        query_is_network_reaction_reversible: LiteralString = f"""
        CALL {{
            WITH {_network_reaction}
            OPTIONAL MATCH ({_network_reaction})-[:reverseReaction]->(reverseReactionLikeEvent)
            RETURN reverseReactionLikeEvent
        }}
        """

        query_expand_reaction_physical_entities_information: LiteralString = f"""
        WITH *, inputs + outputs + enzymes + positiveRegulators + negativeRegulators AS references
        CALL {{
            WITH references
            UNWIND references AS {physical_entity_reference}
            CALL {{
                WITH {physical_entity_reference}
                WITH {physical_entity_reference}.physicalEntity AS {_network_physical_entity}
                    MATCH ({_network_physical_entity})-[:compartment]-({_network_compartment}:Compartment)
                    RETURN COLLECT({_network_compartment}.dbId) as physicalEntityCompartments
                }}
                RETURN
                    COLLECT({{
                        id: {physical_entity_reference}.physicalEntity.dbId,
                        role: {physical_entity_reference}.role,
                        stoichiometry: {physical_entity_reference}.stoichiometry,
                        compartments: physicalEntityCompartments
                    }}) as physicalEntities
        }}
        """

        query: LiteralString = f"""
        {query_reactions_of_interest_subset if self.pathways else ""}
        {query_transitive_closure_of_scenario}
        {filter_reactions_of_interest if self.pathways else ""}
        {collect_network_reactions}
        {query_network_reaction_inputs}
        {query_network_reaction_outputs}
        {query_network_reaction_enzymes}
        {query_network_reaction_positive_regulators}
        {query_network_reaction_negative_regulators}
        {query_network_reaction_compartments}
        {query_is_network_reaction_reversible}
        {query_expand_reaction_physical_entities_information}
        {query_network_reaction_inputs_which_are_network_inputs}
        {query_network_reaction_outputs_which_are_network_outputs}
        RETURN
            COLLECT({{
                id: {_network_reaction}.dbId,
                physical_entities: physicalEntities,
                reverse_reaction: reverseReactionLikeEvent,
                compartments: compartments
            }}) AS reactions,
            COLLECT(reactionNetworkInputs) AS networkInputs,
            COLLECT(reactionNetworkOutputs) AS networkOutputs;
        """

        records: list[neo4j.Record]
        records, _, _ = neo4j_driver.execute_query(
            query,
            scenario_pathways=list(map(int, self.pathways)),
            scenario_physical_entities=list(map(int, self.physical_entities)),
            ignored_physical_entities=list(
                map(int, self.ignored_physical_entities)
            ),
            max_depth=int(self.max_depth) if self.max_depth else -1,
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

        input_physical_entities_id = set[ReactomeDbId](
            map(ReactomeDbId, itertools.chain(*records[0]["networkInputs"]))
        )
        output_physical_entities_id = set[ReactomeDbId](
            map(ReactomeDbId, itertools.chain(*records[0]["networkOutputs"]))
        )
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

        return BiologicalScenarioDefinition._BiologicalNetwork(
            input_physical_entities=input_physical_entities_id,
            output_physical_entities=output_physical_entities_id,
            network=physical_entities | reaction_like_events | compartments,
        )

    def generate_biological_model(
        self, driver: neo4j.Driver
    ) -> BiologicalModel:
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
        environment_physical_entities = set[PhysicalEntity]()

        biological_network: BiologicalScenarioDefinition._BiologicalNetwork = (
            self.__biological_network(driver)
        )

        for obj in biological_network.network:
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
                        if obj.compartments
                        else "default_compartment"
                    )
                    species.setCompartment(species_compartment)
                    species.setConstant(False)
                    species.setSubstanceUnits("mole")
                    species.setBoundaryCondition(False)
                    species.setHasOnlySubstanceUnits(False)
                    species.setInitialAmount(0.5)
                    environment_physical_entities.add(obj)

                    if obj.id in biological_network.input_physical_entities:
                        input_reaction: libsbml.Reaction = (
                            sbml_model.createReaction()
                        )
                        input_reaction.setId(repr(obj))
                        input_reaction.setReversible(False)
                        input_species_ref: libsbml.SpeciesReference = (
                            sbml_model.createProduct()
                        )
                        input_species_ref.setSpecies(repr(obj))
                        input_species_ref.setConstant(False)
                        input_species_ref.setStoichiometry(1)
                        input_kinetic_law: libsbml.KineticLaw = (
                            input_reaction.createKineticLaw()
                        )
                        input_kinetic_law.setMath(
                            libsbml.parseL3Formula(repr(obj))
                        )

                    if obj.id in biological_network.output_physical_entities:
                        pass

                case ReactionLikeEvent():
                    reaction: libsbml.Reaction = sbml_model.createReaction()
                    reaction.setId(repr(obj))
                    reaction.setReversible(obj.is_reversible)
                    reaction_compartment = (
                        repr(next(iter(obj.compartments)))
                        if obj.compartments
                        else "default_compartment"
                    )
                    reaction.setCompartment(reaction_compartment)

                    for physical_entity, role_information in obj.entities():
                        species_ref: libsbml.SpeciesReference
                        match role_information.role:
                            case StandardRole.INPUT:
                                species_ref = sbml_model.createReactant()
                            case StandardRole.OUTPUT:
                                species_ref = sbml_model.createProduct()

                        species_ref.setSpecies(repr(physical_entity))
                        species_ref.setConstant(False)
                        species_ref.setStoichiometry(
                            int(role_information.stoichiometry)
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

        # TODO: sbml annotations for constraints
        return BiologicalModel(
            document=sbml_document,
            virtual_patient_generator=VirtualPatientGenerator(
                virtual_patient_details
            ),
            environment_generator=EnvironmentGenerator(
                environment_physical_entities
            ),
            constraints=self.constraints,
        )

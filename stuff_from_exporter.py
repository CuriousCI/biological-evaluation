# print("MAGIC")
# perf_start = perf_counter()
# for batch in itertools.batched(range(2046464), n=10000):
#     batch_start = perf_counter()
#     _ = migration.dest.execute_query(
#         """
#         UNWIND $bs AS b
#         CREATE (pe:PhysicalEntity {dbId: b})
#         CREATE (re:ReactionLikeEvent {dbId: b, variant: ""})
#         CREATE (pe)-[:stuff]->(re)
#         """,
#         bs=tuple(batch),
#     )
#     print("done batch", perf_counter() - batch_start)
# print("MAGIC DONE", perf_counter() - perf_start)
#
# s = perf_counter()
# _ = migration.dest.execute_query(
#     """
#     UNWIND $bs AS b
#     CREATE (pe:PhysicalEntity {dbId: b})
#     CREATE (re:ReactionLikeEvent {dbId: b, variant: ""})
#     CREATE (pe)-[:stuff]->(re)
#     """,
#     bs=(1, 2, 3),
# )
# print("INDEX START")
# print("INDEX END", perf_counter() - s)

# s = perf_counter()
# print("DONE REACTIONS", perf_counter() - s)

# with measure("new reactions"):
#     _ = migration.dest.execute_query(
#         """
#         UNWIND $reactions AS reaction
#         CREATE (:ReactionLikeEvent { dbId: reaction.id, variant: reaction.variant })
#         """,
#         reactions=tuple(
#             {"id": reaction_id.id, "variant": reaction_id.variant}
#             for reaction_id, _ in reactions
#         ),
#     )
#
# with measure("new entities"):
#     _ = migration.dest.execute_query(
#         """
#         UNWIND $entities AS entity
#         CREATE (:PhysicalEntity { dbId: entity })
#         """,
#         entities=tuple(
#             {p.id for _, reaction in reactions for p in reaction.participants}
#         ),
#     )

# with measure("constraints"):

# entities: set[int] = set()
# for _, reaction in reactions:
#     for participant in reaction.participants:
#         entities.add(int(participant.id))
#
# perf_1 = perf_counter()
# for batch in itertools.batched(entities, n=5000):
#     _ = migration.dest.execute_query(
#         f"""
#         UNWIND $entities AS entity
#         MERGE (physicalEntity:PhysicalEntity {{ dbId: entity }})
#         """,
#         entities=tuple(batch),
#     )
# print(perf_counter() - perf_1)

# def _key(
#     participant: tuple[ReactionVariantId, Participant],
# ) -> StoichiometricRole | ModifierRole:
#     return participant[1].participation.role

# for id_, participant in all_participants:
#     participants.setdefault(participant.participation.role, []).append(
#         (id_, participant)
#     )

# all_participants: Iterable[tuple[ReactionVariantId, Participant]] = tuple(
#     itertools.chain(
#         *(
#             (
#                 (reaction_id, participant)
#                 for participant in reaction.participants
#             )
#             for reaction_id, reaction in reactions
#         )
#     )
# )
#
# print(len(all_participants))

# participants = {
#     key: tuple(participants)
#     for key, participants in itertools.groupby(
#         sorted(all_participants, key=_key), key=_key
#     )
# }

# _ = migration.dest.execute_query(
#     """
#     UNWIND $reactions AS reaction
#     MERGE (reactionLikeEvent:ReactionLikeEvent { dbId: reaction.id, variant: reaction.variant })
#     """,
#     reactions=tuple(
#         {"id": reaction_id.id, "variant": reaction_id.variant}
#         for reaction_id, _ in reactions
#     ),
# )
#
# _ = migration.dest.execute_query(
#     """
#     UNWIND $entities AS entity
#     MERGE (physicalEntity:PhysicalEntity { dbId: entity })
#     """,
#     entities=tuple(
#         {
#             participant.id
#             for _, reaction in reactions
#             for participant in reaction.participants
#         }
#     ),
# )
#
# print("DONE ALL PARTICIPANTS", perf_counter() - perf_start)

# with measure("reactions"):
# with measure("all participants"):
# @contextmanager
# def measure(message: str):
#     start = perf_counter()
#     yield
#     end = perf_counter()
#     print(f"{message}: {end - start:.6f} seconds")

# perf_start = perf_counter()
# print("STUFF DONE", perf_counter() - perf_start)

# case ModifierRole.CATALYST:
#     query = f"MERGE (reactionLikeEvent)-[:{role.name}]->(physicalEntity)"
# case ModifierRole.POSITIVE_REGULATOR:
#     query = f"MERGE (reactionLikeEvent)-[:{role.name}]->(physicalEntity)"
# case ModifierRole.NEGATIVE_REGULATOR:
#     query = f"MERGE (reactionLikeEvent)-[:{role.name}]->(physicalEntity)"

# with measure("ROLE"):
# with measure("batch"):
# participants.get(role, ())
# print("STUFF", perf_counter() - perf_start)
# _ = migration.dest.execute_query(
#     f"""
#     CALL apoc.periodic.iterate(
#         "
#             UNWIND $reactions AS reaction
#             RETURN reaction
#         ",
#         "
#             MERGE (reactionLikeEvent:ReactionLikeEvent {{dbId: reaction.id, variant: reaction.variant}})
#             MERGE (physicalEntity:PhysicalEntity {{dbId: reaction.participant_id}})
#             {query}
#         ",
#         {{
#             params: {{
#                 reactions: $reactions
#             }},
#             parallel: true
#         }}
#     )
#     YIELD batch, operations
#     RETURN NULL;
#     """
# )

# "role": participant.participation.role.name
# "participants": [
#     {
#         "id": participant.id,
#         "role": participant.participation.role.name,
#         "stoichiometry": participant.participation.stoichiometry
#         if isinstance(
#             participant.participation,
#             StoichiometricParticipation,
#         )
#         else None,
#     }
#     for participant in reaction.participants
# ],

# perf_start = perf_counter()
# for batch in itertools.batched(reactions, n=5000):
#     _ = migration.dest.execute_query(
#         f"""
#         UNWIND $reactions AS reaction
#         MERGE (reactionLikeEvent:ReactionLikeEvent {{dbId: reaction.id, variant: reaction.variant}})
#         WITH reactionLikeEvent, reaction.participants AS participants
#         UNWIND participants AS participant
#         MERGE (physicalEntity:PhysicalEntity {{dbId: participant.id}})
#         FOREACH (_ IN CASE participant.role WHEN "{StoichiometricRole.REACTANT.name}" THEN [1] ELSE [] END |
#             MERGE (reactionLikeEvent)-[:{StoichiometricRole.REACTANT.name} {{stoichiometry: participant.stoichiometry}}]->(physicalEntity)
#         )
#         FOREACH (_ IN CASE participant.role WHEN "{StoichiometricRole.PRODUCT.name}" THEN [1] ELSE [] END |
#             MERGE (reactionLikeEvent)<-[:{StoichiometricRole.PRODUCT.name} {{stoichiometry: participant.stoichiometry}}]-(physicalEntity)
#         )
#         FOREACH (_ IN CASE participant.role WHEN "{ModifierRole.CATALYST.name}" THEN [1] ELSE [] END |
#             MERGE (reactionLikeEvent)-[:{ModifierRole.CATALYST.name}]->(physicalEntity)
#         )
#         FOREACH (_ IN CASE participant.role WHEN "{ModifierRole.POSITIVE_REGULATOR.name}" THEN [1] ELSE [] END |
#             MERGE (reactionLikeEvent)-[:{ModifierRole.POSITIVE_REGULATOR.name}]->(physicalEntity)
#         )
#         FOREACH (_ IN CASE participant.role WHEN "{ModifierRole.NEGATIVE_REGULATOR.name}" THEN [1] ELSE [] END |
#             MERGE (reactionLikeEvent)-[:{ModifierRole.NEGATIVE_REGULATOR.name}]->(physicalEntity)
#         )
#         """,
#         reactions=[
#             {
#                 "id": reaction_id.id,
#                 "variant": reaction_id.variant or "",
#                 "participants": [
#                     {
#                         "id": participant.id,
#                         "role": participant.participation.role.name,
#                         "stoichiometry": participant.participation.stoichiometry
#                         if isinstance(
#                             participant.participation, StoichiometricParticipation
#                         )
#                         else None,
#                     }
#                     for participant in reaction.participants
#                 ],
#             }
#             for reaction_id, reaction in batch
#         ],
#     )
# print(perf_counter() - perf_start)


# reaction_like_events: Iterable[tuple[ReactionId, ReactionLikeEvent]] = (
# )


# participants: list[Participant] = []
# for _, reaction_like_event in reaction_like_events:
#     participants.extend(reaction_like_event.participants)

# new_physical_entities = extract_physical_entities(
#     list(reactions), physical_entities_compartments
# )

# reaction_like_events_pathways=reaction_like_events_pathways,

# , collections

# print(new_physical_entities)


# _ = migration.dest.execute_query(
#     """
#     CALL db.awaitIndexes();
#     """
# )


# TODO: do stuff with reactions

# _ = migration.dest.execute_query(
#     """
#     CREATE CONSTRAINT
#     ON (obj:PhysicalEntity)
#     ASSERT obj.dbId IS UNIQUE;
#     """
# )
#
# _ = migration.dest.execute_query(
#     """
#     CREATE CONSTRAINT
#     ON (obj:ReactionLikeEvent)
#     ASSERT (obj.dbId, obj.variant) IS NODE KEY;
#     """
# )

# print("CONSTRAINTS")

# print("PATHWYAS")

# print("REACTIONS")

# print("COMPARTMENTS")
# print("PATHWYAS2")


#     CREATE CONSTRAINT book_title_year
# FOR (book:Book) REQUIRE (book.title, book.publicationYear) IS UNIQUE


# return (
#     (
#         ReactionId(row["dbId"]),
#         Reaction(
#             participants={
#                 Participant.from_dictionary(participant)
#                 for participant in row["participants"]
#             }
#         ),
#     )
#     for row in records
# )

# collections: dict[EntityId, Collection] = {
#     EntityId(row.entity_id): Collection(
#         members_only_in_collection=tuple(map(EntityId, row.members1)),
#         independent_members=tuple(map(EntityId, row.members2)),
#         is_ordered=row.is_ordered,
#     )
#     for row in query_reactome_collections(migration.reactome)
# }
#
# reactions_1: Iterable[tuple[ReactionId, Reaction]] = tuple(
#     (
#         ReactionId(row.id),
#         Reaction(
#             participants={
#                 Participant.from_dictionary({"L": participant})
#                 for participant in row.participants
#             }
#         ),
#     )
#     for row in query_reactome_reactions(migration.reactome)
# )
# TODO: migrate stoichiometry too!

# {
#     Participant.from_dictionary(participant)
#     for participant in row.participants
# }


# TODO: require __hash__ (Hashable), require __eq__ (derived from Hashable)
# GenericReactionId = TypeVar("GenericReactionId")
#
# GenericCompartmentId = TypeVar("GenericCompartmentId")

# @dataclass(eq=False, order=False, frozen=True, slots=True)
# class Graph(Generic[GenericReactionId, GenericCompartmentId]):
#     entities_compartments: dict[EntityId, GenericCompartmentId]
#     reactions: dict[GenericReactionId, Reaction]
#     produced_frontier_entities: set[EntityId]
#     consumed_frontier_entities: set[EntityId]


# class Ctor2(Protocol[Id]):
#     def __call__(self) -> Id: ...

# CompartmentId = NewType("CompartmentId", ReactomeId)
#
# EntityId = NewType("EntityId", ReactomeId)
#
# ReactionId = NewType("ReactionId", ReactomeId)


# PathwayId: TypeAlias = EventId
#
#
# from lib.query import ParticipantRecord

# from tools.normalize.migration import ParticipantRow


# from pydantic import GetCoreSchemaHandler
# from pydantic_core import core_schema


# @classmethod
# def __get_pydantic_core_schema__(
#     cls, source: type[Any], handler: GetCoreSchemaHandler
# ) -> core_schema.AfterValidatorFunctionSchema:
#     return core_schema.no_info_after_validator_function(
#         cls._validate, core_schema.int_schema()
#     )
#
# @classmethod
# def _validate(cls, value: Any) -> "IntGTZ":
#     return cls(value)

# TODO: do SBML versions of stuff
# ReactionIdSBML = "ciao"

# class CompartmentIdSBML(ReactomeId):
#     @override
#     def __str__(self) -> str:
#         return f"compartment_{super().__str__()}"
#
#
# class EntityIdSBML(ReactomeId):
#     @override
#     def __str__(self) -> str:
#         return f"entity_{super().__str__()}"
#
#
# class ReactionIdSBML(EventId):
#     @override
#     def __str__(self) -> str:
#         return f"reaction_{super().__str__()}"

# def SBML_id(obj: EntityId) -> str:
#     return ""
#
# def SBML_id(obj: ReactionId) -> str:
#     return ""

# def SBML_id(obj: EntityId | ReactionId | ReactionVariantId | CompartmentId) -> LiteralString:
#     match obj:
#         case EntityId:
#             return ""


# automatically implements `__hash__()` because `eq` and `frozen` are true
# @dataclass(eq=True, order=False, frozen=True, slots=True)
# class IdSBML:
#     obj: object

# ReactomePhysicalEntityId(int)
#
# ->
#
# NormalPhysicalEntityId(int, str)

# class Stuff(int): ...
#
# # x: Stuff = 4
# @dataclass()
# class MyStuff(Stuff):
#     magic: str
#
# y: MyStuff = MyStuff("ciao")
# print(y)

# ReactomePhysicalEntityId
# PhysicalEntityIdVariant(PhysicalEntityId):


# TODO: migrate stoichiometry
# TODO: fix model generation


# physical_entities=,
# pathways=,
# excluded_physical_entities=,
# constraints={(nitric_oxide, cyclic_amp)},


# from lib.graph import PhysicalEntityId

# def somefunct(somedict: dict[int, str]) -> None:
#     somedict[10] = "B"

# somedict = {1: "a", 2: "b", 3: "c"}
# print(somedict)
# somefunct(somedict)
# print(somedict)

# p = set(PhysicalEntityId("ciao"))
# print(p)
# print(f"{repr(p)}...")
# print(p + "...")

# records: list[neo4j.Record]
# row: neo4j.Record = records[0]

# map(EntityId, row[Column.PRODUCED_FRONTIER_ENTITIES.name])
# map(EntityId, row[Column.CONSUMED_FRONTIER_ENTITIES.name])

# reaction_like_events = {
#     ReactionVariantId(reaction["id"]): Reaction(
#         participants=set(map(ParticipantRecord.into, reaction["participants"]))
#         # reverse_reaction_like_event_id=reaction[
#         #     "reverseReactionLikeEvent"
#         # ],
#     )
#     for reaction in row[Column.REACTIONS.name]
# }

# reverse_reaction_like_event_id=reaction[
#     "reverseReactionLikeEvent"
# ],
# for reaction in row[Column.REACTIONS.name]


# sbml_initial_concentration_parameter: libsbml.Parameter = (
#     sbml_model.createParameter()
# )
# sbml_initial_concentration_parameter.setId(
#     f"{KineticConstantKind.INITIAL_CONCENTRATION}_{sbml_species.getId()}"
# )
# sbml_initial_concentration_parameter.setValue(0.0)
# sbml_initial_concentration_parameter.setConstant(True)
# sbml_initial_concentration_parameter.setAnnotation(
#     KineticConstantKind.INITIAL_CONCENTRATION.value
# )
#
# sbml_species_concentration_assignment_rule: libsbml.AssignmentRule = (
#     sbml_model.createAssignmentRule()
# )
# sbml_species_concentration_assignment_rule.setVariable(sbml_species.getId())
# sbml_species_concentration_assignment_rule.setMath(
#     libsbml.parseFormula(sbml_initial_concentration_parameter.getId())
# )

# sbml_model.addRule(sbml_species_concentration_assignment_rule)
# sbml_species.setConstant(True)


# print(
#     kinetic_law_procedure(
#         sbml_model,
#         reaction_like_event_id,
#         reaction_like_event,
#         kinetic_constants,
#     )
# )

# species_order=self.constraints,
# kinetic_constants_order=kinetic_constants_order,

# for modifier, role in reaction_like_event_id.modifiers():
#     for modifier_reaction_id in role.produced_by:
#         if modifier_reaction_id != reaction_like_event_id.id:
#             reaction_like_events_order.add(
#                 (modifier_reaction_id, reaction_like_event_id.id)
#             )
#         reaction_like_events_order.add(
#             (modifier.id, reaction_like_event_id.id)
#         )

# kinetic_constants_order: PartialOrder[SId] = set()

# All reactions that have a modifier as product are slower than reactions that are modified.
# for reaction_1, reaction_2 in reaction_like_events_order:
#     for kinetic_constant_1 in kinetic_constants:
#         if str(reaction_1) in kinetic_constant_1 and (
#             kinetic_constant_1.startswith(
#                 ("k_production_", "k_reaction_")
#             )
#         ):
#             for kinetic_constant_2 in kinetic_constants:
#                 if (
#                     str(reaction_2) in kinetic_constant_2
#                     and kinetic_constant_2.startswith(
#                         ("k_production_", "k_reaction_")
#                     )
#                 ):
#                     kinetic_constants_order.add(
#                         (kinetic_constant_1, kinetic_constant_2)
#                     )

# sbml_model.setAnnotation(
#     json.dumps(
#         {
#             "kinetic_constants_order": list(
#                 map(list, kinetic_constants_order)
#             ),
#             "species_order": [
#                 list(map(int, order)) for order in self.constraints
#             ],
#         }
#     )
# )

# {
#     CompartmentId(compartment)
#     for compartment in physical_entity["compartments"]
# }

# (
#     PhysicalEntity(ReactomeId(participant["dbId"])),
#     match_role(participant),
# )
# .restructure()


# from tools.normalize.util import ReactionVariantId
# TODO: parameter for initial concentration
# sbml_initial_concentration_parameter = ...model


# If it's about a canonical / standard form
# CanonicalGraph
# GraphNormalForm
# GraphInNormalForm
# StandardizedGraph
# CanonicalizedGraph

# GraphNormalForm

# If it's about structural simplification
# ReducedGraph
# SimplifiedGraph
# FlattenedGraph
# StandardFormGraph

# If it enforces structural constraints
# ConstrainedGraph
# RegularizedGraph
# UniformGraph
# NormalizedStructureGraph

# If it's specifically a transformation result
# GraphNormalizer → (for the transformer class)
# NormalizedGraph → (resulting data)
# GraphCanonicalizer → (transformer)
# CanonicalGraph → (result)

# @dataclass(eq=False, order=False, frozen=True, slots=True)
# class Collection:
#     independent_members: Sequence[EntityId]
#     members_only_in_collection: Sequence[EntityId]
#     is_ordered: bool
#
#
# class CollectionType(IntEnum):
#     SET = auto()
#     LIST = auto()
# OTHER = auto()


# if isinstance(participant, CombinedParticipant):
#     other_participants.append(participant)
#     continue

# (participants.get(EntityClass.OTHER, ()),),


# def extract_physical_entities(
#     reaction_like_events: Iterable[tuple[ReactionVariantId, Reaction]],
#     physical_entities_compartments: dict[EntityId, tuple[CompartmentId, ...]],
# ) -> dict[EntityId, CombinedCompartmentId]:
#     participants: list[Participant] = []
#
#     for _, reaction_like_event in reaction_like_events:
#         participants.extend(reaction_like_event.participants)
#
#     new_physical_entities_compartments = {}
#
#     # print(physical_entities_compartments)
#
#     for participant in participants:
#         compartments: Iterable[CompartmentId] = ()
#         if isinstance(participant, CombinedParticipant):
#             # print("HERE", flush=True)
#             compartments = itertools.chain(
#                 *(
#                     physical_entities_compartments.get(physical_entity_id, ())
#                     for physical_entity_id in participant.combined_entities
#                 )
#             )
#         else:
#             compartments = physical_entities_compartments.get(participant.id, ())
#
#         new_physical_entities_compartments[participant.id] = CombinedCompartmentId(
#             "_".join(sorted(set(map(str, compartments))))
#         )
#
#     return new_physical_entities_compartments


# participants: dict[EntityClass, Sequence[Participant]] = {
#     class_: tuple(participants)
#     for class_, participants in itertools.groupby(
#         sorted(reaction.participants, key=_key), key=_key
#     )
# }


# ReactionLikeEventIdWithVariant = NewType(
#     "ReactionLikeEventIdWithVariant", tuple[ReactionLikeEventId, str]
# )
# reaction_like_events_pathways: Mapping[ReactionLikeEventId, tuple[PathwayId, ...]],
# reaction_like_events_pathways=reaction_like_events_pathways,
# reaction_like_events_pathways: MutableMapping[
#     ReactionLikeEventId, tuple[PathwayId, ...]
# ],


# print(tuple(compartments), flush=True)
# exit()


# if isinstance(participant, CombinedParticipant):
#     new_physical_entities_compartments[participant.physical_entity_id] = (
#         CombinedCompartmentId(
#             "_".join( sorted( set( map( str, ,))))
#         ),
#     )
# else:
#     new_physical_entities_compartments[participant.physical_entity_id] = (
#         CombinedCompartmentId(
#             "_".join(
#                 sorted(
#                     set(
#                         map(
#                             str,
#                         )
#                     )
#                 )
#             )
#         ),
#     )

# compartments = itertools.chain(
#     physical_entities_compartments[component]
#     for component in (
#         collections[physical_entity_id].members_only_in_collection
#         if physical_entity_id in collections
#         else (physical_entity_id,)
#     )
# )

# new_physical_entities_compartments.append(
#     (participant, CompartmentId("_".join(map(str, sorted(compartments)))))
# )


# new_reaction_id: ReactionVariantId = ReactionVariantId(
#     id=reaction_id.id, variant=f"_{version}"
# )
#
# new_reaction: Reaction = Reaction(participants=set(new_participants))

# new_reactions.append((new_reaction_id, new_reaction))
# reaction_like_events_pathways=reaction_like_events_pathways,

# reaction_like_events_pathways[new_reaction_like_event_id] = (
#     reaction_like_events_pathways[reaction_like_event_id]
# )

# if collection := collections.get(participant.physical_entity_id, None):
#     if (
#         isinstance(participant.participation, StoichiometricParticipation)
#         and collection.is_ordered
#     ):
#         return PhysicalEntityClass.LIST
#
#     return PhysicalEntityClass.SET
#
# return PhysicalEntityClass.OTHER

# pass
# new_reactions.extend(())

# TODO: just add to pathways some new stuff

# normalized_new_reactions: NormalizedReactionLikeEvents = normalize_reactions(
#     reaction_like_events=new_reactions, collections=collections
# )
# return NormalizedReactionLikeEvents(
#     reaction_like_events=normal_reactions
#     + normalized_new_reactions.reaction_like_events,
#     combined_physical_entities=normalized_new_reactions.combined_physical_entities
#     | {},
# )
# combined_physical_entities: dict[PhysicalEntityId, Sequence[PhysicalEntityId]],


# collections: dict[PhysicalEntityId, Collection],


# participant.physical_entity_id
# for participant in reaction_like_event.participants
# )


# TODO: I need another dict, "components style", that, given a new physical_entity, it gives me the components of it! YAY
# TODO: whenever I put together a new physical entity which is composed, I add a new entry in this dict, (I can just call with .get(..., ...))


# normalized
# reaction
# like
# events


# @dataclass(eq=False, order=False, frozen=True, slots=True)
# class NormalizedReactionLikeEvents:
#     reaction_like_events: list[tuple[ReactionLikeEventId, ReactionLikeEvent]]
#     combined_physical_entities: dict[PhysicalEntityId, tuple[PhysicalEntityId]]


# physical_entities_of_interest: set[PhysicalEntityId] | neo4j.Query
# pathways_of_interest: set[PathwayId] | neo4j.Query
# excluded_reactions: set[ReactionLikeEventId] | neo4j.Query = field(
#     default_factory=set
# )
# boundary_physical_entities: set[PhysicalEntityId] | neo4j.Query = field(
#     default_factory=set
# )
# max_depth: IntGTZ | None = field(default=None)

# new_combined_participant: list[Participant] = []
#
# if collection.members_only_in_collection:
#     new_combined_participant = (
#         Participant(
#             physical_entity_id=participant.physical_entity_id,
#             participation=participation,
#         ),
#     )
# combined_physical_entities[participant.physical_entity_id] = (
#     collection.members_only_in_collection
# )
# Participant(
#     physical_entity_id=participant.physical_entity_id
#     )

# NormalizedReactionLikeEvents(
#         reaction_like_events=[], combined_physical_entities={}
#     )


# combined_physical_entities: dict[PhysicalEntityId, Sequence[PhysicalEntityId]]
# nonlocal combined_physical_entities

# Participant(
#     physical_entity_id=PhysicalEntityId(
#         participant.physical_entity_id + "_combined"
#     ),
#     participation=participant.participation,
# ),

# def _key(participant: Participant, collections: Mapping[EntityId, Collection]) -> type:
#     if isinstance(participant, CombinedParticipant):
#         return EntityClass.OTHER
#
#     collection: Collection | None = collections.get(participant.entity_id, None)
#
#     if not collection:
#         return EntityClass.OTHER
#
#     if collection.is_ordered:
#         return EntityClass.LIST
#
#     return EntityClass.SET
# collection: Collection = collections[participant.entity_id]
# return itertools.chain(
#     (
#         Participant(
#             entity_id=entity_id, participation=participant.participation
#         )
#         for entity_id in collection.independent_members
#     ),
#     (
#         CombinedParticipant(
#             entity_id=participant.entity_id,
#             participation=participant.participation,
#             combined_entities=collection.members_only_in_collection,
#         ),
#     )
#     if collection.members_only_in_collection
#     else (),
# )
# participants: MutableMapping[EntityClass, MutableSequence[Participant]] = {}
# for participant in reaction.participants:
#     participants.setdefault(_key(participant, collections), []).append(
#         participant
#     )
# if EntityClass.LIST not in participants and EntityClass.SET not in participants:
# if (lists := participants.get(EntityClass.LIST, ()))
# participants.get(EntityClass.SET, ()),


# product_of_sets_members =
# product_of_sets_members,

# coupled_lists_members = (
#     if (reactome_lists)
#     else ITERTOOLS_PRODUCT_IDENTITY
# )

# EntityId(record.id): Collection(
#     members_only_in_collection=tuple(map(EntityId, record.members1)),
#     independent_members=tuple(map(EntityId, record.members2)),
#     is_ordered=bool(record.is_ordered),
# )
# for record in query_reactome_collections(migration.reactome)

# for record in query_reactome_reactions(migration.reactome)

# records = migration.reactome.execute_query(
#     """
#     MATCH (physicalEntity:PhysicalEntity)
#     WHERE NOT "EntitySet" IN LABELS(physicalEntity)
#     CALL {
#         WITH physicalEntity
#         MATCH (physicalEntity)-[:compartment]->(compartment:Compartment)
#         WITH compartment
#         ORDER BY compartment.dbId
#         RETURN COLLECT(DISTINCT compartment.dbId) AS compartments
#     }
#     RETURN physicalEntity.dbId AS id, compartments
#     """,
#     result_transformer_=transformer(CompartmentRecord),
# )

# records = migration.reactome.execute_query(
#     """
#     MATCH (reactionLikeEvent:ReactionLikeEvent)
#     CALL {
#         with reactionLikeEvent
#         MATCH (reactionLikeEvent)<-[:hasEvent]-(pathway:Pathway)
#         RETURN COLLECT(DISTINCT pathway.dbId) AS pathways
#     }
#     RETURN
#         reactionLikeEvent.dbId AS reactionLikeEventId,
#         pathways
#     """,
#     result_transformer_=transformer(ReactionPathwaysRecord),
# )

# from lib.query import (
#     ParticipantRecord,
# )
# Collection,
# query_reactome_collections,
# query_reactome_reactions,


# class

# stuff that returns a query
# stuff that executes a query


# TODO: xxx_query
# execute_xxx


# Functions that execute and return records
# Use verbs like:
#
# fetch_ (very common for SELECT)
# get_
# load_
# execute_
# run_


# from typing import Iterator


# {}
# | (self.entities_of_interest.metadata or {})
# | (self.reactions_of_interest.metadata or {}),


# metadata: dict[str, Any] = ()

# query: LiteralString = ""

# def _extend(
#     obj: set[EntityId] | set[PathwayId] | set[ReactionId] | neo4j.Query,
#     collection: Collection,
#     label: LiteralString,
# ) -> None:
#     nonlocal query
#     nonlocal metadata
#
#     sub_query: neo4j.Query = (
#         obj
#         if isinstance(obj, neo4j.Query)
#         else neo4j.Query(
#             f"""
#             CALL {{
#                 MATCH (node:{label})
#                 WHERE node.dbId IN ${collection.name}
#                 RETURN COLLECT(DISTINCT node) AS {collection.name}
#             }}
#             """,
#             {collection.name: tuple(obj)},
#         )
#     )
#
#     query += sub_query.text
#     if sub_query.metadata:
#         metadata = dict(metadata, **sub_query.metadata)
#
# _extend(
#     self.physical_entities_of_interest,
#     Collection.PHYSICAL_ENTITIES_OF_INTEREST,
#     "PhysicalEntity",
# )
#
# _extend(
#     self.boundary_physical_entities,
#     Collection.FRONTIER_PHYSICAL_ENTITIES,
#     "PhysicalEntity",
# )
#
# _extend(self.pathways_of_interest, Collection.PATHWAYS_OF_INTEREST, "Pathway")
#
# _extend(
#     self.excluded_reactions, Collection.EXCLUDED_REACTIONS, "ReactionLikeEvent"
# )

# query_1: LiteralString =
# query_2: LiteralString = self.reactions_of_interest.text

# {query_1}
# {query_2}

# CALL {{
#     WITH
#         {Collection.PATHWAYS_OF_INTEREST.name},
#         {Collection.EXCLUDED_REACTIONS.name}
#     UNWIND {Collection.PATHWAYS_OF_INTEREST.name} AS pathway
#     CALL apoc.path.subgraphNodes(
#         pathway,
#         {{
#             relationshipFilter: "hasEvent>",
#             labelFilter: ">ReactionLikeEvent"
#         }}
#     )
#     YIELD node
#     WHERE NOT node IN {Collection.EXCLUDED_REACTIONS.name}
#     RETURN COLLECT(DISTINCT node) AS reactionsOfInterest
# }}
#
# CALL {{
#     WITH
#         {Collection.PHYSICAL_ENTITIES_OF_INTEREST.name},
#         {Collection.FRONTIER_PHYSICAL_ENTITIES.name},
#         {Collection.EXCLUDED_REACTIONS.name},
#         reactionsOfInterest
#     UNWIND {Collection.PHYSICAL_ENTITIES_OF_INTEREST.name} AS physicalEntity
#     CALL apoc.path.subgraphNodes(
#         physicalEntity,
#         {{
#             relationshipFilter: "<{StoichiometricRole.REACTANT.name}|<{StoichiometricRole.PRODUCT.name}|<{ModifierRole.CATALYST.name}|<{ModifierRole.POSITIVE_REGULATOR.name}|<{ModifierRole.NEGATIVE_REGULATOR.name}",
#             labelFilter: ">ReactionLikeEvent",
#             maxLevel: $max_depth,
#             denylistNodes: {Collection.FRONTIER_PHYSICAL_ENTITIES.name} + {Collection.EXCLUDED_REACTIONS.name}
#         }}
#     )
#     YIELD node
#     WHERE node IN reactionsOfInterest
#     RETURN COLLECT(DISTINCT node) AS reactionLikeEvents
# }}

# from lib.reactome import EntityId, PathwayId, ReactionId
# class Column(CaseInsensitiveStrEnum):
#     REACTIONS = auto()
#     PHYSICAL_ENTITIES = auto()
#     PRODUCED_FRONTIER_ENTITIES = auto()
#     CONSUMED_FRONTIER_ENTITIES = auto()
#
#
# class Collection(CaseInsensitiveStrEnum):
#     PHYSICAL_ENTITIES_OF_INTEREST = auto()
#     PATHWAYS_OF_INTEREST = auto()
#     EXCLUDED_REACTIONS = auto()
#     FRONTIER_PHYSICAL_ENTITIES = auto()


# TODO: do just reactions of interest and entities of interest
# pathways_of_interest: set[PathwayId] | neo4j.Query
# excluded_reactions: set[ReactionId] | neo4j.Query = field(default_factory=set)
# boundary_entities: set[EntityId] | neo4j.Query = field(default_factory=set)


# "_".join(map(str, physical_entity["compartments"]))
# EntityId(physical_entity["id"]): CombinedCompartmentId(
#     physical_entity["compartments"][0]
# )
# for physical_entity in row[Column.PHYSICAL_ENTITIES.name]


# def _set_constant_kind(
#     sbml_parameter: libsbml.Parameter,
#     constant_kind: KineticConstantKind,
#     obj: ReactomeId,
#     extra: str = "",
# ) -> tuple[SId, KineticConstantKind]:
#     sbml_parameter.setAnnotation(str(constant_kind))
#     sbml_parameter.setValue(0.0)
#     sbml_parameter.setConstant(True)
#     sbml_parameter.setId(SId("_".join(map(str, ["k", constant_kind, obj, extra]))))
#     return (sbml_parameter.getId(), constant_kind)

# TODO: invariant - only one catalyst
# def _key(participant: Participant) -> StoichiometricRole | ModifierRole:
#     return participant.participation.role
#
# participants = {
#     key: tuple(participants)
#     for key, participants in itertools.groupby(
#         sorted(reaction.participants, key=_key), key=_key
#     )
# }
#
# To run
#
# ```
# uv sync
# uv run src/main.py
# ```
#
#
# ```cypher
# MATCH (reaction:ReactionLikeEvent {dbId: 1031716})
# OPTIONAL MATCH path1 = (reaction)-[:input|output]->(e1)
# OPTIONAL MATCH path2 = (reaction)-->(:CatalystActivity)-[:physicalEntity]->(e2)
# OPTIONAL MATCH path3 = (reaction)-->(:Regulation)-[:regulation]->(e3)
# OPTIONAL MATCH path4 = (e1)-[:hasMember|hasCandidate]->()
# OPTIONAL MATCH path5 = (e2)-[:hasMember|hasCandidate]->()
# OPTIONAL MATCH path6 = (e3)-[:hasMember|hasCandidate]->()
# RETURN path1, path2, path3, path4, path5, path6
# ```
#
#
# ```cypher
# MATCH (reaction:ReactionLikeEvent {dbId: 10989008})
# OPTIONAL MATCH path1 = (reaction)-[:input|output]->(e1)
# OPTIONAL MATCH path2 = (reaction)-->(:CatalystActivity)-[:physicalEntity]->(e2)
# OPTIONAL MATCH path3 = (reaction)-->(:Regulation)-[:regulation]->(e3)
# OPTIONAL MATCH path4 = (e1)-[:hasMember|hasCandidate]->(m1)
# OPTIONAL MATCH path5 = (e2)-[:hasMember|hasCandidate]->(m2)
# OPTIONAL MATCH path6 = (e3)-[:hasMember|hasCandidate]->(m3)
# OPTIONAL MATCH path7 = (m1)<--(:ReactionLikeEvent)
# OPTIONAL MATCH path8 = (m2)<--(:ReactionLikeEvent)
# OPTIONAL MATCH path9 = (m3)<--(:ReactionLikeEvent)
# RETURN path1, path2, path3, path4, path5, path6, path7, path8, path9
# ```

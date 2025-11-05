# TODO: tuple[Stoichiometry,  input | output]
# TODO: magic, basically annotate with k_ virtual patient parameters (or "v_")
# TODO: magic, basically annotate with e_ environment vars
# TODO: min max on virtual patient parameters

# virtual_patient_details.extend(
#         map(lambda parameter: parameter.getId(), parameters)
# )
# for l3_formula in self.constraints:
#     constraint: libsbml.Constraint = sbml_model.createConstraint()
#     constraint.setId("constraint_test")
#     constraint.setMath(libsbml.parseL3Formula(l3_formula))


# time_param: libsbml.Parameter = sbml_model.createParameter()
# time_param.setId("t_time")
# time_param.setConstant(False)
# time_param.setValue(0.0)
#
# time_rule: libsbml.Rule = sbml_model.createRateRule()
# time_rule.setVariable("t_time")
# time_rule.setFormula("1")

# class FromSBMLDocument(ABC):
#     @abstractmethod
#     # @classmethod
#     def from_document(cls, document: libsbml.SBMLDocument) -> Self:
#         pass

# @override
# @classmethod
# species: set[Parameter]


# compartment.appendNotes(
#     f'<body xmlns="http://www.w3.org/1999/xhtml"><p>{obj.display_name}</p></body>',
# )

# _ = driver.execute_query(
#     """
#     MATCH (targetReactionLikeEvent:TargetReactionLikeEvent)
#     REMOVE targetReactionLikeEvent:TargetReactionLikeEvent;
#     """
# )

# enzymes
# | reaction_like_event.positive_regulators
# | reaction_like_event.negative_regulators
# | set(
#     map(
#         attrgetter("physical_entity"),
#         reaction_like_event.physical_entities,
#     )
# )


# else:
#     records, _, _ = driver.execute_query(
#         query_reaction_like_events_in_transitive_closure,
#         # + expand_reaction_like_events,
#         max_level=self.max_depth or -1,
#         target_physical_entities=target_physical_entities,
#     )

# PhysicalEntity.ModifierFunction.ENZYME
# PhysicalEntityReactionLikeEvent(
#     physical_entity=PhysicalEntity(
#         e["id"],
#         compartments={
#             Compartment(**c) for c in e["compartments"]
#         },
#     ),
#     stoichiometry=e["stoichiometry"],
#     type=PhysicalEntityReactionLikeEvent.Type.INPUT,
# )

# | {
#     PhysicalEntityReactionLikeEvent(
#         physical_entity=PhysicalEntity(e["id"]),
#         stoichiometry=Stoichiometry(e["stoichiometry"]),
#         type=PhysicalEntityReactionLikeEvent.Type.OUTPUT,
#     )
#     for e in reaction["reactants"]
# },

# [k for k, v in reaction_like_event.physical_entities.items() if v instanceof PhysicalEntity.ModifierFunction],
# if reaction_like_event.is_fast:
#     pass
# formula = f"{formula_forward_reaction}{formula_reverse_reaction}{formula_hill_component}"
# parameters

# is_fast: bool = field(default=False)
# """Open real interval."""
# """int >= 0."""
# """int > 0."""


# @dataclass
# class BiologicalNumber:
#     id: int
#     properties: str
#     organistm: str
#     value: Interval | float | None
#     units: str
#     keywords: set[str]


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


# function
# in
# reaction

# class Modifier(Enum):
#     ENZYME = 0
#     POSITIVE_REGULATOR = 1
#     NEGATIVE_REGULATOR = 2
#     POSITIVE_GENE_REGULATOR = 3
#     NEGATIVE_GENE_REGULATOR = 4


# class PhysicalEntityReaction:
#


# (Enum):
#     INPUT = 1
#     OUTPUT = 2
#     ENZYME = 3
#     POSITIVE_REGULATOR = 4
#     NEGATIVE_REGULATOR = 5


# class Type(Enum):
#     INPUT = 1
#     OUTPUT = 2

# @dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
# class PhysicalEntityReactionLikeEvent:
#     class Type(Enum):
#         INPUT = 1
#         OUTPUT = 2
#
#     stoichiometry: Stoichiometry
#     type: Type

# physical_entity: PhysicalEntity
# @override
# def __hash__(self) -> int:
#     return self.physical_entity.__hash__()
#
# @override
# def __eq__(self, value: object, /) -> bool:
#     return isinstance(
#         value, PhysicalEntityReactionLikeEvent
#     ) and self.physical_entity.__eq__(value.physical_entity)
# @override
# def __repr__(self) -> str:
#     return f"({self.physical_entity}^{self.stoichiometry})"

# physical_entities: set[PhysicalEntityReactionLikeEvent]
# physical_entities: dict[PhysicalEntity, PhysicalEntityReactionLikeEvent]
# enzymes: set[PhysicalEntity] = field(default_factory=set)
# positive_regulators: set[PhysicalEntity] = field(default_factory=set)
# negative_regulators: set[PhysicalEntity] = field(default_factory=set)
# @cache
# def reactants(self) -> set[PhysicalEntityReactionLikeEvent]:
#     return {
#         relationship
#         for relationship in self.physical_entities
#         if relationship.type == PhysicalEntityReactionLikeEvent.Type.INPUT
#     }
#
# @cache
# def products(self) -> set[PhysicalEntityReactionLikeEvent]:
#     return self.physical_entities - self.reactants()

# for reaction in reaction_like_events:
#     print(reaction.id)
#     print(reaction.is_reversible)
#     print("compartments", list(reaction.compartments))
#     print(*[item for item in reaction.physical_entities.items()])

# (
# (
#     p["stoichiometry"],
#     PhysicalEntity.ReactionFunction.OUTPUT,
# )
# )

# compartments={Compartment(c) for c in reaction["compartments"]},
# {
#     Compartment(c) for c in p["compartments"]
# },
# match PhysicalEntity.ReactionFunction(p["function"])
#     case _:
#         (p["stoichiometry"],PhysicalEntity.ReactionFunction.OUTPUT)
# (
#     p["stoichiometry"],
#     # PhysicalEntity.ReactionFunction.OUTPUT,
# )

# print("physical entities", list(reaction.physical_entities))
# print(reaction_like_events)
# exit()
# | {
#     PhysicalEntity(
#         id=p["id"],
#         compartments={
#             Compartment(**c) for c in p["compartments"]
#         },
#     ): (
#         p["stoichiometry"],
#         PhysicalEntity.ReactionFunction.INPUT,
#     )
#     for p in reaction["reactants"]
# },
# enzymes={
#     PhysicalEntity(
#         ReactomeDbId(entity["id"]),
#         compartments={
#             Compartment(**c) for c in entity["compartments"]
#         },
#     )
#     for entity in reaction["enzymes"]
# },
# positive_regulators={
#     PhysicalEntity(**p) for p in reaction["positive_regulators"]
# },
# negative_regulators={
#     PhysicalEntity(**p) for p in reaction["negative_regulators"]
# },

# return set()

# physical_entities: set[tuple[PhysicalEntity, PhysicalEntity.Function]] {
#         for physical_entity, function   in self.physical_entities.items()
#         if isinstance(function, tuple[Stoichiometry, PhysicalEntity.SimpleFunction])
#         }
#
# return {
#     # (physical_entity, physical_entity_function[0])
#     # for physical_entity, physical_entity_function in self.physical_entities.items()
#     # if isinstance(physical_entity_function, tuple[Stoichiometry, PhysicalEntity.SimpleFunction]) and (x, y) = physical_entity_function
# }

# (
#     stoichiometry,
# )
# StandardFunctionInformation: TypeAlias = tuple[
#     Stoichiometry, StandardFunction
# ]

# class Reaction
# @dataclass(init=True, repr=False, eq=False, order=False, frozen=True)
# class SimpleFunctionData:
#     stoichiometry: Stoichiometry
#     function: SimpleFunction


# if(sbo == SBO_ACTIVATOR || sbo == SBO_ENZYME || sbo == SBO_STIMULATOR) {
#     return create_hill_pos_function(model, modifier, h, kinetic_constant_added);
# } else if(sbo == SBO_INHIBITOR) {
#     return create_hill_neg_function(model, modifier, h, kinetic_constant_added);
# } else {
#     eprintf("[FATAL ERROR] the modifier is not an activator on an inhibitor, SBO: %d\n", sbo);
#     exit(5);
# }
#
# std::string create_hill_pos_function(libsbml::Model *model, libsbml::ModifierSpeciesReference *modifier, u_int h, int *kinetic_constant_added) {
#     assert(h > 0);
#     std::string param_k_regulator = "k_activator_"+modifier->getId();
#     libsbml::Parameter *p = model->createParameter();
#     p->setId(param_k_regulator);
#     p->setValue(1.0);
#     p->setConstant(true);
#     *kinetic_constant_added += 1;
#     if(h == 1) {
#         return "(("+ modifier->getSpecies() +")/("+param_k_regulator+"+"+modifier->getSpecies()+"))";
#     } else {
#         std::string h_str = std::to_string(h);
#         return "(("+ modifier->getSpecies() +"^"+h_str+")/(("+param_k_regulator+"^"+h_str+")+("+modifier->getSpecies()+"^"+h_str+")))";
#     }
#
# }
#
# std::string create_hill_neg_function(libsbml::Model *model, libsbml::ModifierSpeciesReference *modifier, u_int h, int *kinetic_constant_added) {
#     assert(modifier->getSBOTerm() == SBO_INHIBITOR);
#     assert(h > 0);
#     std::string param_k_regulator = "k_inhibitor_"+modifier->getId();
#     libsbml::Parameter *p = model->createParameter();
#     p->setId(param_k_regulator);
#     p->setConstant(true);
#     p->setValue(1.0);
#     *kinetic_constant_added += 1;
#     if(h == 1) {
#         return "(("+ param_k_regulator +")/("+param_k_regulator+"+"+modifier->getSpecies()+"))";
#     } else {
#         std::string h_str = std::to_string(h);
#         return "(("+ param_k_regulator +"^"+h_str+")/(("+param_k_regulator+"^"+h_str+")+("+modifier->getSpecies()+"^"+h_str+")))";
#     }
# }


# reaction_enzymes: set[PhysicalEntity] = {
#     physical_entity
#     for physical_entity, function in reaction_like_event.physical_entities.items()
#     if function == PhysicalEntity.ModifierFunction.ENZYME
# }
#
# reaction_positive_regulators

# if reaction_like_event.enzymes:
#     hill_component = "1"
#
# if reaction_like_event.positive_regulators:
#     pass
#
# if reaction_like_event.negative_regulators:
#     pass

# formula = f"{forward_reaction_formula}"

# if reverse_reaction_formula:

# if hill_component:
# formula = f"{hill_component} * {formula}"

# virtual_patient_parameters = set[SId]()
# for parameter in sbml_model.getListOfParameters():
#     virtual_patient_parameters.add(parameter.getId())
#
# environment_physical_entities = set[PhysicalEntity]()
# for physical_entity in sbml_model.getListOfSpecies():
#     environment_physical_entities.add(physical_entity.getId())

# TODO: use regex
# value = random.uniform(10e-6, 10e6)
# virtual_patient[parameter.getId()] = value
# parameter.setValue(value)

# TODO: set()
# parameters: list[libsbml.Parameter]
# @staticmethod
# def load_document(
#     document: libsbml.SBMLDocument,
# ) -> "VirtualPatientDetails":
#     return VirtualPatientDetails(set())
#


# scenario
# model
# definition
# extract
# loading
# upload
# generation
# consume
# generate
# loading

# class ForwardReactionParameter:
#     reaction_like_event:

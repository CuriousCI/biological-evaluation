"""bsys-eval

Tool to determine the plausability of biological systems states through virtual witnesses.
"""

import sys

import libsbml
import roadrunner
from libsbml import (
    SBMLDocument,
)
from neo4j import GraphDatabase

from library.model import (
    BiologicalSituationDefinition,
    Pathway,
    PhysicalEntity,
    ReactomeDbId,
)

NEO4J_URL_REACTOME = 'neo4j://localhost:7687'
AUTH = ('noe4j', 'neo4j')
REACTOME_DATABASE = 'graph.db'

if __name__ == '__main__':
    # document: SBMLDocument = SBMLDocument()
    biological_situation_definition: BiologicalSituationDefinition = (
        BiologicalSituationDefinition(
            target_entities={PhysicalEntity(ReactomeDbId(202124))},
            target_pathways={
                Pathway(ReactomeDbId(162582)),
                Pathway(ReactomeDbId(168256)),
            },
            constraints=[],
        )
    )

    # exit()

    with GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME, auth=AUTH, database=REACTOME_DATABASE
    ) as driver:
        try:
            driver.verify_connectivity()
            model: SBMLDocument
            (model, _) = biological_situation_definition.yield_sbml_model(driver)
            doc = libsbml.writeSBMLToString(model)
            with open('test.sbml', 'w') as file:
                file.write(doc)
            rr = roadrunner.RoadRunner('./test.sbml')
            result = rr.simulate(
                0,
                10,
                1000,
                ['time'],
                # + list(
                #     map(
                #         # lambda physical_entity: str(physical_entity.standard_id),
                #         # physical_entities,
                #     )
                # ),
            )
            # rr.plot(result=result, loc='upper left')

        except Exception as exception:
            print(exception)
            sys.exit(1)

    virtual_patients = set()

    # while True:
    # instance = yield_model_instance(model)
    # if True:
    #     virtual_patients.add(instance)
    # break

# fibrin_results = query(driver)
# print(exception)
#     physical_entities: set[model.PhysicalEntity] = set()
#     reactions: list[model.ReactionLikeEvent] = list()
#
#     for reaction in map(lambda reaction: reaction.data(), fibrin_results):
#         physical_entities = physical_entities.union(
#             map(
#                 lambda physical_entity: model.PhysicalEntity(
#                     model.StandardId(physical_entity['stId']),
#                     physical_entity['displayName'],
#                 ),
#                 reaction['reactants'] + reaction['products'],
#             )
#         )
#
#         reactions.append(
#             model.ReactionLikeEvent(
#                 set(
#                     map(
#                         lambda reactant: model.Reactant(
#                             model.StandardId(reactant['stId']),
#                             reactant['displayName'],
#                             model.RationalGT0(reactant['stoichiometry']),
#                         ),
#                         reaction['reactants'],
#                     )
#                 ),
#                 set(
#                     map(
#                         lambda product: model.ReactionProduct(
#                             model.StandardId(product['stId']),
#                             product['displayName'],
#                             model.RationalGT0(product['stoichiometry']),
#                         ),
#                         reaction['products'],
#                     )
#                 ),
#             )
#         )
#
# print(physical_entities)
#
# document: model.SBMLDocumentString | None = create_simple_model(
#     physical_entities, reactions
# )
#
# if document is None:
#     sys.exit(1)
#
# composite_problem: petab.v1.CompositeProblem = petab.v1.CompositeProblem.from_yaml(
#     './model/model.yaml'
# )
#
# print(composite_problem)
#
# with open('test.sbml', 'w') as file:
#     file.write(document)
#
# black_box: optimization.BlackBoxSBML = optimization.BlackBoxSBML(
#     set(map(lambda e: e.standard_id, physical_entities))
# )
#
# solver = NOMADSolver()
# solver_params = {'solver_params': []}
# result = solver.solve(black_box, solver_params)
# print(result)

# rr = RoadRunnerEngine()
# rr_model: Model = Model(
#     sim_engine=rr,
#     model_filename='test.sbml',
#     abs_tol=1.0,
#     rel_tol=1.0,
#     time_step=1.0,
# )
# trajectory: dict[str, list[float]] = rr.simulate_trajectory(
#     rr_model, horizon=10000.0
# )


# for key, val in trajectory.items():
#     print(key)
#     print(val)

# set(map(lambda e: e.standard_id, physical_entities))

# TODO: simulate until reaching equilibrium

# rr_instance: ModelInstance = rr.load_model('test.sbml')
# rr_instance.set_parameter('par1', 15.5)

#     pass
# print(trajectory)

# with open('test.sbml', 'w') as file:
#     file.write(document)
#
# rr = roadrunner.RoadRunner('./test.sbml')
# result = rr.simulate(
#     0,
#     10,
#     1000,
#     ['time']
#     + list(
#         map(
#             lambda physical_entity: str(physical_entity.standard_id),
#             physical_entities,
#         )
#     ),
# )
# rr.plot(result=result, loc='upper left')
# ```
#
#
# ```python
#  def check(value, message):
#    """If 'value' is None, prints an error message constructed using
#    'message' and then exits with status code 1.  If 'value' is an integer,
#    it assumes it is a libSBML return status code.  If the code value is
#    LIBSBML_OPERATION_SUCCESS, returns without further action; if it is not,
#    prints an error message constructed using 'message' along with text from
#    libSBML explaining the meaning of the code, and exits with status code 1.
#    """
#    if value == None:
#      raise SystemExit('LibSBML returned a null value trying to ' + message + '.')
#    elif type(value) is int:
#      if value == LIBSBML_OPERATION_SUCCESS:
#        return
#      else:
#        err_msg = 'Error encountered trying to ' + message + '.' \
#                  + 'LibSBML returned error code ' + str(value) + ': "' \
#                  + OperationReturnValue_toString(value).strip() + '"'
#        raise SystemExit(err_msg)
#    else:
#      return
#
#
#  def create_model():
#      try:
#          document: libsbml.SBMLDocument = SBMLDocument(3, 1)  # level, version
#      except ValueError:
#          return
#
#      model: libsbml.Model = document.createModel()
#
#      # required
#      model.setTimeUnits('second')
#      model.setExtentUnits('mole')
#      model.setSubstanceUnits('mole')
#
#      per_second = model.createUnitDefinition()
#      per_second.setId('per_second')
#
#      unit = per_second.createUnit()
#      # required
#      unit.setKind(UNIT_KIND_SECOND)
#      unit.setExponent(-1)
#      unit.setScale(0)  # TODO: ??
#      unit.setMultiplier(1)  # TODO: ??
#
#      # bounded Space in which the reactions occur, maybe I would need to make a better compartment
#      c1 = model.createCompartment()
#      c1.setId('c1')
#      c1.setConstant(True)
#      c1.setSize(1)
#      c1.setSpatialDimensions(3)
#      c1.setUnits('litre')
#
#      s1: libsbml.Species = model.createSpecies()
#      s1.setId('s1')
#      s1.setCompartment('c1')
#      s1.setConstant(False)
#      s1.setInitialAmount(5)
#      s1.setSubstanceUnits('mole')
#      s1.setBoundaryCondition(False)
#      s1.setHasOnlySubstanceUnits(False)
#
#      s2 = model.createSpecies()
#      s2.setId('s2')
#      s2.setCompartment('c1')
#      s2.setConstant(False)
#      s2.setInitialAmount(0)
#      s2.setSubstanceUnits('mole')
#      s2.setBoundaryCondition(False)
#      s2.setHasOnlySubstanceUnits(False)
#
#      # Create a parameter object inside this model
#      # attributes 'id' and 'constant' for a parameter in SBML Level 3
#      # initialize the parameter with a value along with its units.
#
#      k = model.createParameter()
#      k.setId('k')
#      k.setConstant(True)
#      k.setValue(1)
#      k.setUnits('per_second')
#
#      # Create a reaction inside this model
#      # and set the reaction rate expression (the SBML "kinetic law").  We
#      # set the minimum required attributes for all of these objects.  The
#      # units of the reaction rate are determined from the 'timeUnits' and
#      # 'extentUnits' attributes on the Model object.
#
#      # for a reaction I need reactants and products
#      # reaction rate expression
#
#      r1 = model.createReaction()
#      r1.setId('r1')
#      r1.setReversible(False)
#      r1.setFast(False)
#
#      species_ref1 = r1.createReactant()
#      species_ref1.setSpecies('s1')
#      species_ref1.setConstant(True)
#
#      species_ref2 = r1.createProduct()
#      species_ref2.setSpecies('s2')
#      species_ref2.setConstant(True)
#
#      math_ast = parseL3Formula('k * s1 * c1')
#
#      kinetic_law = r1.createKineticLaw()
#      kinetic_law.setMath(math_ast)
#
#      return writeSBMLToString(document)
# ```
#
#
# ```python
#     # simulation = roadrunner.RoadRunner(
#     # 'https://www.ebi.ac.uk/biomodels/model/download/BIOMD0000000010.2?filename=BIOMD0000000010_url.xml'
#     # )
#
#     # print(reaction['reaction.dbId'])
#     # print(reaction['reaction.displayName'])
#     # print(reaction['reactants'])
#     # print(reaction['products'])
#
#     # print(json.dumps(result, sort_keys=True, indent=4))
#     # pass
#     # filter(
#     #     lambda result: result['inputs'] != [],
#     # )
#     # inputs = result['inputs']
#     # products = result['outputs']
#     # print(inputs)
#     # print(products)
#
#     # print(json.dumps(result, sort_keys=True, indent=4))
#
# # for item in result:
# #     print(item['path'])
# # print(result)
#
# # break
# # for item in result:
# #     print(item)
# # print(result)
#
# # // 'hasComponent'
# # """
# # MATCH (output)<-[*..1]-(ancestor)<-[*..1]-(input)
# # WHERE ancestor.dbId IN COLLECT {
# #     MATCH path = (n {dbId: $dbId})<-[*..5]-(a)
# #     WHERE
# #         (a:Event OR a:PhysicalEntity) AND
# #         NONE (
# #             relationship IN relationships(path)
# #             WHERE type(relationship) IN ['inferredTo']
# #         )
# #     RETURN a.dbId
# # }
# # RETURN DISTINCT ancestor
# # """,
#
# # // RETURN collect({e: inEdge, p: properties(inEdge)}) AS inputs
# # // RETURN collect({e: outEdge, p: properties(outEdge)}) AS outputs
#
# # 'stoichiometry':
#
#
# # fibrin_results
#
# # max_path = max(
# #     map(lambda record: record.data()['path'], query_fibrin(driver)),
# #     key=lambda path: len(path),
# # )
#
# # for entity in max_path:
# #     print(
# #         (entity['displayName'][:80]) if 'displayName' in entity else entity
# #     )
#
# # model = create_model()
# # with open('test.sbml', 'w') as file:
# #     file.write(str(model))
#
# # for record in query():
# #     print(len(record.data()['path']))
#
# # print(max_path)
#
# # record = query()[0]
# # for record in query():
# # for entity in record.data()['path']:
# #     print(entity)
# # print(record.data()['path'])
#
# # print(model)
#
# # model2 = roadrunner.RoadRunner('./test.sbml')
#
# # simulation = roadrunner.RoadRunner(
# #     'https://www.ebi.ac.uk/biomodels/model/download/BIOMD0000000010.2?filename=BIOMD0000000010_url.xml'
# # )
# # results = simulation.simulate(start=0, end=100, points=10)
#
# # simulation.plot()
# # print(results)
#
# # pylab.plot(results[:, 0], results[:, 1:])
# # pylab.show()
#
# # model.plot()
# # model2.showPlot()
# # model.plotLegend()
# # print(results)
#
# # model = roadrunner.RoadRunner('./docs/R-HSA-140877.sbml')
# # results = model.simulate(start=0, end=2000, points=200)
# # model.plot()
# # print(results)
#
# # driver = GraphDatabase.driver(URI, auth=AUTH)
# # session = driver.session(database='neo4j')
#
# # session.close()
# # driver.close()
#
# # print(summary)
# # for key in keys:
# #     print(key)
# # record = records[0]
# # print(record.data())
# # for record in records:
# #     print(record.data())
#
# # summary = driver.execute_query(
# #     """
# # # CREATE (a:Person {name: $name})
# # # CREATE (b:Person {name: $friendName})
# # # CREATE (a)-[:KNOWS]->(b)
# # """,
# #     name='Alice',
# #     friendName='David',
# #     database_='neo4j',
# # ).summary
# # print(
# #     'Created {nodes_created} nodes in {time} ms.'.format(
# #         nodes_created=summary.counters.nodes_created,
# #         time=summary.result_available_after,
# #     )
# # )
#
# # records, summary, keys = driver.execute_query(
# #     """
# #     MATCH (p:Person)-[:KNOWS]->(:Person)
# #     RETURN p.name AS name
# #     """,
# #     database_='neo4j',
# # )
#
# #     # Loop through results and do something with them
# # for record in records:
# #     print(record.data())  # obtain record as dict
# #
# # # Summary information
# # print(
# #     'The query `{query}` returned {records_count} records in {time} ms.'.format(
# #         query=summary.query,
# #         records_count=len(records),
# #         time=summary.result_available_after,
# #     )
# # )
#
# # session/driver usage


# def create_simple_model(
#     physical_entities: set[model.PhysicalEntity],
#     reactions: list[model.ReactionLikeEvent],
# ) -> model.SBMLDocumentString | None:
#     try:
#         document: libsbml.SBMLDocument = SBMLDocument(3, 1)
#     except ValueError:
#         return None
#
#     sbml_model: libsbml.Model = document.createModel()
#     sbml_model.setTimeUnits('second')
#     sbml_model.setExtentUnits('mole')
#     sbml_model.setSubstanceUnits('mole')
#
#     compartment: libsbml.Compartment = sbml_model.createCompartment()
#     compartment.setId('c1')  # TODO: random UUID64, or just id
#     compartment.setConstant(True)
#     compartment.setSize(1)
#     compartment.setSpatialDimensions(3)
#     compartment.setUnits('litre')
#
#     for physical_entity in physical_entities:
#         species: libsbml.Species = sbml_model.createSpecies()
#         species.setId(str(physical_entity.standard_id))
#         species.setCompartment('c1')
#         species.setConstant(False)
#         species.setInitialAmount(random.randint(5, 100))
#         species.setSubstanceUnits('mole')
#         species.setBoundaryCondition(False)
#         species.setHasOnlySubstanceUnits(False)
#
#     for id, reaction in enumerate(reactions):
#         sbml_reaction: libsbml.Reaction = sbml_model.createReaction()
#         sbml_reaction.setId(f'r{id}')
#         sbml_reaction.setReversible(False)
#         sbml_reaction.setFast(False)
#
#         for reactant in reaction.reactants:
#             reactant_ref: libsbml.SpeciesReference = sbml_model.createReactant()
#             reactant_ref.setSpecies(str(reactant.standard_id))
#             reactant_ref.setConstant(True)
#             reactant_ref.setStoichiometry(reactant.stoichiometry)
#
#         for product in reaction.products:
#             product_ref: libsbml.SpeciesReference = sbml_model.createProduct()
#             product_ref.setSpecies(str(product.standard_id))
#             product_ref.setConstant(True)
#             product_ref.setStoichiometry(product.stoichiometry)
#
#         math_ast = parseL3Formula(
#             '('
#             + ' + '.join(map(lambda r: f'{r.standard_id}', reaction.reactants))
#             + ') * c1'
#         )
#         kinetic_law: KineticLaw = sbml_reaction.createKineticLaw()
#         kinetic_law.setMath(math_ast)
#
#     return writeSBMLToString(document)


# def query(driver: neo4j.Driver) -> list[Any]:
#     # CROSSLINKED_FIBRIN_MULTIMER_REACTION_DB_ID = 158750
#     PLAT_DB_ID = 158754
#
#     # records, summary, keys
#     records, _, _ = driver.execute_query(
#         """
#         MATCH path = (n {dbId: $dbId})<-[*..3]-(reaction:ReactionLikeEvent)
#         WHERE NONE(
#             relationship IN relationships(path)
#             WHERE type(relationship) IN [
#                 'author', 'modified', 'edited', 'authored', 'reviewed',
#                 'created', 'updatedInstance', 'revised', 'inferredTo'
#             ]
#         )
#         CALL {
#             WITH reaction
#             MATCH (entity)-[relationship:input]-(reaction)
#             RETURN collect({
#                 stId: entity.stId,
#                 displayName: entity.displayName,
#                 stoichiometry: relationship.stoichiometry,
#                 order: relationship.order
#             }) AS reactants
#         }
#         CALL {
#             WITH reaction
#             MATCH (entity)-[relationship:output]-(reaction)
#             RETURN collect({
#                 stId: entity.stId,
#                 displayName: entity.displayName,
#                 stoichiometry: relationship.stoichiometry,
#                 order: relationship.order
#             }) AS products
#         }
#         RETURN
#             reaction.stId AS stId, reaction.displayName AS displayName,
#             reactants, products
#         """,
#         dbId=PLAT_DB_ID,
#         database_=REACTOME_DATABASE,
#     )
#
#     return records


# for row in records:
#     for val in row:

# for reaction in val:
#     reaction_like_events.add(

# print(json.dumps(records, indent=4))


# print(list(map(vars, reaction_like_events)))
# print(list(map(vars, physical_entities)))
# print(list(map(vars, compartments)))
# print()
# print()

# try:
# except Exception as e:
#     print(e)
#
# return set()


# set[DatabaseObject
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
# T = TypeVar('T')
# def union(a: set[T], b: set[T]) -> set[T]:
#     return a.union(b)

# RETURN apoc.convert.toJson(COLLECT({reaction: reaction.dbId, reactants: reactants, products: products})) AS reactions;
# target_entities=list(self.target_entities),
# physical_entities: set[PhysicalEntity] = set()

# lambda entity_reaction: entity_reaction.physical_entity,
# .extend(reaction['products'] or []),
# .union(set(map(lambda p: p, reaction['products']))),
# reactants=set(PhysicalEntity(id=ReactomeDbId(10))),
# print([record.keys() for record in records])
# print(records)

# TODO:
# - NewUnitDefinitions
# - CompartmentDefinition (for each PhysicalEntity)
# - SpeciesDefinition (one per PhysicalEntity)
# - ReactionDefinition (+ stuff it needs!)
# -----------------
# - Parameter
# - Constraint


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

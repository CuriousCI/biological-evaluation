"""bsys-eval.

Tool to determine the plausability of biological systems states through virtual witnesses.
"""


# TODO: What question is the model supposed to answer?
# TODO: Is it built to explain a surprising observation?
# TODO: Is it built to relate separate observations with each other and with previous knowledge?
# TODO: Is it built to make predictions, for example, about the effect of specific perturbations?
# TODO: Often, a major function of models is to make assumptions about the underlying process explicit and, hence, testable.
# TODO: (this is basically my case, the other 2, boolean networks and stochastic descriptions do not really matter) Network-based models describe and analyze properties, states, or dynamics of networks, that is, components and their interactions. Typical and frequently used network- centered modeling frameworks are as follows: Systems of ordinary differential equations for bio­ chemical reaction networks
# TODO: This can be kinetic laws for individual reactions or instructions for combining input information arriving at a node from different edges as in Boolean networks. (kinetic laws is my stuff!)
# TODO: ODE systems are deterministic

# TODO: 1) Define the question that the model shall help to answer.
# TODO: 2) Seek available information: Read the literature. Look at the available experimental data. Talk to experts in the field.
# TODO: 3) Formulate a mental model.
# TODO: 4) Decide on the modeling concept (network-based or rule-based, deterministic or stochastic, etc.)
# TODO: 5) Formulate the first (simple) mathematical model.
# TODO: 6) Test the model performance in comparison to the available data.
# TODO: 7) Refine the model, estimate parameters.
# TODO: 8) Analyze the system (parameter sensitivity, static and temporal behaviors, etc.)
# TODO: 9) Make predictions for scenarios not used to construct the model such as gene knockout or overexpression, application of different stimuli or perturbations.
# TODO: 10) Compare predictions and experimental results.
# bionumbers_table = pandas.read_csv("bionumbers.csv")
# units = set()
# keywords: set[str] = set()
# for _, row in bionumbers_table.iterrows():
#     # if (
#     #     difflib.SequenceMatcher(
#     #         None,
#     #         str(row["Properties"]).lower(),
#     #         "nitric oxide",
#     #     ).ratio()
#     #     > 0.6
#     # ):
#     # print(*str(row["Keywords"]).split(","), sep=" | ")
#     keywords = keywords | {
#         keyword.lower().strip()
#         for keyword in str(row["Keywords"]).split(",")
#     }
#
#     if "nitric oxide" in str(row["Properties"]).lower():
#         # print(row["Organism"], row["Range"], row["Units"])
#         print(
#             f"{row['Organism']} \n \t {row['Properties']} \n \t {row['Range']} {row['Units']}"
#         )
#     # print(line)
#
# print(*keywords, sep="\n")
# exit(0)

# compartments = [
#     "endoplasmic reticulum membrane",
#     "lysosomal membrane",
#     "endoplasmic reticulum lumen",
#     "phagocytic vesicle membrane",
#     "lysosomal lumen",
#     "plasma membrane",
#     "phagocytic vesicle lumen",
#     "cytosol",
#     "extracellular region",
#     "phagocytic vesicle",
# ]
# rows = []
# with Path("bionumbers.csv").open() as file:
#     reader = csv.DictReader(file)
#     for row in reader:
#         rows.append(row)
#
# for c in compartments:
#     s = {
#         f"{r['Value']} {r['Units']}"
#         for r in rows
#         if c in r["Keywords"].lower()
#     }
#     print(c, s)
#
# exit(1)

import sys

import libsbml
import roadrunner
from neo4j import GraphDatabase

from library.model import (
    BiologicalScenarioDefinition,
    Pathway,
    PhysicalEntity,
    ReactomeDbId,
)

NEO4J_URL_REACTOME = "neo4j://localhost:7687"
AUTH = ("noe4j", "neo4j")
REACTOME_DATABASE = "graph.db"

if __name__ == "__main__":
    biological_scenario_definition: BiologicalScenarioDefinition = (
        BiologicalScenarioDefinition(
            target_physical_entities={PhysicalEntity(ReactomeDbId(202124))},
            target_pathways={
                Pathway(ReactomeDbId(162582)),
                Pathway(ReactomeDbId(168256)),
            },
            constraints=[],
        )
    )

    with GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME, auth=AUTH, database=REACTOME_DATABASE
    ) as driver:
        try:
            driver.verify_connectivity()

            sbml_doc: libsbml.SBMLDocument
            (sbml_doc, _) = biological_scenario_definition.yield_sbml_model(
                driver
            )
            sbml_str = libsbml.writeSBMLToString(sbml_doc)

            with open("test.sbml", "w") as file:
                file.write(sbml_str)

            #     # http://sys-bio.github.io/roadrunner/docs-build/tutorial/tutorial.html
            rr = roadrunner.RoadRunner(sbml_str)
            result = rr.simulate(start=0, end=10, points=1000)
            rr.plot(result=result, loc="upper left")
        except Exception as exception:
            print(exception)
            sys.exit(1)

    # try:
    # print(result)
    # except Exception as e:
    #     print(e)

    virtual_patients = set()

    while True:
        # instance = yield_model_instance(model)
        if True:
            # virtual_patients.add(instance)
            break


# err = model.checkConsistency()
# print(model.getError(err))
# with open('test.sbml', 'w') as file:
#     file.write(doc)


# result = rr.simulate(
#     0,
#     10,
#     1000,
#     ['time', '202124'],
# )

# + list(
#     map(
#         # lambda physical_entity: str(physical_entity.standard_id),
#         # physical_entities,
#     )
# ),
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

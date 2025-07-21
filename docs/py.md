```python
 def check(value, message):
   """If 'value' is None, prints an error message constructed using
   'message' and then exits with status code 1.  If 'value' is an integer,
   it assumes it is a libSBML return status code.  If the code value is
   LIBSBML_OPERATION_SUCCESS, returns without further action; if it is not,
   prints an error message constructed using 'message' along with text from
   libSBML explaining the meaning of the code, and exits with status code 1.
   """
   if value == None:
     raise SystemExit('LibSBML returned a null value trying to ' + message + '.')
   elif type(value) is int:
     if value == LIBSBML_OPERATION_SUCCESS:
       return
     else:
       err_msg = 'Error encountered trying to ' + message + '.' \
                 + 'LibSBML returned error code ' + str(value) + ': "' \
                 + OperationReturnValue_toString(value).strip() + '"'
       raise SystemExit(err_msg)
   else:
     return


 def create_model():
     try:
         document: libsbml.SBMLDocument = SBMLDocument(3, 1)  # level, version
     except ValueError:
         return

     model: libsbml.Model = document.createModel()

     # required
     model.setTimeUnits('second')
     model.setExtentUnits('mole')
     model.setSubstanceUnits('mole')

     per_second = model.createUnitDefinition()
     per_second.setId('per_second')

     unit = per_second.createUnit()
     # required
     unit.setKind(UNIT_KIND_SECOND)
     unit.setExponent(-1)
     unit.setScale(0)  # TODO: ??
     unit.setMultiplier(1)  # TODO: ??

     # bounded Space in which the reactions occur, maybe I would need to make a better compartment
     c1 = model.createCompartment()
     c1.setId('c1')
     c1.setConstant(True)
     c1.setSize(1)
     c1.setSpatialDimensions(3)
     c1.setUnits('litre')

     s1: libsbml.Species = model.createSpecies()
     s1.setId('s1')
     s1.setCompartment('c1')
     s1.setConstant(False)
     s1.setInitialAmount(5)
     s1.setSubstanceUnits('mole')
     s1.setBoundaryCondition(False)
     s1.setHasOnlySubstanceUnits(False)

     s2 = model.createSpecies()
     s2.setId('s2')
     s2.setCompartment('c1')
     s2.setConstant(False)
     s2.setInitialAmount(0)
     s2.setSubstanceUnits('mole')
     s2.setBoundaryCondition(False)
     s2.setHasOnlySubstanceUnits(False)

     # Create a parameter object inside this model
     # attributes 'id' and 'constant' for a parameter in SBML Level 3
     # initialize the parameter with a value along with its units.

     k = model.createParameter()
     k.setId('k')
     k.setConstant(True)
     k.setValue(1)
     k.setUnits('per_second')

     # Create a reaction inside this model
     # and set the reaction rate expression (the SBML "kinetic law").  We
     # set the minimum required attributes for all of these objects.  The
     # units of the reaction rate are determined from the 'timeUnits' and
     # 'extentUnits' attributes on the Model object.

     # for a reaction I need reactants and products
     # reaction rate expression

     r1 = model.createReaction()
     r1.setId('r1')
     r1.setReversible(False)
     r1.setFast(False)

     species_ref1 = r1.createReactant()
     species_ref1.setSpecies('s1')
     species_ref1.setConstant(True)

     species_ref2 = r1.createProduct()
     species_ref2.setSpecies('s2')
     species_ref2.setConstant(True)

     math_ast = parseL3Formula('k * s1 * c1')

     kinetic_law = r1.createKineticLaw()
     kinetic_law.setMath(math_ast)

     return writeSBMLToString(document)
```


```python
    # simulation = roadrunner.RoadRunner(
    # 'https://www.ebi.ac.uk/biomodels/model/download/BIOMD0000000010.2?filename=BIOMD0000000010_url.xml'
    # )

    # print(reaction['reaction.dbId'])
    # print(reaction['reaction.displayName'])
    # print(reaction['reactants'])
    # print(reaction['products'])

    # print(json.dumps(result, sort_keys=True, indent=4))
    # pass
    # filter(
    #     lambda result: result['inputs'] != [],
    # )
    # inputs = result['inputs']
    # products = result['outputs']
    # print(inputs)
    # print(products)

    # print(json.dumps(result, sort_keys=True, indent=4))

# for item in result:
#     print(item['path'])
# print(result)

# break
# for item in result:
#     print(item)
# print(result)

# // 'hasComponent'
# """
# MATCH (output)<-[*..1]-(ancestor)<-[*..1]-(input)
# WHERE ancestor.dbId IN COLLECT {
#     MATCH path = (n {dbId: $dbId})<-[*..5]-(a)
#     WHERE
#         (a:Event OR a:PhysicalEntity) AND
#         NONE (
#             relationship IN relationships(path)
#             WHERE type(relationship) IN ['inferredTo']
#         )
#     RETURN a.dbId
# }
# RETURN DISTINCT ancestor
# """,

# // RETURN collect({e: inEdge, p: properties(inEdge)}) AS inputs
# // RETURN collect({e: outEdge, p: properties(outEdge)}) AS outputs

# 'stoichiometry':


# fibrin_results

# max_path = max(
#     map(lambda record: record.data()['path'], query_fibrin(driver)),
#     key=lambda path: len(path),
# )

# for entity in max_path:
#     print(
#         (entity['displayName'][:80]) if 'displayName' in entity else entity
#     )

# model = create_model()
# with open('test.sbml', 'w') as file:
#     file.write(str(model))

# for record in query():
#     print(len(record.data()['path']))

# print(max_path)

# record = query()[0]
# for record in query():
# for entity in record.data()['path']:
#     print(entity)
# print(record.data()['path'])

# print(model)

# model2 = roadrunner.RoadRunner('./test.sbml')

# simulation = roadrunner.RoadRunner(
#     'https://www.ebi.ac.uk/biomodels/model/download/BIOMD0000000010.2?filename=BIOMD0000000010_url.xml'
# )
# results = simulation.simulate(start=0, end=100, points=10)

# simulation.plot()
# print(results)

# pylab.plot(results[:, 0], results[:, 1:])
# pylab.show()

# model.plot()
# model2.showPlot()
# model.plotLegend()
# print(results)

# model = roadrunner.RoadRunner('./docs/R-HSA-140877.sbml')
# results = model.simulate(start=0, end=2000, points=200)
# model.plot()
# print(results)

# driver = GraphDatabase.driver(URI, auth=AUTH)
# session = driver.session(database='neo4j')

# session.close()
# driver.close()

# print(summary)
# for key in keys:
#     print(key)
# record = records[0]
# print(record.data())
# for record in records:
#     print(record.data())

# summary = driver.execute_query(
#     """
# # CREATE (a:Person {name: $name})
# # CREATE (b:Person {name: $friendName})
# # CREATE (a)-[:KNOWS]->(b)
# """,
#     name='Alice',
#     friendName='David',
#     database_='neo4j',
# ).summary
# print(
#     'Created {nodes_created} nodes in {time} ms.'.format(
#         nodes_created=summary.counters.nodes_created,
#         time=summary.result_available_after,
#     )
# )

# records, summary, keys = driver.execute_query(
#     """
#     MATCH (p:Person)-[:KNOWS]->(:Person)
#     RETURN p.name AS name
#     """,
#     database_='neo4j',
# )

#     # Loop through results and do something with them
# for record in records:
#     print(record.data())  # obtain record as dict
#
# # Summary information
# print(
#     'The query `{query}` returned {records_count} records in {time} ms.'.format(
#         query=summary.query,
#         records_count=len(records),
#         time=summary.result_available_after,
#     )
# )

# session/driver usage
```

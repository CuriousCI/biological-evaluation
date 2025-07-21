import random
import sys
from typing import Any

import libsbml
import neo4j
import roadrunner
from libsbml import (
    SBMLDocument,
    parseL3Formula,
    writeSBMLToString,
)
from neo4j import GraphDatabase

import model

NEO4J_URL_REACTOME = 'neo4j://localhost:7687'
AUTH = ('noe4j', 'neo4j')
REACTOME_DATABASE = 'graph.db'


def create_simple_model(
    physical_entities: set[model.PhysicalEntity],
    reactions: list[model.ReactionLikeEvent],
) -> model.SBMLDocumentString | None:
    try:
        document: libsbml.SBMLDocument = SBMLDocument(3, 1)
    except ValueError:
        return None

    sbml_model: libsbml.Model = document.createModel()
    sbml_model.setTimeUnits('second')
    sbml_model.setExtentUnits('mole')
    sbml_model.setSubstanceUnits('mole')

    compartment: libsbml.Compartment = sbml_model.createCompartment()
    compartment.setId('c1')  # TODO: random UUID64, or just id
    compartment.setConstant(True)
    compartment.setSize(1)
    compartment.setSpatialDimensions(3)
    compartment.setUnits('litre')

    for physical_entity in physical_entities:
        species: libsbml.Species = sbml_model.createSpecies()
        species.setId(str(physical_entity.standard_id))
        species.setCompartment('c1')
        species.setConstant(False)
        species.setInitialAmount(random.randint(5, 100))
        species.setSubstanceUnits('mole')
        species.setBoundaryCondition(False)
        species.setHasOnlySubstanceUnits(False)

    for id, reaction in enumerate(reactions):
        sbml_reaction: libsbml.Reaction = sbml_model.createReaction()
        sbml_reaction.setId(f'r{id}')
        sbml_reaction.setReversible(False)
        sbml_reaction.setFast(False)

        for reactant in reaction.reactants:
            reactant_ref: libsbml.SpeciesReference = sbml_model.createReactant()
            reactant_ref.setSpecies(str(reactant.standard_id))
            reactant_ref.setConstant(True)
            reactant_ref.setStoichiometry(reactant.stoichiometry)

        for product in reaction.products:
            product_ref: libsbml.SpeciesReference = sbml_model.createProduct()
            product_ref.setSpecies(str(product.standard_id))
            product_ref.setConstant(True)
            product_ref.setStoichiometry(product.stoichiometry)

        math_ast = parseL3Formula(
            '('
            + ' + '.join(map(lambda r: f'{r.standard_id}', reaction.reactants))
            + ') * c1'
        )
        kinetic_law = sbml_reaction.createKineticLaw()
        kinetic_law.setMath(math_ast)

    return writeSBMLToString(document)


def query(driver: neo4j.Driver) -> list[Any]:
    # CROSSLINKED_FIBRIN_MULTIMER_REACTION_DB_ID = 158750
    PAT_DB_ID = 158754

    # records, summary, keys
    # ReactionLikeEvent -> converts inputs to outputs
    # Pathway -> grouping of events
    records, _, _ = driver.execute_query(
        """
        MATCH path = (n {dbId: $dbId})<-[*..3]-(reaction:ReactionLikeEvent)
        WHERE NONE( 
            relationship IN relationships(path) 
            WHERE type(relationship) IN [
                'author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised', 'inferredTo'
            ]
        )
        CALL { 
            WITH reaction 
            MATCH (entity)-[relationship:input]-(reaction) 
            RETURN collect({
                stId: entity.stId, 
                displayName: entity.displayName,
                stoichiometry: relationship.stoichiometry, 
                order: relationship.order
            }) AS reactants
        }
        CALL { 
            WITH reaction 
            MATCH (entity)-[relationship:output]-(reaction)
            RETURN collect({
                stId: entity.stId, 
                displayName: entity.displayName,
                stoichiometry: relationship.stoichiometry, 
                order: relationship.order 
            }) AS products
        } 
        RETURN reaction.stId AS stId, reaction.displayName AS displayName, labels(reaction), reactants, products 
        """,
        dbId=PAT_DB_ID,
        database_=REACTOME_DATABASE,
    )

    return records


if __name__ == '__main__':
    with GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME, auth=AUTH, database=REACTOME_DATABASE
    ) as driver:
        try:
            driver.verify_connectivity()
            fibrin_results = query(driver)
        except Exception as exception:
            print(exception)
            sys.exit(1)

        physical_entities = set()
        reactions = list()

        for reaction in map(lambda reaction: reaction.data(), fibrin_results):
            physical_entities = physical_entities.union(
                map(
                    lambda physical_entity: model.PhysicalEntity(
                        model.StandardId(physical_entity['stId']),
                        physical_entity['displayName'],
                    ),
                    reaction['reactants'] + reaction['products'],
                )
            )

            reactions.append(
                model.ReactionLikeEvent(
                    set(
                        map(
                            lambda reactant: model.Reactant(
                                model.StandardId(reactant['stId']),
                                reactant['displayName'],
                                model.RationalGT0(reactant['stoichiometry']),
                            ),
                            reaction['reactants'],
                        )
                    ),
                    set(
                        map(
                            lambda product: model.ReactionProduct(
                                model.StandardId(product['stId']),
                                product['displayName'],
                                model.RationalGT0(product['stoichiometry']),
                            ),
                            reaction['products'],
                        )
                    ),
                )
            )

    print(physical_entities)

    document: model.SBMLDocumentString | None = create_simple_model(
        physical_entities, reactions
    )

    if document is None:
        sys.exit(1)

    with open('test.sbml', 'w') as file:
        file.write(document)

    rr = roadrunner.RoadRunner('./test.sbml')
    result = rr.simulate(
        0,
        10,
        1000,
        ['time']
        + list(
            map(
                lambda physical_entity: str(physical_entity.standard_id),
                physical_entities,
            )
        ),
    )
    rr.plot(result=result, loc='upper left')

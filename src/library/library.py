""" """

from libsbml import SBMLDocument
import neo4j

from library.model import BiologicalSituationDefinition


# yield
# model
# instance
def yield_model_instance(model: SBMLDocument) -> SBMLDocument:
    return SBMLDocument()


# def yield_sbml_model(definition: BiologicalSituationDefinition, driver: neo4j.Driver):
#     pass


# from libsbml import SBMLDocument
# from model import BiologicalSituationDefinition
# import neo4j


# def yield_sbml_model(
#     definition: BiologicalSituationDefinition, driver: neo4j.Driver
# ) -> SBMLDocument:
#     objects = definition.model_objects(driver)
#
#     # TODO: generate the model, lel
#
#     return SBMLDocument()

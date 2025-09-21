""" """

from libsbml import SBMLDocument


# yield
# model
# instance
def yield_model_instance(model: SBMLDocument) -> SBMLDocument:
    return SBMLDocument()


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

Usage Guide
===========

TODO: check out other documentations around to learn how to write a good documentation 
for a project.

Getting Started
---------------

To get started, the first step is to define a **target scenario** from which to 
generate the the complete sbml model with the transitive closure of the reactions.

.. code-block:: python
   :linenos:

    nitric_oxide = PhysicalEntity(
        ReactomeDbId(202124),
        Interval(0.000178, 0.00024),
    )
    signal_transduction = Pathway(ReactomeDbId(162582))
    immune_system = Pathway(ReactomeDbId.from_stable_id_version("R-HSA-168256.9"))

    biological_scenario_definition: BiologicalScenarioDefinition = (
        BiologicalScenarioDefinition(
            target_physical_entities={nitric_oxide},
            target_pathways={
                signal_transduction,
                immune_system,
            },
            constraints=[f"{nitric_oxide} > 0.00024"],
        )
    )

The next step is to generate the model itself, and this requires a **connection** to a
the Reactome graph database (to install and run the Reactome graph database check  
https://reactome.org/dev/graph-database).

.. code-block:: python
   :linenos:

    biological_scenario_definition = ...

    with neo4j.GraphDatabase.driver(
        uri=NEO4J_URL_REACTOME,
        auth=AUTH,
        database=REACTOME_DATABASE,
    ) as driver:
        driver.verify_connectivity()

        sbml_document: libsbml.SBMLDocument
        virtual_patient_details: VirtualPatientDetails
        environment: Environment
        (sbml_document, virtual_patient_details, environment) = (
            biological_scenario_definition.yield_sbml_model(
                driver,
            )
        )

The :python:`yield_sbml_model()` method connects to the database, does the queries needed 
to produce the objects of the model, and builds the SBML document, generating a **template** 
for the **environment** and the **virtual patients** at the same time. 

The **description of the virtual patients** can be used to generate  
a virtual patient, and roadrunner can be used to check if the
virtual patient satisfies the constraints imposed on the system.


.. code-block:: python
   :linenos:
 
    # ...

    sbml_document: libsbml.SBMLDocument = ...
    virtual_patient_details: VirtualPatientDetails = ...
    environment: Environment = ...

    sbml_str = libsbml.writeSBMLToString(sbml_document)
    rr: roadrunner.RoadRunner = roadrunner.RoadRunner(sbml_str)

    virtual_patients = []
    for _ in range(10):
        virtual_patient: VirtualPatient = virtual_patient_details()

        if is_virtual_patient_valid(rr, virtual_patient, environment):
            virtual_patients.append(virtual_patient)


.. Installation
.. ------------
..
.. API Reference
.. -------------

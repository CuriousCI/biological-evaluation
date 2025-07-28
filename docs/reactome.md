- [bionumbers](https://bionumbers.hms.harvard.edu/search.aspx?trm=)
- [API](https://reactome.org/ContentService/#/)
- [Reactome Graph Database Documentation](https://reactome.org/dev/graph-database)
- [Reactome Data Schema](https://reactome.org/content/schema/DatabaseObject)
- [Data Model Glossary](https://download.reactome.org/documentation/DataModelGlossary_V90.pdf)
- [Neo4j & Cypher Query Language](https://neo4j.com/developer/cypher-query-language/)

- ReactionLikeEvent -> converts inputs to outputs
- Pathway -> grouping of events

PAPERS/ARTICLES:
- [neo4j efficient queries](https://pmc.ncbi.nlm.nih.gov/articles/PMC5805351/)

Reactome represents all of this complexity as reactions in which input physical entities are converted to output entities.

"Entity"

In Reactome, unmodified and modified forms of a protein are distinct physical entities and the modification process is treated as an explicit reaction.

"Cellular compartments"

In Reactome, a molecule in one compartment is distinct from that molecule in another compartment
Thus, extracellular and cytosolic glucose are different Reactome entities and, e.g., the movement of glucose across the plasma membrane is a reaction that converts the extracellular glucose entity into the cytosolic one.

The goal of the Reactome knowledgebase is to represent human biological processes, but many of these processes have not been directly studied in humans.

## Frames

The goal of the Reactome knowledgebase is to represent human biological processes, but many of these processes have not been directly studied in humans.

- classes (frames) (e.g., reaction, simple entity) 
- Knowledge is captured as instances of these classes (e.g., “glucose transport across the plasma membrane”, “cytosolic ATP”)
- slots that hold properties of the instances (e.g., the identities of the molecules that participate as inputs and outputs in a reaction)

TODO: 
- next https://reactome.org/documentation/data-model
- https://neo4j.com/docs/cypher-manual/current/introduction/

# Key data classes

## PhysicalEntity

PhysicalEntities include individual molecules, multi-molecular complexes, and sets of molecules or complexes grouped together on the basis of shared characteristics.

- Molecules are further classified as genome-encoded (DNA, RNA, and proteins) or not (all others)
- attributes capture the chemical structure of an entity, including any covalent modifications in the case of a macromolecule and its subcellular localization
- PhysicalEntity instances that represent, e.g., the same chemical in different compartments share numerous invariant features such as names, molecular structure and links to external databases like UniProt or ChEBI

- ReferenceEntity
    - captures invariant features of a molecule
    - a PhysicalEntity is a combination of ReferenceEntity + attributes giving specifical conditioanl information

- SUBCLASSSES
    - EntityWithAccessionedSequence
        - proteins and nucleic acids with known sequences.
    - GenomeEncodedEntity
        - a species-specific protein or nucleic acid whose sequence is unknown, such as an enzyme that has been characterized functionally but not yet purified and sequenced
    - SimpleEntity
        - other fully characterized molecules, e.g. nucleoplasmic ATP or cytosolic glutathione
        - https://reactome.org/content/detail/R-ALL-29358#Homo%20sapiens
    - Complex
        - a complex of two or more PhysicalEntities,
    - EntitySet
        - a set of PhysicalEntities (molecules or complexes) that function interchangeably in a given situation

## Event

the conversion of input entities to output entities in one or more steps – are the building blocks used in Reactome to represent all biological processes.

- ReactionLikeEvent
    - is an event that converts inputs into outputs
    - further division:
        - Reaction (bona fide reactions)
        - BlackBoxEvent (unbalanced reactions, like protein synthesis or degradation or shortcut reactions)
        - Polymerisation
        - Depolymerisation
- Pathway
    - is any grouping of related Events. An event may be a member of more than one Pathway.

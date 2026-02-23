// TODO: reactions marked as "reversible" are just the ones where the catalyst is involved?
// TODO: non è che la direzione inversa ha bisogno di catalizzatori !!!! ?
/ Are there reversible reactions where no enzyme is involved?:

// TODO: is it more common for a reaction to be reversible or not?
// TODO: how many reactions are not reversible in Reactome?
// TODO take a reaction which is reversible, check catalysts!
// TODO: ah, are there reactions with multiple "catalyst activity!"???
/ Is it more common for a reaction to be reversible or not? Are there reversible reactions with different objects?:


// TODO: is there a reaction which has a set and a non set to its sides?
/ Is there a reaction which involves both set and non-set physical entities?:

// TODO: create a "mega compartment" that represents those 3?
/ How should the compartments of sets be handled?: the set should be split into
    its members, thus each member has its compartments.

// TODO: some reactions have compartments
// TODO: some reactions have multiple compartments, lol... sadge
// TODO: it does matter, sadly
/ Are there reactions with multiple compartments?: yes, but they are not a
    problem for SBML.


// TODO: what happens when a species is both input and output of a reaction?
// TODO: what happens when a species is both input and output of a reaction?
// TODO: this is meant to handle species which are both reactants and products of reactions
// TODO: again the question, is there something that is both catalyst and input of reaction?
/ What happens when a physical entity is both input and output of a reaction?:

// TODO if a physicalEntity is a Complex and a component of the complex mediates the molecularFunction, that component should be identified as the activeUnit of the CatalystActivity.
// TODO: If the Regulator is a Complex, the specific Complex component(s) that play the regulatory role can be specified as activeUnit(s) of the NegativeRegulation instance.
/ How should modifiers which are complexes be handled?: this one is hard (both
    active unit and direct)

// TODO: can something be both a an enzyme and an inhibitor in a reaction
/ Can an entity be both an enzyme and a regulator in a reaction?: yes, yes it
    can.

// TODO: do all this behaviours stem from Sets?
/ Do all strange behaviours stem from sets?:

// TODO: inferredTo Doesn't need to be traversed I think, I
/ Does `inferredTo` need to be traversed?:

// TODO: check if there is "inverredTo" stuff within the same species?
/ Are there `inferredTo` reactions within the same species?:

// TODO: interesting, how can I use the reference entity? Reactome handles this using the concept of a 'reference entity', which captures the invariant features of a molecule such as its name, reference chemical structure, amino acid or nucleotide sequence (when relevant), and accession numbers in reference databases.
/ Is the `referenceEntity` useful?:

// TODO: is there a way to model directly concentrations in roadrunner?
/ Is there a way to model concentrations between in $[0, 1]$ directly in `libroadrunner`?:

// TODO: is there a reaction which takes an enzyme (catalyst activity) and gives out a complex containing the enzyme? NOPE!
/ Is there a reaction which takes an enzyme (catalyst activity) and gives out a complex containing the enzyme?:

// TODO: c'è qualcosa con più di un catalyst activity?
/ Is there a reaction with multiple catalyst activities?: Yes

// TODO: are there reactions without pathways
/ Are there reactions without pathways?:

-

```
MATCH (reaction:ReactionLikeEvent)
WHERE NOT EXISTS {
    MATCH (pathway:Pathway)--(reaction)
}
RETURN COUNT (DISTINCT reaction) // 2247
```

// TODO: are there reactions with multiple pathways?

/ Are there reactions with multiple pathways?:

```
MATCH
    (reaction:ReactionLikeEvent)--(pathway1:Pathway),
    (reaction:ReactionLikeEvent)--(pathway2:Pathway)
WHERE pathway1 <> pathway2
RETURN COUNT(DISTINCT reaction) // 4633
```

```
MATCH
    (reaction:Pathway)<-[:hasEvent]-(pathway1:Pathway),
    (reaction:Pathway)<-[:hasEvent]-(pathway2:Pathway)
CALL
    apoc.path.subgraphNodes(
        pathway,
        {
            relationshipFilter: "hasEvent",
        }
    )
    YIELD node

WHERE pathway1 <> pathway2
AND EXISTS {
    MATCH (pathway1)-[:hasEvent *]-(pathway2)
}
RETURN COUNT(DISTINCT reaction)
```

```
MATCH (pathway:Pathway)
CALL
    apoc.path.subgraphNodes(
        pathway,
        {
            relationshipFilter: "hasEvent>",
            labelFilter: ">Pathway"
        }
    )
    YIELD node
WITH pathway, COLLECT(DISTINCT node) AS reachablePathways
WHERE NOT pathway IN reachablePathways
RETURN COUNT (DISTINCT pathway) // 8274
```

```
MATCH (pathway:Pathway {:9612973})
CALL
    apoc.path.subgraphNodes(
        pathway,
        {
            relationshipFilter: "hasEvent>",
            labelFilter: ">Pathway"
        }
    )
    YIELD node
WITH pathway, COLLECT(DISTINCT node) AS reachablePathways
RETURN pathway.dbId, reachablePathways // 8274
```

// TODO:
/ Are there reversible reactions which do not share pathways?:


```
MATCH
  (reaction1:ReactionLikeEvent)-->(:CatalystActivity)-->(:PhysicalEntity)<--(:CatalystActivity)<--(reaction2:ReactionLikeEvent)
WHERE
  reaction1 <> reaction2
RETURN COUNT(DISTINCT reaction1)




MATCH (reaction:ReactionLikeEvent)
OPTIONAL MATCH path1 = (reaction)-[:input]->()
OPTIONAL MATCH path2 = (reaction)-[:output]->()
OPTIONAL MATCH path3 = (reaction)-->(:CatalystActivity)-->(:PhysicalEntity)
OPTIONAL MATCH path4 = (reaction)-->(:Regulation)-->(:PhysicalEntity)
WHERE reaction.dbId IN [113411, 112392]
RETURN path1, path2, path3, path4





OPTIONAL MATCH (reaction)-[:input]->(entity1)
OPTIONAL MATCH (reaction)-[:output]->(entity2)
OPTIONAL MATCH (reaction)-->(:CatalystActivity)-->(entity3:PhysicalEntity)
OPTIONAL MATCH (reaction)-->(:PositiveRegulation)-->(entity4:PhysicalEntity)
OPTIONAL MATCH (reaction)-->(:NegativeRegulation)-->(entity5:PhysicalEntity)
WITH
  reaction,
  entity1,
  entity2,
  entity3,
  entity4,
  entity5
  ORDER BY reaction, entity1.dbId, entity2.dbId, entity3.dbId, entity4.dbId, entity5.dbId
WITH
    reaction,
    COLLECT(DISTINCT entity1) AS e1,
    COLLECT(DISTINCT entity2) AS e2,
    COLLECT(DISTINCT entity3) AS e3,
    COLLECT(DISTINCT entity4) AS e4,
    COLLECT(DISTINCT entity5) AS e5
WITH COLLECT({r: reaction, e1: e1, e2: e2, e3: e3, e4: e4, e5: e5}) AS rects
UNWIND rects AS r1
UNWIND rects AS r2
WITH r1, r2
WHERE
    r1.r.dbId < r2.r.dbId
    AND r1.e1 = r2.e2
    AND r1.e2 = r2.e1
    AND r1.e3 = r2.e3
    AND r1.e4 = r2.e4
    AND r1.e5 = r2.e5
RETURN COUNT (DISTINCT r1.r)
```

```
MATCH (object)
WHERE
  size(apoc.coll.intersection(["PhysicalEntity"], labels(object))) <> 0
OPTIONAL MATCH (object)-[relation]->(:PhysicalEntity)
WITH object, type(relation) as type ORDER BY type
WITH DISTINCT labels(object) AS labels, COLLECT(DISTINCT type) AS types
RETURN labels, types
ORDER BY size(labels), labels, size(types), types
```

```
MATCH (object)
WHERE
  size(apoc.coll.intersection(["PhysicalEntity"], labels(object))) <> 0
OPTIONAL MATCH (object)-[relation]->(entity:PhysicalEntity)
WITH
  object,
  type(relation) as type,
  apoc.coll.subtract(
      labels(entity),
      ["DatabaseObject", "PhysicalEntity", "Trackable", "Deletable"]
  ) AS entityLabels
ORDER BY type, entityLabels
WITH DISTINCT labels(object) AS labels, COLLECT(DISTINCT [type, entityLabels]) AS types
RETURN labels, types
ORDER BY size(labels), labels, size(types), types
```

```
MATCH (object)
WHERE
  size(apoc.coll.intersection(["PhysicalEntity"], labels(object))) <> 0
UNWIND keys(object) AS key
WITH object, key ORDER BY key
WITH DISTINCT labels(object) AS labels, COLLECT(DISTINCT key) AS keys
RETURN labels, keys
ORDER BY size(labels), labels, size(keys), keys
```




```
OPTIONAL MATCH (reaction)-[relation]-(entity)
WHERE
    NOT type(relation) IN [
        "precedingEvent", "negativePrecedingEvent", "normalReaction",
        "inferredTo", "reverseReaction"
    ]
    AND size(apoc.coll.intersection(
        [
            "ControlledVocabulary", "ReviewStatus", "UpdateTracker",
            "InstanceEdit", "Publication", "LiteratureReference",
            "ExternalOntology", "EvidenceType", "URL", "Pathway",
            "Figure", "Anatomy", "Book", "MetaDatabaseObject",
            "DatabaseIdentifier", "RegulationReference",
            "CatalystActivityReference", "EntityFunctionalStatus",
            "DrugActionType", "GO_CellularComponent", "GO_Term",
            "GO_BiologicalProcess", "Species", "Taxon", "Summation",
            "Compartment"
        ],
        labels(entity)
    )) = 0
WITH
    reaction,
    apoc.coll.subtract(
        labels(entity),
        [
            "DatabaseObject", "Deletable", "Trackable",

            "ReactionLikeEvent", "Event",

            "EntitySet", "CandidateSet", "DefinedSet", "SimpleEntity",
            "EntityWithAccessionedSequence", "GenomeEncodedEntity",
            "OtherEntity", "Complex", "Disease",
            "Polymer", "ProteinDrug", "Cell", "Requirement",
            "Drug", "RNADrug", "ChemicalDrug",

            "NegativeRegulation", "PositiveRegulation",
            "NegativeGeneExpressionRegulation",
            "PositiveGeneExpressionRegulation"
        ]
    ) as labels
UNWIND labels AS label
WITH reaction, label ORDER BY label
WITH DISTINCT reaction, COLLECT(DISTINCT label) AS types
RETURN
    apoc.coll.subtract(
        labels(reaction),
        ["DatabaseObject", "Deletable", "Trackable"]
    ) AS labels,
    types,
    COUNT(*) AS cnt
ORDER BY labels DESC, size(types)
```


// WHERE pathway.dbId IN $scenario_pathways

// TODO: https://jjj.biochem.sun.ac.za/
// TODO: https://www.ebi.ac.uk/biomodels/
// TODO: https://academic.oup.com/nar/article/31/1/248/2401298
// TODO: super useful! https://pmc.ncbi.nlm.nih.gov/articles/PMC1868929/#:~:text=Reactions%20that%20are%20driven%20by%20an%20enzyme,inhibition')%20is%20known%2C%20this%20information%20is%20captured.
// TODO: WHAT I DO!! https://pmc.ncbi.nlm.nih.gov/articles/PMC5256869/
// TODO: the thing to search is "parameter estimation in biological networks"

// TODO: how to model: "association of two proteins to forma a complex", "transport of protein"
// Because the functions of biologic molecules critically depend on their subcellular locations, chemically identical entities located in different compartments are represented as distinct physical entities. For example, extracellular D-glucose and cytosolic D-glucose are distinct Reactome entities.
// TODO: what do compartments have to do in all of this?
// TODO: what better kinetic law to use?
// TODO: should I have a reaction type
// TODO: make a diagram to show all cases
// TODO: wtf is normal reaction?
// TODO: p5.js to do animation of graph, like consumption and etc...
// TODO: In the enzyme kinetics term \(k_{cat}\) (catalytic rate constant), the "cat" part stands for catalytic, referring to the enzyme's ability to catalyze (speed up) a reaction
// TODO: page 5 A reac- tion is always catalysed by a specific enzyme; we describe isoenzymes by distinct reactions.
// TODO: mi conviene modellare le "costanti di equilibrio" e le "velocità con cui si raggiungono piuttosto che k_1 e k_2?
// Beh, in questo modo posso dire: si, tu devi andare più veloce o più lento
// Oppure, si, tu devi essere di più e tu di meno
// TODO: S -> = simple decay
// TODO: is this the case for really reversible reactions???? (The enzyme may catalyze the reaction in both directions, pag 62, 4.25).
// TODO: rename into something better, like "Appendix" or "Interesting stuff"
// TODO: effector = regulator... (inhibitor and activator, vs positive and negative)
// TODO: cell designer to open SBML file
// TODO: copasi for simulations
// TODO: vcell
// 4.1.6
// Generalized Mass Action Kinetics
// TODO: other than project, define projection while keeping information? Nah
// Let's denote the concentration with [e]
// TODO: can equations be split if reversible? (check with simulation too!)

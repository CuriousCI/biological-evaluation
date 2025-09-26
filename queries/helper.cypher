// PhysicalEntity without a Compartment
MATCH (n:PhysicalEntity)
WHERE NOT EXISTS { (n)--(c:Compartment) }
RETURN n
LIMIT 10

// PhysicalEntity without a Compartment (COUNT)
MATCH (n:PhysicalEntity)
WHERE NOT EXISTS { (n)--(c:Compartment) }
RETURN COUNT(n) // 19

// PhysicalEntity with multiple Compartment
MATCH (n:PhysicalEntity)--(c1:Compartment)
WHERE
  EXISTS {
    MATCH (n)--(c2:Compartment)
    WHERE c2 <> c1
  }
RETURN n
LIMIT 10

// PhysicalEntity with multiple Compartment (COUNT)
MATCH (n:PhysicalEntity)--(c1:Compartment)
WHERE
  EXISTS {
    MATCH (n)--(c2:Compartment)
    WHERE c2 <> c1
  }
RETURN COUNT(n) // 14046

// Example entity with multiple Compartment
MATCH path = (n {dbId: 10163238})--(c:Compartment)
RETURN path

// This queries find all the types of entities which have a stIdVersion, but AREN'T PhysicalEntity or Event
MATCH (n)
WHERE
  n.stIdVersion <> '' AND
  NOT 'Event' IN labels(n) AND
  NOT 'PhysicalEntity' IN labels(n)
RETURN DISTINCT (labels(n));
// basically of of these are regulations
// ["DatabaseObject", "Deletable", "PositiveRegulation", "Regulation", "PositiveGeneExpressionRegulation"]
// ["DatabaseObject", "Deletable", "PositiveRegulation", "Regulation"]
// ["DatabaseObject", "Deletable", "Regulation", "NegativeRegulation", "NegativeGeneExpressionRegulation"]
// ["DatabaseObject", "Deletable", "Regulation", "NegativeRegulation"]
// ["DatabaseObject", "Deletable", "PositiveRegulation", "Regulation", "Requirement"]

// MAX LENGTH OF A PATH FROM PATHWAY TO REACTION
MATCH path = (r:ReactionLikeEvent)<-[:hasEvent*12..]-(p:Pathway)
RETURN path
LIMIT 1

// Pathways without anyone above, just the types, without inferredTo
MATCH (pathway:Pathway)
WHERE NOT EXISTS { (event:Event)-[:hasEvent]->(pathway) }
RETURN DISTINCT pathway.displayName

// pathway.displayName
// Autophagy
// Cell Cycle
// Complex III assembly
// Cell-Cell communication
// Cellular responses to stimuli
// Transport of small molecules
// Chromatin organization
// Circadian clock
// Developmental Biology
// Digestion and absorption
// Disease
// DNA Repair
// DNA Replication
// Drug ADME
// Extracellular matrix organization
// Gene expression (Transcription)
// Hemostasis
// Immune System
// Metabolism
// Metabolism of proteins
// Metabolism of RNA
// Muscle contraction
// Mycobacterium tuberculosis biological processes
// Neuronal System
// Organelle biogenesis and maintenance
// Programmed Cell Death
// Protein localization
// Reproduction
// Sensory Perception
// Signal Transduction
// Vesicle-mediated transport
// DNA replication and repair
// Innate Immune System
// Drosophila signaling pathways

// check if any input / output in a reaction has no stoichiometry
// It never happens that stoichiometry is null
MATCH path = (n:PhysicalEntity)-[relation:input|output]-(r:ReactionLikeEvent)
WHERE relation.stoichiometry IS NULL
RETURN path
LIMIT 1;

// check an example of reverseReaction
MATCH path = (r:ReactionLikeEvent)-[:reverseReaction]-(p:ReactionLikeEvent)
RETURN path
LIMIT 1

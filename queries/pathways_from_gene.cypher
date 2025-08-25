MATCH (n)-[:referenceDatabase]->(rd:ReferenceDatabase)
WHERE
  toLower(rd.displayName) = toLower("UniProt") AND
  (n.identifier = "P36897" OR
    n.variantIdentifier = "P36897" OR
    "P36897" IN n.geneName OR
    "P36897" IN n.name)
WITH DISTINCT n
MATCH
  (pe:PhysicalEntity)-
    [:referenceEntity|referenceSequence|crossReference|referenceGene*]->
  (n)
WITH DISTINCT pe
MATCH
  (rle:ReactionLikeEvent)-
    [:input
      |output
      |catalystActivity
      |physicalEntity
      |entityFunctionalStatus
      |diseaseEntity
      |regulatedBy
      |regulator
      |hasComponent
      |hasMember
      |hasCandidate
      |repeatedUnit*]->
  (pe)
WITH DISTINCT rle
MATCH (:Species {taxId: "9606"})<-[:species]-(p:Pathway)-[:hasEvent]->(rle)
RETURN DISTINCT p
ORDER BY p.stId

MATCH (r:ReactionLikeEvent)-[rel:input]->(p:PhysicalEntity)
CREATE (r)<-[:input_2 {stoichiometry: rel.stoichiometry, order: rel.order}]-(p);

MATCH (r:ReactionLikeEvent)<-[*]-(p:Pathway)
CREATE (r)<-[:has_event_2]-(p);

MATCH path = ({stIdVersion: 'R-ALL-202124.3'})<-[:output|input_2*6..7]-()
RETURN apoc.convert.toJson(path)
LIMIT 1;

// RESULT:
// MATCH path = (:DatabaseObject:PhysicalEntity:Trackable:Deletable:SimpleEntity {schemaClass: "SimpleEntity", oldStId: "REACT_13183", isInDisease: FALSE, displayName: "NO [cytosol]", stIdVersion: "R-ALL-202124.3", dbId: 202124, name: ["NO", "nitric oxide"], referenceType: "ReferenceMolecule", stId: "R-ALL-202124"})<-[:output {stoichiometry: 1, order: 0}]-(:DatabaseObject:Event:ReactionLikeEvent:Reaction:Trackable:Deletable {schemaClass: "Reaction", oldStId: "REACT_202556", isInDisease: FALSE, releaseDate: "2025-06-18", displayName: "Nitric Oxide Synthase (NOS) produces Nitric Oxide (NO)", stId: "R-GGA-418436", speciesName: "Gallus gallus", stIdVersion: "R-GGA-418436.1", dbId: 10689776, name: ["Nitric Oxide Synthase (NOS) produces Nitric Oxide (NO)"], category: "transition", isInferred: TRUE})<-[:input_2 {stoichiometry: 1, order: 2}]-(:DatabaseObject:PhysicalEntity:Trackable:Deletable:SimpleEntity {schemaClass: "SimpleEntity", oldStId: "REACT_5251", isInDisease: FALSE, displayName: "O2 [cytosol]", stIdVersion: "R-ALL-29368.5", dbId: 29368, name: ["O2", "Oxygen", "dioxygen"], referenceType: "ReferenceMolecule", stId: "R-ALL-29368"})<-[:output {stoichiometry: 4, order: 1}]-(:DatabaseObject:Event:ReactionLikeEvent:Reaction:Trackable:Deletable {schemaClass: "Reaction", oldStId: "REACT_327748", isInDisease: FALSE, releaseDate: "2025-06-18", displayName: "Hemoglobin A is protonated and carbamated causing release of oxygen", stId: "R-GGA-1237325", speciesName: "Gallus gallus", stIdVersion: "R-GGA-1237325.1", dbId: 10703310, name: ["Hemoglobin A is protonated and carbamated causing release of oxygen", "Bohr Effect"], category: "binding", isInferred: TRUE})<-[:input_2 {stoichiometry: 4, order: 2}]-(:DatabaseObject:PhysicalEntity:Trackable:Deletable:SimpleEntity {schemaClass: "SimpleEntity", oldStId: "REACT_2373", isInDisease: FALSE, displayName: "CO2 [cytosol]", stIdVersion: "R-ALL-113528.3", dbId: 113528, name: ["CO2", "carbon dioxide"], referenceType: "ReferenceMolecule", stId: "R-ALL-113528"})<-[:output {stoichiometry: 1, order: 1}]-(:DatabaseObject:Event:ReactionLikeEvent:Reaction:Trackable:Deletable {schemaClass: "Reaction", oldStId: "REACT_284023", isInDisease: FALSE, releaseDate: "2025-06-18", displayName: "PCK1 phosphorylates OA to yield PEP", stId: "R-MMU-70241", speciesName: "Mus musculus", stIdVersion: "R-MMU-70241.1", dbId: 9955244, name: ["PCK1 phosphorylates OA to yield PEP", "GTP + oxaloacetate => CO2 + GDP + phosphoenolpyruvate"], category: "transition", isInferred: TRUE})<-[:input_2 {stoichiometry: 1, order: 1}]-(:DatabaseObject:PhysicalEntity:Trackable:Deletable:SimpleEntity {schemaClass: "SimpleEntity", oldStId: "REACT_2875", isInDisease: FALSE, displayName: "GTP [cytosol]", stIdVersion: "R-ALL-29438.4", dbId: 29438, name: ["GTP", "Guanosine 5'-triphosphate", "GTP)(4-)"], referenceType: "ReferenceMolecule", stId: "R-ALL-29438"}) RETURN path;

// MATCH path = (n {stIdVersion: 'R-ALL-202124.3'})<-[:output|input*]-()
// RETURN path
// LIMIT 10;
// INPUT 2

MATCH
  (r:ReactionLikeEvent)--
  (c:CatalystActivity)-[:physicalEntity]-
  (p:PhysicalEntity)
CREATE (r)<-[:catalyst_2]-(p);

MATCH
  path = ({stIdVersion: 'R-ALL-202124.3'})<-[:output|input_2|catalyst_2*6..7]-()
RETURN apoc.convert.toJson(path)
LIMIT 1;

// this is a test query that actually containts catalyst
MATCH path = (p:PhysicalEntity)<-[:output|input_2|catalyst_2*10..]-()
WHERE
  ANY(
    relationship IN relationships(path) WHERE type(relationship) = 'catalyst_2'
  )
RETURN path
LIMIT 20;

// OK... I want this type of thing within signal_transduction
MATCH path = (p:PhysicalEntity)<-[:output|input_2|catalyst_2*0..3]-()
WHERE
  ANY(
    relationship IN relationships(path) WHERE type(relationship) = 'catalyst_2'
  ) AND
  ALL(
    n IN nodes(path)
    WHERE
      NOT 'ReactionLikeEvent' IN labels(n) OR (n)<-[:hasEvent*]-({dbId: 162582})
  )
RETURN path;

// TODO: create an index
// TODO: has_event_2 baby!
// TODO: what happens when instead of using stIdVersion I use id od dbId?
// TODO: how much time does it take for the creation of direct edges to work?

MATCH path = (p:PhysicalEntity)<-[:output|input_2|catalyst_2*0..3]-()
WHERE
  ALL(
    n IN nodes(path)
    WHERE
      NOT 'ReactionLikeEvent' IN labels(n) OR (n)<-[:hasEvent*]-({dbId: 162582})
  )
RETURN path;

MATCH path = (p {dbId: 202124})<-[:output|input_2|catalyst_2*0..1]-(s)
RETURN COUNT(DISTINCT s);

MATCH path = ({dbId: 202124})<-[:output|input_2|catalyst_2*0..3]-()
WHERE
  ALL(
    n IN nodes(path)
    WHERE
      NOT 'ReactionLikeEvent' IN labels(n) OR (n)<-[:hasEvent*]-({dbId: 162582})
  )
RETURN path;

MATCH path = ({dbId: 202124})<-[:output|input_2|catalyst_2*0..8]-(s)
WHERE
  ALL(
    n IN nodes(path)
    WHERE
      NOT 'ReactionLikeEvent' IN labels(n) OR (n)<-[:hasEvent*]-({dbId: 162582})
  )
RETURN COUNT(DISTINCT s);

// HOLY!!!!!
MATCH path = ({dbId: 202124})<-[:output|input_2|catalyst_2*0..7]-(s)
WHERE
  ALL(
    n IN nodes(path)
    WHERE
      NOT 'ReactionLikeEvent' IN labels(n) OR (n)<-[:hasEvent*]-({dbId: 162582})
  )
RETURN COUNT(DISTINCT s); // 100
// THIS STUFF IS WAY LESS!!
MATCH path = ({dbId: 202124})<-[:output|input_2|catalyst_2*0..7]-(s)
RETURN COUNT(DISTINCT s); // 55989

// still manageable!
MATCH path = ({dbId: 202124})<-[:output|input_2|catalyst_2*0..22]-(s)
WHERE
  ALL(
    n IN nodes(path)
    WHERE
      NOT 'ReactionLikeEvent' IN labels(n) OR (n)<-[:hasEvent*]-({dbId: 162582})
  )
RETURN COUNT(DISTINCT s);

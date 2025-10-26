MATCH
  path = (plat {dbId: 158754})-[*]-(:PhysicalEntity)<-[:output]-()-[:input]->()
WHERE ALL(node IN nodes(path) WHERE 'PhysicalEntity' IN labels(node))
RETURN DISTINCT path;

MATCH path = (plat {dbId: 158754})<-[*]-(:PhysicalEntity)
WHERE ALL(node IN nodes(path) WHERE 'PhysicalEntity' IN labels(node))
RETURN DISTINCT path;

// serine-type endopeptidases involved in novel PDGF processing [extracellular region]
// hasMember
// Plasmin [extracellular region], should I expand it too? Let's try not to.
// TODO: we can actually ignore hasMember, because they just have the same function
MATCH
  path =
    (plat {dbId: 158754})<-[:hasComponent*0..]-
    (:PhysicalEntity)--
    (:ReactionLikeEvent)-[:input]-
    ()-[:output]-
    (:ReactionLikeEvent)
RETURN path;

MATCH
  path = (plat {dbId: 158754})<-[:hasComponent*0..]-()-[:output]-()-[:input]-()
RETURN path;

MATCH
  path =
    (plat {dbId: 158754})<-[:hasComponent*0..]-
    ()-[:output]-
    ()-[:input]-
    ()<-[:hasComponent*0..]-
    ()
RETURN path;

MATCH
  path =
    (plat {dbId: 158754})<-[:hasComponent*0..]-
    ()-[:output]-
    ()-[:input]-
    ()<-[:hasComponent*0..]-
    ()-[:output]-
    ()-[:input]-
    ()
RETURN path;

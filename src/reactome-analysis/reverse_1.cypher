MATCH (reactionLikeEvent)-[:input]->(physicalEntity)
MERGE (reactionLikeEvent)<-[:reverseInput]-(physicalEntity);

MATCH (targetPathway:Pathway)
WHERE targetPathway.dbId IN [162582]
CALL
  apoc.path.subgraphNodes(
    targetPathway,
    {
      relationshipFilter: "hasEvent>",
      labelFilter: ">ReactionLikeEvent",
      bfs: true
    }
  )
  YIELD node
WITH COLLECT(node) AS speciesOfInterest
MATCH (n)
WHERE n.dbId IN [202124]
CALL
  apoc.path.subgraphNodes(
    n,
    {
      relationshipFilter: "<output|<input|catalystActivity|physicalEntity",
      labelFilter: ">ReactionLikeEvent"
    }
  )
  YIELD node
  WHERE node IN speciesOfInterest
RETURN COUNT(DISTINCT node)

// MATCH ()-[r:input]-()
// CALL apoc.refactor.invert(r) YIELD input, output

// WITH node
// MATCH ()-[r:input]-()
// CALL apoc.refactor.invert(r) YIELD input, output

MATCH (targetEntity)
WHERE targetEntity.dbId IN [202124]
CALL
  apoc.path.subgraphNodes(
    targetEntity,
    {
      relationshipFilter: "<fixedPoint",
      labelFilter: ">TargetReactionLikeEvent",
      bfs: true
    }
  )
  YIELD node
WITH COLLECT(node) AS nodes1
MATCH (targetPathway:Pathway)
WHERE targetPathway.dbId IN [162582]
CALL
  apoc.path.subgraphNodes(
    targetPathway,
    {
      relationshipFilter: "hasEvent>",
      labelFilter: ">ReactionLikeEvent",
      bfs: true
    }
  )
  YIELD node
WITH COLLECT(node) AS speciesOfInterest, nodes1
MATCH (n)
WHERE n.dbId IN [202124]
CALL
  apoc.path.subgraphNodes(
    n,
    {
      relationshipFilter: "<output|input>|catalystActivity|physicalEntity",
      labelFilter: ">ReactionLikeEvent"
    }
  )
  YIELD node
  WHERE node IN speciesOfInterest AND NOT node IN nodes1
RETURN node.dbId
LIMIT 1

// RETURN COUNT(DISTINCT node)
// RETURN COUNT(DISTINCT node)

MATCH (n1 {dbId: 202124}), (n2 {dbId: 180073})
CALL
  apoc.algo.dijkstra(
    n1,
    n2,
    "input|output|catalystActivity|physicalEntity",
    "",
    1,
    5
  )
  YIELD path, weight
RETURN path

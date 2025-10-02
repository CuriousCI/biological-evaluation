MATCH ()-[r:input]-()
CALL apoc.refactor.invert(r) YIELD input, output
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
WITH node
MATCH ()-[r:input]-()
CALL apoc.refactor.invert(r) YIELD input, output
RETURN COUNT(DISTINCT node)

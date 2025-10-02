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
RETURN COUNT(DISTINCT node)

CREATE
  (n:PhysicalEntity {name: "POTATO"})<-[:input]-
  (r:ReactionLikeEvent)-[:catalystActivity]->
  (c:CatalystActivity)-[:physicalEntity]->
  (p:PhysicalEntity)

MATCH (n)
WHERE n.name = "POTATO"
CALL
  apoc.path.subgraphNodes(
    n,
    {
      relationshipFilter: "<output|input>|catalystActivity|physicalEntity",
      labelFilter: ">ReactionLikeEvent"
    }
  )
  YIELD node
RETURN node

MATCH (n)
WHERE n.name = "POTATO"
RETURN n

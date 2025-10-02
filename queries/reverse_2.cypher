MATCH
  (physicalEntity:PhysicalEntity)<-[:input]-
  (reactionLikeEvent:ReactionLikeEvent)
MERGE (reactionLikeEvent)<-[:fixedPoint]-(physicalEntity);

MATCH
  (physicalEntity:PhysicalEntity)<-[:output]-
  (reactionLikeEvent:ReactionLikeEvent)
MERGE (physicalEntity)<-[:fixedPoint]-(reactionLikeEvent);

MATCH
  (reactionLikeEvent:ReactionLikeEvent)-->
  (:CatalystActivity)-[:physicalEntity]->
  (physicalEntity:PhysicalEntity)
MERGE (reactionLikeEvent)<-[:fixedPoint]-(physicalEntity);

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
  YIELD node AS reactionLikeEvent
SET reactionLikeEvent: TargetReactionLikeEvent;

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

// CREATE
//   (n:PhysicalEntity {name: "POTATO"})<-[:input]-
//   (r:ReactionLikeEvent)-[:catalystActivity]->
//   (c:CatalystActivity)-[:physicalEntity]->
//   (p:PhysicalEntity)
//
// MATCH (n)
// WHERE n.name = "POTATO"
// CALL
//   apoc.path.subgraphNodes(
//     n,
//     {
//       relationshipFilter: "<output|input>|catalystActivity|physicalEntity",
//       labelFilter: ">ReactionLikeEvent"
//     }
//   )
//   YIELD node
// RETURN node
//
// MATCH (n)
// WHERE n.name = "POTATO"
// RETURN n

MATCH (targetPathway:Pathway)
WHERE targetPathway.dbId IN [162582]
CALL
  apoc.path.subgraphNodes(
    targetPathway,
    {relationshipFilter: "hasEvent>", labelFilter: ">ReactionLikeEvent"}
  )
  YIELD node
WITH COLLECT(node) AS reactionsOfInterest
MATCH (n)
WHERE n.dbId IN [202124]
CALL
  apoc.path.subgraphNodes(
    n,
    {
      relationshipFilter: "<output|input>|catalystActivity>|physicalEntity>",
      labelFilter: ">ReactionLikeEvent"
    }
  )
  YIELD node
  WHERE node IN reactionsOfInterest
RETURN COUNT(DISTINCT node)

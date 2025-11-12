MATCH (reactionInput)<-[:input]-(reaction)
MERGE (reaction)<-[:fixedPoint]-(reactionInput);
MATCH (reactionOutput)<-[:output]-(reaction)
MERGE (reactionOutput)<-[:fixedPoint]-(reaction);
MATCH (reaction)-->(:CatalystActivity)-[:physicalEntity]->(physicalEntity)
MERGE (reaction)<-[:fixedPoint]-(physicalEntity);

// https://neo4j.com/docs/apoc/current/graph-refactoring/invert-relationship/
MATCH (targetPathway)
WHERE targetPathway.dbId IN [162582, 168256]
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
SET node: TargetReactionLikeEvent;

MATCH (targetSpecies)
WHERE targetSpecies.dbId IN [202124]
CALL
  apoc.path.subgraphNodes(
    targetSpecies,
    {
      relationshipFilter: "<fixedPoint",
      labelFilter: ">TargetReactionLikeEvent",
      bfs: true
    }
  )
  YIELD node AS reaction
CALL {
  WITH reaction
  MATCH (reaction)-[r:input]->(e)
  RETURN
    COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS reactants
}
CALL {
  WITH reaction
  MATCH (reaction)-[r:output]->(e)
  RETURN
    COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS products
}
CALL {
  WITH reaction
  MATCH (reaction)-->(:CatalystActivity)-[:physicalEntity]->(e)
  RETURN COLLECT({dbId: e.dbId})
}
RETURN
  apoc.convert.toJson(
    COLLECT({reaction: reaction.dbId, reactants: reactants, products: products})) AS reactions;
// apoc.convert.toJson(
//     COLLECT({})
// ) as species

MATCH (n:TargetReactionLikeEvent)
REMOVE n: TargetReactionLikeEvent;

// MATCH (targetPathway)
// WHERE targetPathway.dbId IN [162582, 168256]
// CALL
//   apoc.path.subgraphNodes(
//     targetPathway,
//     {
//       relationshipFilter: "hasEvent>",
//       labelFilter: ">ReactionLikeEvent",
//       bfs: true
//     }
//   )
//   YIELD node AS targetReaction

// WITH
//   COLLECT(DISTINCT targetReaction) AS targetReactionsSet,
//   COLLECT(DISTINCT generatingReaction) AS generatingReactionSet
// WITH
//   apoc.coll.intersection(targetReactionsSet, generatingReactionSet) AS reactions
// MATCH (reaction)
// WHERE reaction IN reactions

// MATCH (targetSpecies)
// WHERE targetSpecies.dbId IN [202124]
// CALL
//   apoc.path.subgraphNodes(
//     targetSpecies,
//     {
//       relationshipFilter: "<fixedPoint",
//       labelFilter: ">ReactionLikeEvent",
//       bfs: true
//     }
//   )
//   YIELD node AS generatingReaction
// RETURN COUNT(apoc.coll.intersection(targetReaction, generatingReaction))

// WITH COLLECT(targetReaction) AS targetReactionsSet
// MATCH (generatingReaction)
// WHERE generatingReaction IN targetReactionsSet
// RETURN COUNT(generatingReaction)
// WITH
//   COLLECT(DISTINCT targetReaction) AS targetReactionsSet,
//   COLLECT(DISTINCT generatingReaction) AS generatingReactionSet
// RETURN COUNT(apoc.coll.intersection(targetReactionsSet, generatingReactionSet))

// MATCH (reaction)
// WHERE reaction IN reactions
// CALL {
//   WITH reaction
//   MATCH (reaction)-[r:input]->(e)
//   RETURN
//     COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS reactants
// }
// CALL {
//   WITH reaction
//   MATCH (reaction)-[r:output]->(e)
//   RETURN
//     COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS products
// }
// CALL {
//   WITH reaction
//   MATCH (reaction)-->(:CatalystActivity)-[:physicalEntity]->(e)
//   RETURN COLLECT({dbId: e.dbId})
// }
// RETURN
//   apoc.convert.toJson(
//     COLLECT({reaction: reaction.dbId, reactants: reactants, products: products}));

// Subquery 1, get just the reactions in the included pathways
// Subquery 2, get all the reactions that generate the target species, intersect with the targetReactionsSubset
// Query 3, generate the list of products and reactants and catalysts of each reaction
// WITH COLLECT(DISTINCT node) AS targetReactionsSet
// COLLECT()

// WITH DISTINCT node AS interestingReactions
// RETURN
//   apoc.convert.toJson(
//     COLLECT({reaction: node.dbId, reactants: reactants, products: products}));
// CALL
//   apoc.path.subgraphNodes(
//     targetSpecies,
//     {
//       relationshipFilter: "<fixedPoint",
//       labelFilter: ">ReactionLikeEvent",
//       bfs: true
//     }
//   )
//   YIELD node

// WITH
//   reduce(
//     commonMovies = head(movies),
//     movie IN tail(movies) | apoc.coll.intersection(commonMovies, movie)) AS commonMovies

//

// MATCH (targetSpecies)
// WHERE targetSpecies.dbId IN [202124]
// CALL
//   apoc.path.subgraphNodes(
//     targetSpecies,
//     {
//       relationshipFilter: "<fixed_point_2",
//       labelFilter: ">ReactionLikeEvent",
//       bfs: true
//     }
//   )
//   YIELD node
// CALL {
//   WITH node
//   MATCH (node)-[r:input]->(e)
//   RETURN
//     COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS reactants
// }
// CALL {
//   WITH node
//   MATCH (node)-[r:output]->(e)
//   RETURN
//     COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS products
// }
// RETURN
//   apoc.convert.toJson(
//     COLLECT({reaction: node.dbId, reactants: reactants, products: products}));

// MATCH (targetSpecies)
// WHERE targetSpecies.dbId IN [202124]
// CALL
//   apoc.path.subgraphNodes(
//     targetSpecies,
//     {
//       relationshipFilter: "<fixed_point_2",
//       labelFilter: ">ReactionLikeEvent",
//       bfs: true
//     }
//   )
//   YIELD node
// RETURN DISTINCT node;

// MATCH
//   (reaction:ReactionLikeEvent)-[input:input]->(physicalEntity:PhysicalEntity)
// CREATE
//   (reaction)<-
//     [:input_ {stoichiometry: input.stoichiometry, order: input.order}]-
//   (physicalEntity);
// MATCH
//   ({dbId: 162582})-[:hasEvent*]->(reaction),
//   (reaction)<-[:input_]-(reactionInput),
//   (reaction)<-[:catalyst_]-(reactionCatalyst),
//   (reactionOutput)<-[:output]-(reaction)
// CREATE
//   (reaction)<-[:input_2]-(reactionInput),
//   (reaction)<-[:catalyst_2]-(reactionCatalyst),
//   (reactionOutput)<-[:output_2]-(reaction);
//
// MATCH (reaction:ReactionLikeEvent)-[:input]->(physicalEntity:PhysicalEntity)
// CREATE (reaction)<-[:input_]-(physicalEntity);
// MATCH
//   (reaction:ReactionLikeEvent)-->(:CatalystActivity)-[:physicalEntity]->
//   (physicalEntity:PhysicalEntity)
// CREATE (reaction)<-[:catalyst_]-(physicalEntity);
// MATCH ()
// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH DISTINCT reaction

// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH DISTINCT reaction

// MATCH
//   (reaction:ReactionLikeEvent)-->(:CatalystActivity)-[:physicalEntity]->
//   (physicalEntity:PhysicalEntity)
// CREATE (reaction)<-[:catalyst_]-(physicalEntity);

// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH DISTINCT reaction
// MATCH (targetSpecies)<-[:fixed_point_2*..3]-(reaction)
// WHERE targetSpecies.dbId IN [202124]
// RETURN COUNT(DISTINCT reaction);

// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH reaction
// MATCH (reaction)<-[:catalyst_]-(reactionCatalyst)
// CREATE (reaction)<-[:fixed_point_2]-(reactionCatalyst);

// CREATE LOOKUP INDEX node_label_lookup_index IF NOT EXISTS FOR (node) ON EACH labels (node);;
// CREATE LOOKUP INDEX rel_type_lookup_index IF NOT EXISTS FOR ()-[rel]-() ON EACH type (rel);
// CALL db.awaitIndexes(1000);

// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH DISTINCT reaction
// MATCH (reaction)
// WHERE EXISTS {
//     MATCH (targetSpecies)<-[:fixed_point_2*]-(reaction)
//     WHERE targetSpecies.dbId IN [202124]
// }
// RETURN COUNT(DISTINCT reaction);

// labelFilter: "+ReactionLikeEvent",
// minLevel: 1,
// maxLevel: 10

//   (reaction),
//   (reactionOutput)<-[:output]-(reaction)
// CREATE
//   (reaction)<-[:fixed_point_2]-(reactionInput),
//   (reaction)<-[:fixed_point_2]-(reactionCatalyst),
//   (reactionOutput)<-[:fixed_point_2]-(reaction);

// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH DISTINCT reaction
// MATCH (targetSpecies)<-[:output_2|input_2|catalyst_2*..3]-(reaction)
// WHERE targetSpecies.dbId IN [202124]
// RETURN COUNT (DISTINCT reaction);

// CREATE LOOKUP INDEX node_label_lookup_index_2 IF NOT EXISTS FOR (node) ON EACH labels (node);;
// CREATE LOOKUP INDEX rel_type_lookup_index_2 IF NOT EXISTS FOR ()-[rel]-() ON EACH type (rel);
// CALL db.awaitIndexes(1000);

// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH DISTINCT reaction
// MATCH (targetSpecies)<-[:output|input_|catalyst_*..3]-(reaction)
// WHERE targetSpecies.dbId IN [202124]
// CALL {
//   WITH reaction
//   MATCH (reaction)-[r:input]->(e)
//   RETURN
//     COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS reactants
// }
// CALL {
//   WITH reaction
//   MATCH (reaction)-[r:output]->(e)
//   RETURN
//     COLLECT({dbId: e.dbId, stoichiometry: r.stoichiometry, order: r.order}) AS products
// }
// RETURN
//   apoc.convert.toJson(
//     COLLECT(
//       DISTINCT {
//         reactionDbId: reaction.dbId,
//         reactants: reactants,
//         products: products
//       }));

// MATCH ({dbId: 162582})-[:hasEvent*]->(reaction)
// WITH DISTINCT reaction
// MATCH path= (targetSpecies)<-[:output|input_|catalyst_*..3]-(reaction)
// WHERE targetSpecies.dbId IN [202124] AND
// // ALL(node IN nodes(path) WHERE )
// RETURN COUNT (DISTINCT reaction);

// WITH [202124] AS targetSpecies
// WITH [162582] AS includedPathways
// WITH [2173793, 198753, 199920, 170670, 114508, 354192] AS ignoredPathways
// ALL(
//   node IN nodes(path)
//   WHERE
//     NOT 'ReactionLikeEvent' IN labels(node) OR
//     EXISTS {
//       MATCH (node)<-[:hasEvent*]-(pathway)
//       WHERE
//         pathway.dbId IN [162582] AND
//         NOT pathway.dbId IN [2173793, 198753, 199920, 170670, 114508, 354192]
//     }
// )

// RETURN COUNT (DISTINCT reaction)

// RETURN COUNT(DISTINCT reaction);

// reaction.stId AS stId,
// reaction.displayName AS displayName,

// ALL(
//   n IN NODES(path)
//   WHERE
//     NOT 'ReactionLikeEvent' IN labels(n) OR (n)<-[:hasEvent*]-({dbId: 162582})
// )
// EXISTS {
//   MATCH path2 = (reaction)<-[:hasEvent*]-(pathway:Pathway)
//   WHERE
//     pathway.dbId IN [162582] AND
//     NONE(
//       p IN nodes(path2)
//       WHERE p.dbId IN [2173793, 198753, 199920, 170670, 114508, 354192]
//     )
// }

// (entity)<-[relationship:output]-(reaction)
// displayName: entity.displayName,
// displayName: input.displayName,
// RETURN
//   reaction.stId AS stId,
//   reaction.displayName AS displayName,
//   reactants,
//   products

// TOOK more than 1 hour and a half
// MATCH (r:ReactionLikeEvent)<-[*]-(p:Pathway)
// CREATE (r)<-[:has_event_2]-(p);

// MATCH path = (n {dbId: $dbId})<-[*..3]-(reaction:ReactionLikeEvent)
// WHERE
//   NONE(
//     relationship IN relationships(path)
//     WHERE
//       type(relationship) IN [
//         'author',
//         'modified',
//         'edited',
//         'authored',
//         'reviewed',
//         'created',
//         'updatedInstance',
//         'revised',
//         'inferredTo'
//       ]
//   )
// CALL {
//   WITH reaction
//   MATCH (entity)-[relationship:input]-(reaction)
//   RETURN
//     collect({
//       stId: entity.stId,
//       displayName: entity.displayName,
//       stoichiometry: relationship.stoichiometry,
//       order: relationship.order
//     }) AS reactants
// }
// CALL {
//   WITH reaction
//   MATCH (entity)-[relationship:output]-(reaction)
//   RETURN
//     collect({
//       stId: entity.stId,
//       displayName: entity.displayName,
//       stoichiometry: relationship.stoichiometry,
//       order: relationship.order
//     }) AS products
// }
// RETURN
//   reaction.stId AS stId,
//   reaction.displayName AS displayName,
//   reactants,
//   products

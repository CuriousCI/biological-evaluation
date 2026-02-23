class ReactomeScope(Scope):
    @override
    def query(self) -> neo4j.Query:
        metadata: dict[str, Any] = {
            "max_depth": int(self.max_depth) if self.max_depth else -1
        }
        query: LiteralString = ""

        def _extend(
            obj: set[EntityId] | set[PathwayId] | set[ReactionId] | neo4j.Query,
            collection: Collection,
            label: LiteralString,
        ) -> None:
            nonlocal query
            nonlocal metadata

            sub_query: neo4j.Query = (
                obj
                if isinstance(obj, neo4j.Query)
                else neo4j.Query(
                    f"""
                    CALL {{
                        MATCH (node:{label})
                        WHERE node.dbId IN ${collection.name}
                        RETURN COLLECT(DISTINCT node) AS {collection.name}
                    }}
                    """,
                    {collection.name: list(map(int, obj))},
                )
            )

            query += sub_query.text
            if sub_query.metadata:
                metadata = dict(metadata, **sub_query.metadata)

        _extend(
            self.physical_entities_of_interest,
            Collection.PHYSICAL_ENTITIES_OF_INTEREST,
            "PhysicalEntity",
        )

        _extend(
            self.boundary_physical_entities,
            Collection.FRONTIER_PHYSICAL_ENTITIES,
            "PhysicalEntity",
        )

        _extend(
            self.pathways_of_interest,
            Collection.PATHWAYS_OF_INTEREST,
            "Pathway",
        )

        _extend(
            self.excluded_reactions,
            Collection.EXCLUDED_REACTIONS,
            "ReactionLikeEvent",
        )

        return neo4j.Query(
            query
            + f"""
            CALL {{
                WITH
                    {Collection.PATHWAYS_OF_INTEREST.name},
                    {Collection.EXCLUDED_REACTIONS.name}
                UNWIND {Collection.PATHWAYS_OF_INTEREST.name} AS pathway
                CALL apoc.path.subgraphNodes(
                    pathway,
                    {{
                        relationshipFilter: "hasEvent>",
                        labelFilter: ">ReactionLikeEvent"
                    }}
                )
                YIELD node
                WHERE NOT node IN {Collection.EXCLUDED_REACTIONS.name}
                RETURN COLLECT(DISTINCT node) AS reactionsOfInterest
            }}

            CALL {{
                WITH
                    {Collection.PHYSICAL_ENTITIES_OF_INTEREST.name},
                    {Collection.FRONTIER_PHYSICAL_ENTITIES.name},
                    {Collection.EXCLUDED_REACTIONS.name},
                    reactionsOfInterest
                UNWIND {Collection.PHYSICAL_ENTITIES_OF_INTEREST.name} AS physicalEntity
                CALL apoc.path.subgraphNodes(
                    physicalEntity,
                    {{
                        relationshipFilter: "<output|input>|catalystActivity>|physicalEntity>|regulatedBy>|regulator>|reverseReaction",
                        labelFilter: ">ReactionLikeEvent",
                        maxLevel: $max_depth,
                        denylistNodes: {Collection.FRONTIER_PHYSICAL_ENTITIES.name} + {Collection.EXCLUDED_REACTIONS.name}
                    }}
                )
                YIELD node
                WHERE node IN reactionsOfInterest
                RETURN COLLECT(DISTINCT node) AS reactionLikeEvents
            }}

            WITH reactionLikeEvents

            CALL {{
                WITH reactionLikeEvents
                UNWIND reactionLikeEvents AS reaction
                CALL apoc.path.subgraphNodes(
                    reaction,
                    {{
                        relationshipFilter: "input>|output>|catalystActivity>|physicalEntity>|regulatedBy>|regulator>|hasMember>|hasCandidate>",
                        labelFilter: "PhysicalEntity"
                    }}
                )
                YIELD node
                RETURN COLLECT(DISTINCT node) AS physicalEntities
            }}

            CALL {{
                WITH reactionLikeEvents
                UNWIND reactionLikeEvents AS reaction

                CALL {{
                    WITH reaction
                    MATCH (reaction)-[relation:input|output]->(physicalEntity:PhysicalEntity)
                    RETURN
                        COLLECT({{
                            dbId: physicalEntity.dbId,
                            stoichiometry: relation.stoichiometry,
                            role: CASE type(relation)
                                WHEN "input" THEN "{StoichiometricRole.REACTANT.name}"
                                WHEN "output" THEN "{StoichiometricRole.PRODUCT.name}"
                                ELSE ""
                            END
                        }}) AS participants1
                }}

                CALL {{
                    WITH reaction
                    MATCH (reaction)-[:catalystActivity]->(:CatalystActivity)-[:physicalEntity|activeUnit]->(physicalEntity:PhysicalEntity)
                    RETURN
                        COLLECT({{
                            dbId: physicalEntity.dbId,
                            role: "{ModifierRole.CATALYST.name}"
                        }}) AS participants2
                }}

                CALL {{
                    WITH reaction
                    MATCH (reaction)-[:regulatedBy]->(regulation:Regulation)-[:regulator|activeUnit]->(physicalEntity:PhysicalEntity)
                    RETURN
                        COLLECT({{
                            dbId: physicalEntity.dbId,
                            role: CASE
                                WHEN "PositiveRegulation" IN labels(regulation) THEN "{ModifierRole.POSITIVE_REGULATOR.name}"
                                WHEN "NegativeRegulation" IN labels(regulation) THEN "{ModifierRole.NEGATIVE_REGULATOR.name}"
                                ELSE ""
                            END
                        }}) AS participants3
                }}

                RETURN
                    COLLECT({{
                        dbId: reaction.dbId,
                        participants: participants1 + participants2 + participants3
                    }}) AS {Column.REACTIONS.name}
            }}

            CALL {{
                WITH physicalEntities
                UNWIND physicalEntities AS physicalEntity
                MATCH (physicalEntity)-[:compartment]->(compartment:Compartment)
                WITH physicalEntity, COLLECT(DISTINCT compartment.dbId) AS compartments
                RETURN COLLECT({{ dbId: physicalEntity.dbId, compartments: compartments }}) AS {Column.PHYSICAL_ENTITIES.name}
            }}

            CALL {{
                WITH physicalEntities, reactionLikeEvents
                UNWIND physicalEntities AS physicalEntity
                WITH physicalEntity, reactionLikeEvents
                WHERE NOT EXISTS {{
                    MATCH (reaction)-[:output]->(physicalEntity)
                    WHERE reaction IN reactionLikeEvents
                }}
                RETURN COLLECT(DISTINCT physicalEntity.dbId) AS {Column.PRODUCED_FRONTIER_ENTITIES.name}
            }}

            CALL {{
                WITH physicalEntities, reactionLikeEvents
                UNWIND physicalEntities AS physicalEntity
                WITH physicalEntity, reactionLikeEvents
                WHERE NOT EXISTS {{
                    MATCH (reaction)-[:input]->(physicalEntity)
                    WHERE reaction IN reactionLikeEvents
                }}
                RETURN COLLECT(DISTINCT physicalEntity.dbId) AS {Column.CONSUMED_FRONTIER_ENTITIES.name}
            }}

            RETURN
                {Column.REACTIONS.name},
                {Column.PHYSICAL_ENTITIES.name},
                {Column.PRODUCED_FRONTIER_ENTITIES.name},
                {Column.CONSUMED_FRONTIER_ENTITIES.name}
        """,
            metadata=metadata,
        )

        # CALL apoc.path.subgraphNodes(
        #     reaction,
        #     {{
        #         relationshipFilter: "<{StoichiometricRole.REACTANT.name}|{StoichiometricRole.PRODUCT.name}>|<{ModifierRole.CATALYST.name}|<{ModifierRole.POSITIVE_REGULATOR.name}|<{ModifierRole.NEGATIVE_REGULATOR.name}",
        #         labelFilter: "PhysicalEntity"
        #     }}
        # )
        # YIELD node


# class CollectionRecord(BaseModel):
#     id: int
#     is_ordered: bool | None
#     members1: list[int]
#     members2: list[int]


# def query_reactome_collections(driver: neo4j.Driver) -> Iterable[CollectionRecord]:
#     return driver.execute_query(
#         """
#         MATCH (collection:EntitySet)
#         CALL {
#             WITH collection
#             MATCH (collection)-[membership:hasMember|hasCandidate]->(member:PhysicalEntity)
#             WHERE
#                 (collection.isOrdered IS NULL OR collection.isOrdered = false)
#                 AND NOT "EntitySet" IN LABELS(member)
#                 AND NOT EXISTS {
#                     MATCH (member)<-[:input|output]-(:ReactionLikeEvent)
#                 }
#                 AND NOT EXISTS {
#                     MATCH (member)<-[:regulator]-(:Regulation)--(:ReactionLikeEvent)
#                 }
#                 AND NOT EXISTS {
#                     MATCH (member)<-[:physicalEntity]-(:CatalystActivity)<-[:catalystActivity]-(:ReactionLikeEvent)
#                 }
#                 AND NOT EXISTS {
#                     MATCH (member)<-[:hasMember|hasCandidate]-(collection2:EntitySet)
#                     WHERE collection <> collection2
#                 }
#             WITH member
#             ORDER BY membership.order
#             WITH DISTINCT member
#             RETURN COLLECT(member.dbId) AS members1
#         }
#         CALL {
#             WITH collection, members1
#             MATCH (collection)-[membership:hasMember|hasCandidate]->(member:PhysicalEntity)
#             WHERE NOT member.dbId IN members1
#             WITH member
#             ORDER BY membership.order
#             WITH DISTINCT member
#             RETURN COLLECT(member.dbId) AS members2
#         }
#         RETURN collection.dbId AS id, collection.isOrdered as is_ordered, members1, members2
#         """,
#         result_transformer_=transformer(CollectionRecord),
#     )


# def query_reactome_reactions(driver: neo4j.Driver) -> Iterable[ReactionRecord]:

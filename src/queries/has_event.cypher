MATCH (r:ReactionLikeEvent)<-[*]-(p:Pathway)
CREATE (r)<-[:has_event_2]-(p);

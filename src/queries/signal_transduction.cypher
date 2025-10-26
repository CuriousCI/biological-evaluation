MATCH
  path =
    (reaction:ReactionLikeEvent)-[:hasEvent*0..5]-
    (pathway:Pathway {stIdVersion: 'R-HSA-162582.13'})
RETURN COUNT(path);

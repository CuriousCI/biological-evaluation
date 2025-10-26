MATCH
  path =
    (reaction:ReactionLikeEvent)-[:hasEvent*0..5]-
    (pathway:Pathway {stIdVersion: 'R-HSA-162582.13'})
WHERE
  NONE(
    node IN nodes(path)
    WHERE
      node.stIdVersion IN [
        'R-HSA-198753.3',
        'R-HSA-199920.3',
        'R-HSA-170670.5',
        'R-HSA-114508.4',
        'R-HSA-354192.4',
        'R-HSA-2173793.6'
      ]
  )
RETURN COUNT(path);

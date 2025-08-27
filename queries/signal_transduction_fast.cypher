// CREATE INDEX TODO: test
MATCH
  path =
    (reaction:ReactionLikeEvent)-[:hasEvent*0..7]-
    (pathway:Pathway {dbId: 162582})
WHERE
  NONE(
    node IN nodes(path)
    WHERE node.dbId IN [2173793, 198753, 199920, 170670, 114508, 354192]
  )
RETURN COUNT(path);

// 'R-HSA-198753.3',
// 'R-HSA-199920.3',
// 'R-HSA-170670.5',
// 'R-HSA-114508.4',
// 'R-HSA-354192.4',
// 'R-HSA-2173793.6'

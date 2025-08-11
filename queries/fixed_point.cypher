MATCH path = (n {dbId: 158754})<-[*0..]-(r)
WHERE
  NONE(
    x IN relationships(path)
    WHERE
      type(x) IN [
        'author',
        'modified',
        'edited',
        'authored',
        'reviewed',
        'created',
        'updatedInstance',
        'revised'
      ]
  )
RETURN DISTINCT r

MATCH
  path =
    (plat {dbId: 158754})<-[:hasComponent*0..]-
    ()-[:output]-
    ()-[:input]-
    ()<-[:hasComponent*0..]-
    ()-[:output]-
    ()-[:input]-
    ()
RETURN path
LIMIT 2;

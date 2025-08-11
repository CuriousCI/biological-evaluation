MATCH (plat {dbId: 158754})-[:hasComponent*0..5]-(component:PhysicalEntity)
RETURN DISTINCT component

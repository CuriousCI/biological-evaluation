MATCH (plat {dbId: 158754})-[:hasComponent*0..]-(component:PhysicalEntity)
RETURN DISTINCT component;

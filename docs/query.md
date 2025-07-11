MATCH path = (n:PhysicalEntity)<-[*]-()
WHERE 
    n.displayName CONTAINS 'PLAT' AND 
    n.speciesName = 'Homo sapiens' AND
    NONE(x IN relationships(path) WHERE type(x) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised'])
RETURN DISTINCT path


MATCH (n:PhysicalEntity) WHERE n.displayName CONTAINS 'PLAT' AND n.speciesName = 'Homo sapiens' RETURN n


MATCH path = (:Pathway {dbId: 9612973})<-[*]-()
RETURN DISTINCT path LIMIT 10000


MATCH (n:Pathway {dbId: 9612973})<-[r]-() RETURN COUNT(r)


MATCH (n:Pathway) RETURN n LIMIT 1

MATCH (p:Person) RETURN COUNT(p) 

// 158754,


MATCH path = ({dbId: 158754})<-[*]-()
WHERE 
    NONE (node in nodes(path) WHERE node.dbId IN [381937]) AND
    NONE (relationship in relationships(path) WHERE type(relationship) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised', 'replacementInstances', 'hasEncapsulatedEvent'])
RETURN DISTINCT path

// hasComponent?

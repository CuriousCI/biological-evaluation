```python
MATCH
  path =
    (plat {dbId: 158754})<-[:hasComponent*0..5]-
    (entity)<-[:output]-
    (reaction)-[:input]->
    (reactionsInputs)
RETURN DISTINCT path
```

```python
# -e NEO4J_dbms_memory_heap_maxSize=4g

    # basically
    # 1. run container 
    # 2. start a script within the container, in which
    # 3. create the log file to solve permission problem 
    # 4. 'neo4j start' in background
    # 5. while loop that waits until 'neo4j status' returns the port / valid info
    # 6. run the query
    # 7. save the results in a file (matching the query file name or stuff like that, even just giving the name as an argument, and give it a default value)
    # 8. everyone happy!!

# query "MATCH path = (n {dbId: 158754})<-[*..12]-(r:PhysicalEntity) WHERE NONE(x IN relationships(path) WHERE type(x) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised']) RETURN DISTINCT r"

# QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r:PhysicalEntity) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r'
# QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r) WHERE ALL( x IN relationships(path) WHERE type(x) IN [\"input\", \"output\"]) RETURN DISTINCT r'
# QUERY='MATCH (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r:ReactionLikeEvent) RETURN DISTINCT r'

# NEO4J_URL_REACTOME='http://localhost:7474/db/data/transaction/commit'
# AUTH='-u neo4j:neo4j'
#
# if $run_curl_query; then 
#     QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r) RETURN DISTINCT r'
#
# NEO4J_REQUEST="
# {
#     \"statements\": [
#         {
#             \"statement\": \"$QUERY\",
#             \"resultDataContents\": [ \"row\"]
#         }
#     ]
# }
# "
#
#     curl -X POST $NEO4J_URL_REACTOME $AUTH -H 'Content-Type: application/json' -d "$NEO4J_REQUEST" | jq '.results.[0].data' 
# fi


# Run a test query using curl.
# run_curl_query=false 
        # t) run_curl_query=true
        #     cypher_file="$OPTARG";;
```

1. `QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r:PhysicalEntity) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r'`
2. `QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r'`

2. è più veloce, e da più oggetti


<!-- # TODO: use cypher-shell directly in interactive container! -->
<!---->
<!-- # QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*]-(r) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\", \"hasEncapsulatedEvent\"]) RETURN DISTINCT r' -->
<!-- # QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r' -->
<!-- # QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..18]-(r) RETURN DISTINCT r' -->

```cql
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


curl -X POST $REACTOME_NEO4J_URL $AUTH -H 'Content-Type: application/json' -d "$REQUEST" | jq . 
QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..10]-(r) 
    WHERE NONE(
        x IN relationships(path) 
        WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\", \"hasEncapsulatedEvent\"]
    ) 
    RETURN DISTINCT r'

TODO: query that gets ancestors at any depth, but excludes encapsulated events, way faster, less useful
MATCH path = ({dbId: 158754})<-[*]-()
WHERE 
    NONE (node in nodes(path) WHERE node.dbId IN [381937]) AND
    NONE (relationship in relationships(path) WHERE type(relationship) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised', 'replacementInstances', 'hasEncapsulatedEvent'])
RETURN DISTINCT path

find all the ancestors of tPA (PLAT, tissue plasminogen activator (one-chain)) up to depth 20
REQUEST='
{
    "statements": [{
        "statement": "MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..10]-(r) WHERE NONE(x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\", \"hasEncapsulatedEvent\"]) RETURN DISTINCT r",
        "resultDataContents": ["graph"]
    }]
}
'
srun --pty singularity shell --writable-tmpfs --containall --cleanenv --pid docker://public.ecr.aws/reactome/graphdb:latest
srun --pty singularity shell --writable-tmpfs -B /home/cicio_2048752/neo4j:/var/lib/neo4j docker://public.ecr.aws/reactome/graphdb:latest
srun singularity run --writable-tmpfs --net --network none docker://public.ecr.aws/reactome/graphdb:latest
```

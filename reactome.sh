#!/bin/bash

drun=false # run locally with Docker
srun=false # run on HPC cluster with slurm + singularity
query_tests=false # run a demanding test query against the DB

while getopts ":dqs" option; do
    case $option in
        d) drun=true;;
        q) query_tests=true;;
        s) srun=true;;
    esac
done

if $drun; then
    docker run -p 7474:7474 -p 7687:7687 -e NEO4J_dbms_memory_heap_maxSize=8g public.ecr.aws/reactome/graphdb:latest
fi

if $srun; then
    srun --pty singularity shell -u --overlay overlay.img docker://public.ecr.aws/reactome/graphdb:latest
fi

if $query_tests; then 
    REACTOME_NEO4J_URL='http://localhost:7474/db/data/transaction/commit'
    AUTH='-u neo4j:neo4j'

    # TODO: use cypher-shell directly in interactive container!

    # QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*]-(r) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\", \"hasEncapsulatedEvent\"]) RETURN DISTINCT r'
    # QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r'
    # QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..18]-(r) RETURN DISTINCT r'
    QUERY='EXPLAIN MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..16]-(r) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r'
    REQUEST="
    {
        \"statements\": [
            {
                \"statement\": \"$QUERY\",
                \"resultDataContents\": [ \"row\"]
            }
        ]
    }
    "

    curl -X POST $REACTOME_NEO4J_URL $AUTH -H 'Content-Type: application/json' -d "$REQUEST" | jq . 
fi


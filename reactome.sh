#!/bin/bash

run_docker=false # run locally with Docker
run_singularity=false # run on HPC cluster with slurm + singularity
run_test=false # run a demanding test query against the database

while getopts dst option; do
    case $option in
        d) run_docker=true;;
        s) run_singularity=true;;
        t) run_test=true;;
    esac
done

if $run_docker; then
    docker run -p 7474:7474 -p 7687:7687 -e NEO4J_dbms_memory_heap_maxSize=8g public.ecr.aws/reactome/graphdb:latest
fi

if $run_singularity; then
    srun --pty singularity shell -u --overlay overlay.img docker://public.ecr.aws/reactome/graphdb:latest
fi

NEO4J_URL_REACTOME='http://localhost:7474/db/data/transaction/commit'
AUTH='-u neo4j:neo4j'

NEO4J_REQUEST="
{
    \"statements\": [
        {
            \"statement\": \"$QUERY\",
            \"resultDataContents\": [ \"graph\"]
        }
    ]
}
"

if $run_test; then 
    QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..2]-(r) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT path'

    curl -X POST $NEO4J_URL_REACTOME $AUTH -H 'Content-Type: application/json' -d "$NEO4J_REQUEST" | jq . 
fi


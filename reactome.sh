#!/bin/bash

run_docker=false # run locally with Docker
run_docker_5=false # run locally with Docker using neo4j 5
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
    docker run -p 7474:7474 -p 7687:7687 -e NEO4J_dbms_memory_heap_maxSize=4g public.ecr.aws/reactome/graphdb:latest
fi

if $run_docker_5; then
    docker run --interactive --tty --rm \
        --volume=$HOME/neo4j/newdata:/data \
        --volume=$HOME/neo4j/backups:/backups \
        neo4j/neo4j-admin:2025.06.2 \
        neo4j-admin database load neo4j --from-path=/backups

    docker run --interactive --tty --rm \
        --volume=$HOME/neo4j/newdata:/data \
        neo4j:2025.06.2
fi


if $run_singularity; then
    srun --pty singularity shell -u --overlay overlay.img docker://public.ecr.aws/reactome/graphdb:latest
fi

NEO4J_URL_REACTOME='http://localhost:7474/db/data/transaction/commit'
AUTH='-u neo4j:neo4j'

if $run_test; then 
    QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r) RETURN DISTINCT r'
    # QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r:PhysicalEntity) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r'
    # QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r) WHERE ALL( x IN relationships(path) WHERE type(x) IN [\"input\", \"output\"]) RETURN DISTINCT r'
    # QUERY='MATCH (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r:ReactionLikeEvent) RETURN DISTINCT r'

NEO4J_REQUEST="
{
    \"statements\": [
        {
            \"statement\": \"$QUERY\",
            \"resultDataContents\": [ \"row\"]
        }
    ]
}
"

    curl -X POST $NEO4J_URL_REACTOME $AUTH -H 'Content-Type: application/json' -d "$NEO4J_REQUEST" | jq '.results.[0].data' 
fi


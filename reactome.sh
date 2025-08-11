#!/bin/bash

# Build reactome.sif image to run container.
build_singularity_image=false 

# Run on HPC cluster with slurm + singularity. 
# Requires reactome.sif image to be built.
run_slurm_singularity_image=false 

# Run reactome container locally with Docker.
run_local_docker_image=false 

# Run a test query using curl.
run_curl_query=false 

# Run a test query using cypher-shell within a running container.
run_cypher_query=false

# Run query with a srun job and save results. 
submit_job=false

# File containing the cypher query.
cypher_file=''

while getopts bcdstj: option; do
    case $option in
        b) build_singularity_image=true;;
        s) run_slurm_singularity_image=true;;

        d) run_local_docker_image=true;;

        # TODO: cypher_file for curl_query too, it has to be optional;
        t) run_curl_query=true;;

        # TODO: cypher_file for cypher_query too, it has to be optional;
        c) run_cypher_query=true;;

        j) submit_job=true
            cypher_file="$OPTARG";;
    esac
done

if $build_singularity_image; then
    singularity build --sandbox reactome.sif docker://public.ecr.aws/reactome/graphdb:latest
fi

if $run_slurm_singularity_image; then
    srun --pty singularity shell --userns --writable reactome.sif 
fi

if $run_local_docker_image; then
    docker run -p 7474:7474 -p 7687:7687 -e NEO4J_dbms_memory_heap_maxSize=4g public.ecr.aws/reactome/graphdb:latest
fi


NEO4J_URL_REACTOME='http://localhost:7474/db/data/transaction/commit'
AUTH='-u neo4j:neo4j'

if $run_curl_query; then 
    QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r) RETURN DISTINCT r'

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

query() {
    cypher-shell -u neo4j -p neo4j --format verbose "$1" | tail -n 1
}

if $run_cypher_query; then 
    query "MATCH path = (n {dbId: 158754})<-[*..12]-(r:PhysicalEntity) WHERE NONE(x IN relationships(path) WHERE type(x) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised']) RETURN DISTINCT r"
fi

if $submit_job; then
    # basically
    # 1. run container 
    # 2. start a script within the container, in which
    # 3. create the log file to solve permission problem 
    # 4. 'neo4j start' in background
    # 5. while loop that waits until 'neo4j status' returns the port / valid info
    # 6. run the query
    # 7. save the results in a file (matching the query file name or stuff like that, even just giving the name as an argument, and give it a default value)
    # 8. everyone happy!!
fi

# QUERY='MATCH path = (n {dbId: 158754})<-[*..12]-(r:PhysicalEntity) WHERE NONE( x IN relationships(path) WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) RETURN DISTINCT r'
# QUERY='MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r) WHERE ALL( x IN relationships(path) WHERE type(x) IN [\"input\", \"output\"]) RETURN DISTINCT r'
# QUERY='MATCH (n:PhysicalEntity {dbId: 158754})<-[*..17]-(r:ReactionLikeEvent) RETURN DISTINCT r'

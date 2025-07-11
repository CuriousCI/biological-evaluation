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
    docker run -p 7474:7474 -p 7687:7687 -e NEO4J_dbms_memory_heap_maxSize=4g public.ecr.aws/reactome/graphdb:latest
fi

if $srun; then
    srun --pty singularity shell -u --overlay overlay.img docker://public.ecr.aws/reactome/graphdb:latest
    # srun --pty singularity shell --writable-tmpfs --containall --cleanenv --pid docker://public.ecr.aws/reactome/graphdb:latest
    # srun --pty singularity shell --writable-tmpfs -B /home/cicio_2048752/neo4j:/var/lib/neo4j docker://public.ecr.aws/reactome/graphdb:latest
    # srun singularity run --writable-tmpfs --net --network none docker://public.ecr.aws/reactome/graphdb:latest
fi

if $query_tests; then 
    # TODO: use cypher-shell directly in interactive container!
    REACTOME_NEO4J_URL='http://localhost:7474/db/data/transaction/commit'
    AUTH='-u neo4j:neo4j'

    # find all the ancestors of tPA (PLAT, tissue plasminogen activator (one-chain)) up to depth 20
    REQUEST='
    {
        "statements": [{
            "statement": "
                MATCH path = (n:PhysicalEntity {dbId: 158754})<-[*1..20]-(r) 
                WHERE NONE(x IN relationships(path) 
                WHERE type(x) IN [\"author\", \"modified\", \"edited\", \"authored\", \"reviewed\", \"created\", \"updatedInstance\", \"revised\"]) 
                RETURN DISTINCT r",
            "resultDataContents": ["graph"]
        }]
    }
    '

    # TODO: query that gets ancestors at any depth, but excludes encapsulated events, way faster, less useful
    # MATCH path = ({dbId: 158754})<-[*]-()
    # WHERE 
    #     NONE (node in nodes(path) WHERE node.dbId IN [381937]) AND
    #     NONE (relationship in relationships(path) WHERE type(relationship) IN ['author', 'modified', 'edited', 'authored', 'reviewed', 'created', 'updatedInstance', 'revised', 'replacementInstances', 'hasEncapsulatedEvent'])
    # RETURN DISTINCT path

    curl $AUTH -H 'Content-Type: application/json' -X POST -d `$REQUEST` $REACTOME_NEO4J_URL
fi

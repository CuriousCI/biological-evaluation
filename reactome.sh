#!/bin/bash

# Build reactome.sif image to run container
build_reactome_sif=false 

# Run on HPC cluster with slurm + singularity
# Requires reactome.sif image to be built (./reactome.sh -b)
run_reactome_sif_with_slurm_interactive=false 

# Run reactome container locally with Docker
run_reactome_locally_with_docker=false 

# Run a query using cypher-shell within a running container
exec_cypher_query=false

# Run query with a srun job and save results
submit_job=false

# File containing the cypher query
cypher_file=''

# File in which to store a job logs
log_file='job.log'

# File in which to store the results of a query
out_file=''

while getopts bc:dl:o:qsj: option; do
    case $option in
        b) build_reactome_sif=true;;
        s) run_reactome_sif_with_slurm_interactive=true;;
        d) run_reactome_locally_with_docker=true;;

        c) exec_cypher_query=true; cypher_file="$OPTARG";;
        j) submit_job=true; cypher_file="$OPTARG";;

        l) log_file="$OPTARG";;
        o) out_file="$OPTARG";;
    esac
done

if $build_reactome_sif; then
    singularity build --sandbox reactome.sif docker://public.ecr.aws/reactome/graphdb:latest
fi

if $run_reactome_sif_with_slurm_interactive; then
    srun --pty singularity shell --writable reactome.sif 
fi

if $run_reactome_locally_with_docker; then
    docker run -p 7474:7474 -p 7687:7687  public.ecr.aws/reactome/graphdb:latest
fi


exec_query() {
    cypher-shell --debug -u neo4j -p neo4j --format verbose "$1"
}

exec_query_file() {
    cypher-shell --debug -u neo4j -p neo4j --format verbose --file $1 
}

if $exec_cypher_query; then 
    {
        time {
            touch /var/lib/neo4j/logs/neo4j.log

            export HEAP_SIZE=128g
            # export NEO4J_CONF='./neo4j.conf'

            neo4j start
            neo4j status

            iteration=1
            while ! (echo > /dev/tcp/localhost/7687) 2>/dev/null; do 
                sleep 1; 
                echo "... $iteration"
                iteration=$((iteration + 1))
            done
        }
    } 2> $log_file 

    {
        if [ -z "$out_file" ]; then 
            out_file="$cypher_file.out"
        fi

        time exec_query_file $cypher_file > $out_file
    } 2>> $log_file 
fi

if $submit_job; then
    srun singularity run --writable reactome.sif ./reactome.sh -c $cypher_file -o $out_file -l $log_file
fi

# TODO: job name based on query
# TODO: --additional-config??? Maybe not needed
# TODO: possibly log execution time, maybe use 'tee'
# neo4j-admin 
# NEO4J_CONF    Path to directory which contains neo4j.conf.
# NEO4J_DEBUG   Set to anything to enable debug output.
# NEO4J_HOME    Neo4j home directory.
# HEAP_SIZE     Set JVM maximum heap size during command execution. Takes a number and a unit, for example 512m.
# 31G suggested
# let's try 128G


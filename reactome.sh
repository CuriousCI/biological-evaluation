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

# Run query with a srun job and save results (requires cypher file)
submit_job=false

# Run query with a sbatch job and save results (requries cypher file)
submit_batch_job=false

# File containing the cypher query (requires cypher file)
cypher_file=''

# File in which to store a job logs (requires log file)
log_file=''

# File in which to store the results of a query (requires out file)
out_file=''

while getopts bc:dl:o:q:sj: option; do
    case $option in
        b) build_reactome_sif=true;;
        s) run_reactome_sif_with_slurm_interactive=true;;
        d) run_reactome_locally_with_docker=true;;

        c) exec_cypher_query=true; cypher_file="$OPTARG";;
        j) submit_job=true; cypher_file="$OPTARG";;
        q) submit_batch_job=true; cypher_file="$OPTARG";;

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
    basename="$(basename $cypher_file '.cypher')"

    if [ -z "$log_file" ]; then 
        log_file="./logs/$basename.log"
    fi

    {
        time {
            touch /var/lib/neo4j/logs/neo4j.log
            cp ./neo4j.conf /var/lib/neo4j/conf/neo4j.conf

            neo4j start
            neo4j status

            iteration=1
            while ! (echo > /dev/tcp/localhost/7687) 2>/dev/null; do 
                sleep 1; 
                echo "[$(printf "%3d" $iteration)]"
                iteration=$((iteration + 1))
            done
        }
    } 2> $log_file 

    { 
        if [ -z "$out_file" ]; then 
            out_file="./logs/$basename.out"
        fi

        time exec_query_file $cypher_file > $out_file 
    } 2>> $log_file 
fi

if $submit_job; then
    args=( "-c $cypher_file" )
    
    if [ -n "$out_file" ]; then 
        args+=( "-o $out_file" ) 
    fi

    if [ -n "$log_file" ]; then 
        args+=( "-l $log_file" ) 
    fi

    basename="$(basename $cypher_file '.cypher')"
    srun -J $basename singularity run --writable reactome.sif ./reactome.sh "${args[@]}"
fi

if $submit_batch_job; then
    args=( "-c $cypher_file" )
    
    if [ -n "$out_file" ]; then 
        args+=( "-o $out_file" ) 
    fi

    if [ -n "$log_file" ]; then 
        args+=( "-l $log_file" ) 
    fi

    echo $cypher_file
    basename="$(basename $cypher_file '.cypher')"
    echo "#!/bin/bash" > temp.job
    echo "singularity run --writable reactome.sif ./reactome.sh ${args[@]}" >> temp.job
    chmod +x temp.job
    sbatch -J $basename temp.job 
fi

# TODO: print cypher query results in JSON

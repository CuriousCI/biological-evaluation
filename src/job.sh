#!/bin/bash

set -a
source .env
set +a

cd $CLUSTER_PROJECT_PATH 
$HOME/.local/bin/uv run src/worker.py "$@"

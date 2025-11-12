#!/bin/bash

set -a
source .env
set +a

uv run src/worker.py "$@"

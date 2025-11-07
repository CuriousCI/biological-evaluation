#!/bin/bash

until 2>/dev/null >/dev/tcp/mongo/27017
do
    echo "..."
    sleep 1
done

uv run openbox/artifact/manage.py migrate && uv run openbox/artifact/manage.py runserver 0.0.0.0:8000

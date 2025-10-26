FROM debian:trixie-slim

COPY --from=docker.io/astral/uv:latest /uv /uvx /bin/

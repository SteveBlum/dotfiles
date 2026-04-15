#!/bin/bash

name="$1"

if [ -z "$name" ]; then
    echo "Usage: ./dev.sh <environment_name>"
    exit 1
fi

# Resolve script directory to an absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEV_DIR="$SCRIPT_DIR/dev"
ENV_FILE="$SCRIPT_DIR/$name.env"
DEV_INIT_SCRIPT="$SCRIPT_DIR/dev-init.sh"

dev_init_called=false

# If the given name is an existing path in the current working directory, treat it as a bind-mount workspace
if [ -d "$PWD/$name" ]; then
    export WORKSPACE_PATH="$PWD/$name"

    # Prefer a .env.last inside the dev folder, fall back to the top-level .env.last
    if [ -f "$DEV_DIR/.env.last" ]; then
        ENV_LAST="$DEV_DIR/.env.last"
    else
        ENV_LAST="$SCRIPT_DIR/.env.last"
    fi

    echo "Using bind-mounted workspace at '$WORKSPACE_PATH'. Bringing up compose (path override)..."
    docker compose --env-file "$ENV_LAST" -f "$DEV_DIR/docker-compose.yml" -f "$DEV_DIR/docker-compose.path.yml" up -d
else
    # Named-volume workspace flow
    if [ ! -f "$ENV_FILE" ]; then
        echo "Environment file $ENV_FILE not found. Initializing..."
        if [ -f "$DEV_INIT_SCRIPT" ]; then
            "$DEV_INIT_SCRIPT" "$name"
            dev_init_called=true
        else
            echo "Error: dev-init.sh not found at $DEV_INIT_SCRIPT. Cannot initialize environment."
            exit 1
        fi
    fi

    export WORKSPACE_VOLUME="$name"

    # Check if docker compose services are already running for the volume-based compose
    running_services=$(docker compose --env-file "$ENV_FILE" -f "$DEV_DIR/docker-compose.yml" -f "$DEV_DIR/docker-compose.volume.yml" ps --status running -q)

    if [ "$dev_init_called" = true ] || [ -z "$running_services" ]; then
        echo "Bringing up docker compose services (volume override)..."
        docker compose --env-file "$ENV_FILE" -f "$DEV_DIR/docker-compose.yml" -f "$DEV_DIR/docker-compose.volume.yml" up -d
    else
        echo "Docker compose services are already running."
    fi
fi

echo "Attaching to dev container..."
docker attach dev

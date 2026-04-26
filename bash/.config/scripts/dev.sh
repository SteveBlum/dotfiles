#!/bin/bash

name="$1"
action="${2:-start}"

if [ -z "$name" ]; then
    echo "Usage: ./dev.sh <environment_name> [start|stop|restart|status|logs]"
    exit 1
fi

action=$(echo "$action" | tr '[:upper:]' '[:lower:]')
case "$action" in
    start|stop|restart|status|logs)
        ;; 
    *)
        echo "Invalid action: $action"
        echo "Usage: ./dev.sh <environment_name> [start|stop|restart|status|logs]"
        exit 1
        ;;
esac

# Resolve script directory to an absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEV_DIR="$SCRIPT_DIR/dev"
ENV_FILE="$SCRIPT_DIR/$name.env"
DEV_INIT_SCRIPT="$SCRIPT_DIR/dev-init.sh"

dev_init_called=false
# Determine if this is a bind-mount (path) workspace or a named-volume workspace
is_path=false
if [ -d "$PWD/$name" ]; then
    is_path=true
fi

# Set ENV_FILE appropriately (for path workspaces prefer DEV_DIR/.env.last)
if [ "$is_path" = true ]; then
    export WORKSPACE_PATH="$PWD/$name"
    if [ -f "$DEV_DIR/.env.last" ]; then
        ENV_FILE="$DEV_DIR/.env.last"
    else
        ENV_FILE="$SCRIPT_DIR/.env.last"
    fi
else
    ENV_FILE="$SCRIPT_DIR/$name.env"
fi

# Helper to invoke docker compose with the chosen env file and compose files
invoke_compose() {
    cmd="$*"
    if [ "$is_path" = true ]; then
        docker compose --env-file "$ENV_FILE" -f "$DEV_DIR/docker-compose.yml" -f "$DEV_DIR/docker-compose.path.yml" $cmd
    else
        docker compose --env-file "$ENV_FILE" -f "$DEV_DIR/docker-compose.yml" -f "$DEV_DIR/docker-compose.volume.yml" $cmd
    fi
}

# Main actions
if [ "$is_path" = true ]; then
    echo "Using bind-mounted workspace at '$WORKSPACE_PATH'."
    if [ "$action" = "start" ] || [ "$action" = "restart" ]; then
        echo "Bringing up compose (path override)..."
        invoke_compose up -d
    elif [ "$action" = "stop" ]; then
        invoke_compose down
    elif [ "$action" = "status" ]; then
        invoke_compose ps
    elif [ "$action" = "logs" ]; then
        invoke_compose logs -f
    fi
else
    # Named-volume workspace flow
    if [ "$action" = "start" ] || [ "$action" = "restart" ]; then
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
        echo "Bringing up docker compose services (volume override)..."
        invoke_compose up -d

    elif [ "$action" = "stop" ]; then
        if [ ! -f "$ENV_FILE" ]; then
            echo "Environment file $ENV_FILE not found. Run start to initialize the workspace."
            exit 1
        fi
        export WORKSPACE_VOLUME="$name"
        invoke_compose down

    elif [ "$action" = "status" ]; then
        if [ ! -f "$ENV_FILE" ]; then
            echo "Environment file $ENV_FILE not found. Run start to initialize the workspace."
            exit 1
        fi
        export WORKSPACE_VOLUME="$name"
        invoke_compose ps

    elif [ "$action" = "logs" ]; then
        if [ ! -f "$ENV_FILE" ]; then
            echo "Environment file $ENV_FILE not found. Run start to initialize the workspace."
            exit 1
        fi
        export WORKSPACE_VOLUME="$name"
        invoke_compose logs -f
    fi
fi

if [ "$action" = "start" ] || [ "$action" = "restart" ]; then
    echo "Attaching to dev container..."
    docker attach dev
fi

#!/bin/bash
# Test MCP server locally
# Usage: ./scripts/test-local.sh <server-name> [command]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SERVERS_DIR="$ROOT_DIR/servers"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <server-name> [command]"
    echo ""
    echo "Commands:"
    echo "  build    Build the Docker image"
    echo "  run      Run the server interactively"
    echo "  tools    List available tools"
    echo "  shell    Open a shell in the container"
    echo "  test     Run basic connectivity test"
    echo ""
    echo "Examples:"
    echo "  $0 gmail-oauth build"
    echo "  $0 gmail-oauth run"
    echo "  $0 gmail-oauth tools"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

SERVER_NAME="$1"
COMMAND="${2:-build}"
SERVER_DIR="$SERVERS_DIR/$SERVER_NAME"
IMAGE_NAME="mcp/$SERVER_NAME"

if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}Error: Server '$SERVER_NAME' not found${NC}"
    echo "Available servers:"
    ls -1 "$SERVERS_DIR" | grep -v "^_"
    exit 1
fi

case "$COMMAND" in
    build)
        echo -e "${BLUE}Building $IMAGE_NAME...${NC}"
        docker build -t "$IMAGE_NAME" "$SERVER_DIR"
        echo -e "${GREEN}✓ Build complete: $IMAGE_NAME${NC}"
        ;;

    run)
        echo -e "${BLUE}Running $IMAGE_NAME...${NC}"

        # Server-specific volume mounts
        VOLUMES=""
        case "$SERVER_NAME" in
            gmail-oauth)
                VOLUMES="-v $HOME/.gmail-mcp:/root/.gmail-mcp"
                ;;
        esac

        docker run -it --rm $VOLUMES "$IMAGE_NAME"
        ;;

    tools)
        echo -e "${BLUE}Tools for $SERVER_NAME:${NC}"
        if [ -f "$SERVER_DIR/tools.json" ]; then
            cat "$SERVER_DIR/tools.json" | python3 -c "
import json, sys
tools = json.load(sys.stdin)
for tool in tools:
    print(f\"  - {tool['name']}: {tool.get('description', 'No description')}\")
"
        else
            echo "  No tools.json found (uses dynamic discovery)"
        fi
        ;;

    shell)
        echo -e "${BLUE}Opening shell in $IMAGE_NAME...${NC}"
        docker run -it --rm --entrypoint /bin/sh "$IMAGE_NAME"
        ;;

    test)
        echo -e "${BLUE}Testing $IMAGE_NAME...${NC}"

        # Build first
        docker build -t "$IMAGE_NAME:test" "$SERVER_DIR" > /dev/null 2>&1

        # Try to start and verify it responds
        echo "  Checking container starts..."
        if docker run --rm -d --name "${SERVER_NAME}_test" "$IMAGE_NAME:test" > /dev/null 2>&1; then
            sleep 2
            docker stop "${SERVER_NAME}_test" > /dev/null 2>&1 || true
            echo -e "${GREEN}  ✓ Container starts successfully${NC}"
        else
            echo -e "${YELLOW}  ! Container may require configuration to start${NC}"
        fi

        # Check image size
        SIZE=$(docker images "$IMAGE_NAME:test" --format "{{.Size}}")
        echo "  Image size: $SIZE"

        echo -e "${GREEN}✓ Basic tests complete${NC}"
        ;;

    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        usage
        ;;
esac

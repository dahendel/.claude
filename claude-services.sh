#!/bin/bash
# Claude Services Management Script
# Manages Docker-based vector database and supporting services

CLAUDE_DIR="$HOME/.claude"
COMPOSE_FILE="$CLAUDE_DIR/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     Claude Services Manager                           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker is not installed${NC}"
        echo ""
        echo "Install Docker:"
        echo "  Ubuntu/Debian: curl -fsSL https://get.docker.com | sh"
        echo "  macOS: brew install --cask docker"
        echo "  Or visit: https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        echo -e "${RED}✗ Docker daemon is not running${NC}"
        echo ""
        echo "Start Docker:"
        echo "  Linux: sudo systemctl start docker"
        echo "  macOS: Open Docker Desktop application"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}✗ Docker Compose is not installed${NC}"
        echo ""
        echo "Install Docker Compose:"
        echo "  https://docs.docker.com/compose/install/"
        exit 1
    fi
}

get_compose_cmd() {
    if docker compose version &> /dev/null 2>&1; then
        echo "docker compose"
    else
        echo "docker-compose"
    fi
}

start_services() {
    print_header
    echo -e "${BLUE}Starting Claude services...${NC}"
    echo ""

    check_docker

    # Create necessary directories
    mkdir -p "$CLAUDE_DIR/chroma-data"
    mkdir -p "$CLAUDE_DIR/qdrant-data"
    mkdir -p "$CLAUDE_DIR/ollama-data"

    COMPOSE_CMD=$(get_compose_cmd)

    cd "$CLAUDE_DIR"
    $COMPOSE_CMD up -d

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Services started successfully${NC}"
        echo ""

        # Wait for health check
        echo "Waiting for services to be healthy..."
        sleep 5

        # Check status
        $COMPOSE_CMD ps

        echo ""
        echo -e "${GREEN}Services are running!${NC}"
        echo ""
        echo "Access points:"
        echo "  Chroma API:  http://localhost:8000"
        echo "  Chroma UI:   http://localhost:8000/api/v1"

        # Check if other services are running
        if docker ps --format '{{.Names}}' | grep -q claude-qdrant; then
            echo "  Qdrant API:  http://localhost:6333"
            echo "  Qdrant UI:   http://localhost:6333/dashboard"
        fi

        if docker ps --format '{{.Names}}' | grep -q claude-ollama; then
            echo "  Ollama API:  http://localhost:11434"
        fi

        echo ""
        echo "Next steps:"
        echo "  1. Test connection: curl http://localhost:8000/api/v1/heartbeat"
        echo "  2. Initialize collections: claude-init-db"
        echo "  3. Configure MCP: claude-setup-mcp"
    else
        echo -e "${RED}✗ Failed to start services${NC}"
        echo ""
        echo "Check logs with: claude-services logs"
        exit 1
    fi
}

stop_services() {
    print_header
    echo -e "${YELLOW}Stopping Claude services...${NC}"
    echo ""

    check_docker

    COMPOSE_CMD=$(get_compose_cmd)

    cd "$CLAUDE_DIR"
    $COMPOSE_CMD down

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Services stopped${NC}"
    else
        echo -e "${RED}✗ Failed to stop services${NC}"
        exit 1
    fi
}

restart_services() {
    print_header
    echo -e "${BLUE}Restarting Claude services...${NC}"
    echo ""

    stop_services
    sleep 2
    start_services
}

status_services() {
    print_header
    echo -e "${BLUE}Service Status:${NC}"
    echo ""

    check_docker

    COMPOSE_CMD=$(get_compose_cmd)

    cd "$CLAUDE_DIR"
    $COMPOSE_CMD ps

    echo ""
    echo -e "${BLUE}Container Details:${NC}"
    echo ""

    # Check Chroma
    if docker ps --format '{{.Names}}' | grep -q claude-chroma; then
        echo -e "${GREEN}✓ Chroma${NC} - Running"
        chroma_health=$(curl -s http://localhost:8000/api/v1/heartbeat 2>/dev/null)
        if [ -n "$chroma_health" ]; then
            echo "  Health: OK"
        else
            echo -e "  Health: ${YELLOW}Unreachable${NC}"
        fi

        # Get collection count
        collections=$(curl -s http://localhost:8000/api/v1/collections 2>/dev/null | grep -o '"id"' | wc -l)
        echo "  Collections: $collections"
    else
        echo -e "${RED}✗ Chroma${NC} - Not running"
    fi

    echo ""

    # Check Qdrant (if enabled)
    if docker ps --format '{{.Names}}' | grep -q claude-qdrant; then
        echo -e "${GREEN}✓ Qdrant${NC} - Running"
        echo "  API: http://localhost:6333"
    fi

    # Check Ollama (if enabled)
    if docker ps --format '{{.Names}}' | grep -q claude-ollama; then
        echo -e "${GREEN}✓ Ollama${NC} - Running"
        echo "  API: http://localhost:11434"
    fi

    echo ""
    echo -e "${BLUE}Data Volumes:${NC}"
    du -sh "$CLAUDE_DIR/chroma-data" 2>/dev/null | awk '{print "  Chroma: " $1}'
    du -sh "$CLAUDE_DIR/qdrant-data" 2>/dev/null | awk '{print "  Qdrant: " $1}'
    du -sh "$CLAUDE_DIR/ollama-data" 2>/dev/null | awk '{print "  Ollama: " $1}'
}

logs_services() {
    print_header
    echo -e "${BLUE}Service Logs:${NC}"
    echo ""

    check_docker

    COMPOSE_CMD=$(get_compose_cmd)

    cd "$CLAUDE_DIR"

    if [ -n "$1" ]; then
        # Follow logs for specific service
        $COMPOSE_CMD logs -f "$1"
    else
        # Show recent logs for all services
        $COMPOSE_CMD logs --tail=50
        echo ""
        echo "To follow logs: claude-services logs -f"
        echo "For specific service: claude-services logs chroma"
    fi
}

test_connection() {
    print_header
    echo -e "${BLUE}Testing Service Connections:${NC}"
    echo ""

    # Test Chroma
    echo -n "Chroma API... "
    if curl -s -f http://localhost:8000/api/v1/heartbeat > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"

        # Get version
        version=$(curl -s http://localhost:8000/api/v1/version 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$version" ]; then
            echo "  Version: $version"
        fi

        # List collections
        echo -n "  Collections: "
        curl -s http://localhost:8000/api/v1/collections 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, list):
        print(f'{len(data)} found')
        for coll in data[:3]:
            print(f\"    - {coll.get('name', 'unknown')}\")
    else:
        print('0 found')
except:
    print('Error reading')
" 2>/dev/null || echo "Unable to read"
    else
        echo -e "${RED}✗ Failed${NC}"
        echo "  Make sure services are running: claude-services start"
    fi

    echo ""

    # Test Qdrant if running
    if docker ps --format '{{.Names}}' | grep -q claude-qdrant; then
        echo -n "Qdrant API... "
        if curl -s -f http://localhost:6333/health > /dev/null 2>&1; then
            echo -e "${GREEN}✓ OK${NC}"
        else
            echo -e "${RED}✗ Failed${NC}"
        fi
        echo ""
    fi

    # Test Ollama if running
    if docker ps --format '{{.Names}}' | grep -q claude-ollama; then
        echo -n "Ollama API... "
        if curl -s -f http://localhost:11434/api/tags > /dev/null 2>&1; then
            echo -e "${GREEN}✓ OK${NC}"

            # List models
            models=$(curl -s http://localhost:11434/api/tags 2>/dev/null | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
            if [ -n "$models" ]; then
                echo "  Models installed:"
                echo "$models" | while read model; do
                    echo "    - $model"
                done
            else
                echo "  No models installed yet"
                echo "  Install: docker exec claude-ollama ollama pull nomic-embed-text"
            fi
        else
            echo -e "${RED}✗ Failed${NC}"
        fi
    fi
}

clean_data() {
    print_header
    echo -e "${YELLOW}⚠️  Clean Data Volumes${NC}"
    echo ""
    echo "This will DELETE all data from:"
    echo "  - Vector databases (Chroma/Qdrant)"
    echo "  - Ollama models"
    echo ""
    echo "Backups in ~/.claude/backups will NOT be affected."
    echo ""
    echo -n "Are you sure? Type 'yes' to confirm: "
    read confirm

    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi

    echo ""
    echo "Stopping services..."
    stop_services

    echo ""
    echo "Removing data volumes..."
    rm -rf "$CLAUDE_DIR/chroma-data"/*
    rm -rf "$CLAUDE_DIR/qdrant-data"/*
    rm -rf "$CLAUDE_DIR/ollama-data"/*

    echo ""
    echo -e "${GREEN}✓ Data volumes cleaned${NC}"
    echo ""
    echo "Restart services: claude-services start"
}

show_help() {
    print_header
    echo "Usage: claude-services [command]"
    echo ""
    echo "Commands:"
    echo "  start      Start all services"
    echo "  stop       Stop all services"
    echo "  restart    Restart all services"
    echo "  status     Show service status"
    echo "  logs       Show service logs"
    echo "  logs -f    Follow service logs"
    echo "  test       Test service connections"
    echo "  clean      Clean all data volumes (DESTRUCTIVE)"
    echo ""
    echo "Examples:"
    echo "  claude-services start"
    echo "  claude-services status"
    echo "  claude-services logs chroma"
    echo "  claude-services test"
}

# Main command handler
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        status_services
        ;;
    logs)
        shift
        logs_services "$@"
        ;;
    test)
        test_connection
        ;;
    clean)
        clean_data
        ;;
    *)
        show_help
        ;;
esac

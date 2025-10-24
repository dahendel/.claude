#!/bin/bash
# Setup Auto-start for Claude Vector Database
# Supports Linux (systemd) and macOS (LaunchAgent)

set -e

CLAUDE_DIR="$HOME/.claude"
SERVICE_FILE="$CLAUDE_DIR/config/claude-docker.service"
PLIST_FILE="$CLAUDE_DIR/config/com.claude.docker.plist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     Claude Auto-start Setup                           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

setup_linux() {
    echo -e "${BLUE}Setting up systemd service...${NC}"

    # Create user systemd directory
    mkdir -p ~/.config/systemd/user

    # Copy service file
    cp "$SERVICE_FILE" ~/.config/systemd/user/claude-docker.service

    # Reload systemd
    systemctl --user daemon-reload

    # Enable service
    systemctl --user enable claude-docker.service

    # Start service
    systemctl --user start claude-docker.service

    echo -e "${GREEN}✓ Systemd service installed and started${NC}"
    echo ""
    echo "Useful commands:"
    echo "  systemctl --user status claude-docker    # Check status"
    echo "  systemctl --user stop claude-docker      # Stop service"
    echo "  systemctl --user restart claude-docker   # Restart service"
    echo "  systemctl --user disable claude-docker   # Disable auto-start"
    echo "  journalctl --user -u claude-docker       # View logs"
}

setup_macos() {
    echo -e "${BLUE}Setting up LaunchAgent...${NC}"

    # Create LaunchAgents directory
    mkdir -p ~/Library/LaunchAgents

    # Expand ~ in plist file and copy
    sed "s|~|$HOME|g" "$PLIST_FILE" > ~/Library/LaunchAgents/com.claude.docker.plist

    # Load the agent
    launchctl load ~/Library/LaunchAgents/com.claude.docker.plist

    echo -e "${GREEN}✓ LaunchAgent installed and loaded${NC}"
    echo ""
    echo "Useful commands:"
    echo "  launchctl list | grep claude             # Check status"
    echo "  launchctl stop com.claude.docker         # Stop service"
    echo "  launchctl start com.claude.docker        # Start service"
    echo "  launchctl unload ~/Library/LaunchAgents/com.claude.docker.plist  # Disable"
    echo "  cat /tmp/claude-docker.log               # View logs"
}

remove_linux() {
    echo -e "${YELLOW}Removing systemd service...${NC}"

    systemctl --user stop claude-docker.service 2>/dev/null || true
    systemctl --user disable claude-docker.service 2>/dev/null || true
    rm -f ~/.config/systemd/user/claude-docker.service
    systemctl --user daemon-reload

    echo -e "${GREEN}✓ Systemd service removed${NC}"
}

remove_macos() {
    echo -e "${YELLOW}Removing LaunchAgent...${NC}"

    launchctl unload ~/Library/LaunchAgents/com.claude.docker.plist 2>/dev/null || true
    rm -f ~/Library/LaunchAgents/com.claude.docker.plist

    echo -e "${GREEN}✓ LaunchAgent removed${NC}"
}

print_header

OS=$(detect_os)

case "${1:-install}" in
    install)
        if [[ "$OS" == "linux" ]]; then
            setup_linux
        elif [[ "$OS" == "macos" ]]; then
            setup_macos
        else
            echo -e "${RED}✗ Unsupported OS: $OSTYPE${NC}"
            exit 1
        fi
        ;;

    remove|uninstall)
        if [[ "$OS" == "linux" ]]; then
            remove_linux
        elif [[ "$OS" == "macos" ]]; then
            remove_macos
        else
            echo -e "${RED}✗ Unsupported OS: $OSTYPE${NC}"
            exit 1
        fi
        ;;

    status)
        if [[ "$OS" == "linux" ]]; then
            systemctl --user status claude-docker.service
        elif [[ "$OS" == "macos" ]]; then
            launchctl list | grep claude || echo "Service not running"
            echo ""
            echo "Recent logs:"
            tail -20 /tmp/claude-docker.log 2>/dev/null || echo "No logs found"
        fi
        ;;

    *)
        echo "Usage: $0 {install|remove|status}"
        echo ""
        echo "Commands:"
        echo "  install  - Install auto-start service"
        echo "  remove   - Remove auto-start service"
        echo "  status   - Check service status"
        exit 1
        ;;
esac

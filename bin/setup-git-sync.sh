#!/bin/bash
# Setup Git Auto-sync for Claude Environment
# Supports cron (Linux) and launchd (macOS)

set -e

CLAUDE_DIR="$HOME/.claude"
SYNC_SCRIPT="$CLAUDE_DIR/bin/git-auto-sync.sh"
LAUNCHD_PLIST="$CLAUDE_DIR/config/com.claude.git-sync.plist"
CRON_JOB="0 */4 * * * $SYNC_SCRIPT >> $CLAUDE_DIR/data/git-sync-cron.log 2>&1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     Claude Git Auto-sync Setup                        ${BLUE}║${NC}"
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

check_git_repo() {
    cd "$CLAUDE_DIR"
    if [ ! -d ".git" ]; then
        echo -e "${RED}✗ Not a git repository${NC}"
        echo ""
        echo "Initialize git first:"
        echo "  cd ~/.claude"
        echo "  git init"
        echo "  git remote add origin git@github.com:USERNAME/.claude.git"
        exit 1
    fi

    if ! git remote -v | grep -q "origin"; then
        echo -e "${RED}✗ No git remote configured${NC}"
        echo ""
        echo "Add a remote first:"
        echo "  cd ~/.claude"
        echo "  git remote add origin git@github.com:USERNAME/.claude.git"
        exit 1
    fi

    echo -e "${GREEN}✓ Git repository configured${NC}"
}

create_launchd_plist() {
    cat > "$LAUNCHD_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.git-sync</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SYNC_SCRIPT</string>
    </array>

    <key>StartInterval</key>
    <integer>14400</integer>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>$CLAUDE_DIR/data/git-sync-launchd.log</string>

    <key>StandardErrorPath</key>
    <string>$CLAUDE_DIR/data/git-sync-launchd.err</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF
}

setup_linux() {
    echo -e "${BLUE}Setting up cron job...${NC}"

    # Check if cron is available
    if ! command -v crontab &> /dev/null; then
        echo -e "${RED}✗ crontab not found${NC}"
        echo "Install cron: sudo apt-get install cron"
        exit 1
    fi

    # Check if job already exists
    if crontab -l 2>/dev/null | grep -q "git-auto-sync.sh"; then
        echo -e "${YELLOW}! Cron job already exists${NC}"
        echo ""
        read -p "Replace existing job? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Keeping existing cron job"
            exit 0
        fi
        # Remove old job
        crontab -l 2>/dev/null | grep -v "git-auto-sync.sh" | crontab -
    fi

    # Add new job
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

    echo -e "${GREEN}✓ Cron job installed${NC}"
    echo ""
    echo "Schedule: Every 4 hours"
    echo "Log file: $CLAUDE_DIR/data/git-sync-cron.log"
    echo ""
    echo "Useful commands:"
    echo "  crontab -l                           # View cron jobs"
    echo "  crontab -e                           # Edit cron jobs"
    echo "  tail -f $CLAUDE_DIR/data/git-sync.log  # View sync logs"
    echo "  $SYNC_SCRIPT                         # Run sync manually"
}

setup_macos() {
    echo -e "${BLUE}Setting up LaunchAgent...${NC}"

    # Create LaunchAgents directory
    mkdir -p ~/Library/LaunchAgents

    # Create plist file
    create_launchd_plist

    # Copy to LaunchAgents
    cp "$LAUNCHD_PLIST" ~/Library/LaunchAgents/com.claude.git-sync.plist

    # Load the agent
    launchctl unload ~/Library/LaunchAgents/com.claude.git-sync.plist 2>/dev/null || true
    launchctl load ~/Library/LaunchAgents/com.claude.git-sync.plist

    echo -e "${GREEN}✓ LaunchAgent installed and loaded${NC}"
    echo ""
    echo "Schedule: Every 4 hours"
    echo "Log file: $CLAUDE_DIR/data/git-sync-launchd.log"
    echo ""
    echo "Useful commands:"
    echo "  launchctl list | grep claude-git            # Check status"
    echo "  launchctl start com.claude.git-sync         # Run now"
    echo "  tail -f $CLAUDE_DIR/data/git-sync.log       # View logs"
    echo "  $SYNC_SCRIPT                                # Run sync manually"
}

remove_linux() {
    echo -e "${YELLOW}Removing cron job...${NC}"

    if crontab -l 2>/dev/null | grep -q "git-auto-sync.sh"; then
        crontab -l 2>/dev/null | grep -v "git-auto-sync.sh" | crontab -
        echo -e "${GREEN}✓ Cron job removed${NC}"
    else
        echo "No cron job found"
    fi
}

remove_macos() {
    echo -e "${YELLOW}Removing LaunchAgent...${NC}"

    launchctl unload ~/Library/LaunchAgents/com.claude.git-sync.plist 2>/dev/null || true
    rm -f ~/Library/LaunchAgents/com.claude.git-sync.plist

    echo -e "${GREEN}✓ LaunchAgent removed${NC}"
}

test_sync() {
    echo -e "${BLUE}Testing git sync...${NC}"
    echo ""

    if [ ! -x "$SYNC_SCRIPT" ]; then
        echo -e "${RED}✗ Sync script not executable${NC}"
        exit 1
    fi

    echo "Running sync script..."
    if bash "$SYNC_SCRIPT"; then
        echo ""
        echo -e "${GREEN}✓ Sync test successful${NC}"
        echo ""
        echo "View logs:"
        echo "  tail -20 $CLAUDE_DIR/data/git-sync.log"
    else
        echo ""
        echo -e "${RED}✗ Sync test failed${NC}"
        echo "Check logs: tail -20 $CLAUDE_DIR/data/git-sync.log"
        exit 1
    fi
}

print_header

OS=$(detect_os)

case "${1:-install}" in
    install)
        check_git_repo
        echo ""

        if [[ "$OS" == "linux" ]]; then
            setup_linux
        elif [[ "$OS" == "macos" ]]; then
            setup_macos
        else
            echo -e "${RED}✗ Unsupported OS: $OSTYPE${NC}"
            exit 1
        fi

        echo ""
        echo -e "${BLUE}Testing sync...${NC}"
        test_sync
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

    test)
        check_git_repo
        test_sync
        ;;

    status)
        if [[ "$OS" == "linux" ]]; then
            echo "Cron jobs:"
            crontab -l 2>/dev/null | grep "git-auto-sync" || echo "No cron job found"
        elif [[ "$OS" == "macos" ]]; then
            echo "LaunchAgents:"
            launchctl list | grep claude-git || echo "No LaunchAgent found"
        fi
        echo ""
        echo "Recent sync logs:"
        tail -20 "$CLAUDE_DIR/data/git-sync.log" 2>/dev/null || echo "No logs found"
        ;;

    *)
        echo "Usage: $0 {install|remove|test|status}"
        echo ""
        echo "Commands:"
        echo "  install  - Install auto-sync (cron/launchd)"
        echo "  remove   - Remove auto-sync"
        echo "  test     - Test sync manually"
        echo "  status   - Check sync status and logs"
        exit 1
        ;;
esac

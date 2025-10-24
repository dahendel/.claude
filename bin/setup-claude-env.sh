#!/usr/bin/env bash
#
# Claude Environment Setup Script
# Supports: macOS (arm64/x86_64), Linux (x86_64)
# Usage: curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/setup-claude-env.sh | bash
#        OR: bash setup-claude-env.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Environment Setup                                  ║${NC}"
echo -e "${BLUE}║  OS: ${OS} | Arch: ${ARCH}                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Normalize architecture
case "$ARCH" in
    x86_64|amd64)
        ARCH="x86_64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        ;;
    *)
        echo -e "${RED}✗ Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user
prompt_yes_no() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Create directory structure
echo -e "${YELLOW}→ Creating directory structure...${NC}"
mkdir -p ~/.claude/{chroma-data,backups}
echo -e "${GREEN}✓ Directories created${NC}"

# Detect shell
SHELL_TYPE="unknown"
if [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif command_exists fish; then
    SHELL_TYPE="fish"
fi

echo -e "${BLUE}→ Detected shell: $SHELL_TYPE${NC}"

# Check for existing CLAUDE.md
if [ -f ~/.claude/CLAUDE.md ]; then
    echo -e "${YELLOW}! Found existing ~/.claude/CLAUDE.md${NC}"
    if prompt_yes_no "Backup and update CLAUDE.md?"; then
        cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}✓ Backed up existing CLAUDE.md${NC}"
    else
        echo -e "${YELLOW}→ Skipping CLAUDE.md update${NC}"
    fi
fi

# Install Docker if needed
echo ""
echo -e "${YELLOW}→ Checking Docker installation...${NC}"
if ! command_exists docker; then
    echo -e "${RED}✗ Docker not found${NC}"
    if [ "$OS" = "darwin" ]; then
        echo -e "${YELLOW}  Install Docker Desktop from: https://www.docker.com/products/docker-desktop${NC}"
    elif [ "$OS" = "linux" ]; then
        echo -e "${YELLOW}  Install Docker with:${NC}"
        echo "  curl -fsSL https://get.docker.com | sh"
        echo "  sudo usermod -aG docker $USER"
        echo "  newgrp docker"
    fi
    if ! prompt_yes_no "Continue without Docker?"; then
        exit 1
    fi
else
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}! Docker is installed but not running${NC}"
        if [ "$OS" = "darwin" ]; then
            echo -e "${YELLOW}  Start Docker Desktop and run this script again${NC}"
        fi
    else
        echo -e "${GREEN}✓ Docker is installed and running${NC}"
    fi
fi

# Install Python if needed
echo ""
echo -e "${YELLOW}→ Checking Python installation...${NC}"
if ! command_exists python3; then
    echo -e "${RED}✗ Python 3 not found${NC}"
    if [ "$OS" = "darwin" ]; then
        if command_exists brew; then
            if prompt_yes_no "Install Python via Homebrew?"; then
                brew install python3
            fi
        else
            echo -e "${YELLOW}  Install Homebrew first: https://brew.sh${NC}"
            echo -e "${YELLOW}  Then run: brew install python3${NC}"
        fi
    elif [ "$OS" = "linux" ]; then
        echo -e "${YELLOW}  Install with: sudo apt-get install python3 python3-pip${NC}"
    fi
else
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python installed: $PYTHON_VERSION${NC}"
fi

# Install required Python packages
if command_exists python3; then
    echo -e "${YELLOW}→ Installing Python dependencies...${NC}"
    python3 -m pip install --user --quiet chromadb requests 2>/dev/null || true
    echo -e "${GREEN}✓ Python packages installed${NC}"
fi

# Download or copy Claude environment files
echo ""
echo -e "${YELLOW}→ Setting up Claude environment files...${NC}"

# Check if we're running from the repo
if [ -f "$(dirname "$0")/aliases.fish" ]; then
    SOURCE_DIR="$(dirname "$0")"
    echo -e "${BLUE}  Using local files from: $SOURCE_DIR${NC}"

    # Copy files
    for file in aliases.fish aliases.sh manage-context.sh claude-services.sh \
                init-vectordb.py monitor.py docker-compose.yml \
                CLAUDE.md DOCKER_SETUP.md FISH_SETUP.md OPENTOFU_ALIASES.md; do
        if [ -f "$SOURCE_DIR/$file" ]; then
            cp "$SOURCE_DIR/$file" ~/.claude/
            [ "${file##*.}" = "sh" ] || [ "${file##*.}" = "py" ] && chmod +x ~/.claude/$file
            echo -e "${GREEN}  ✓ Copied $file${NC}"
        fi
    done
else
    echo -e "${YELLOW}  Files must be copied manually or from repository${NC}"
fi

# Configure shell based on detected shell type
echo ""
echo -e "${YELLOW}→ Configuring shell integration...${NC}"

case "$SHELL_TYPE" in
    fish)
        FISH_CONFIG="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$FISH_CONFIG")"

        # Check if already configured
        if grep -q "Claude Code Environment" "$FISH_CONFIG" 2>/dev/null; then
            echo -e "${YELLOW}! Fish shell already configured${NC}"
            if prompt_yes_no "Reconfigure Fish shell?"; then
                # Backup and remove old config
                cp "$FISH_CONFIG" "${FISH_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
                sed -i.bak '/# ===.*Claude Code Environment/,/# ===.*End Claude Code Environment/d' "$FISH_CONFIG"
                sed -i.bak '/# ===.*OpenTofu Aliases/,/# ===.*End OpenTofu Aliases/d' "$FISH_CONFIG"
            else
                echo -e "${YELLOW}→ Skipping Fish configuration${NC}"
                SHELL_TYPE="skip"
            fi
        fi

        if [ "$SHELL_TYPE" = "fish" ]; then
            cat >> "$FISH_CONFIG" << 'EOF'

# ============================================================
# Claude Code Environment - Auto-start Vector Database
# ============================================================

# Auto-start Docker vector database (one-time per session with timeout protection)
if status is-interactive; and not set -q CLAUDE_DOCKER_CHECKED
    set -g CLAUDE_DOCKER_CHECKED 1

    # Background job to start Docker (non-blocking, with timeout)
    fish -c '
        # Quick timeout check - give Docker 2 seconds max
        if timeout 2s docker info >/dev/null 2>&1
            if not docker ps --format "{{.Names}}" 2>/dev/null | grep -q claude-chroma
                echo "🚀 Starting Claude vector database..." >&2
                timeout 5s ~/.claude/claude-services.sh start >/dev/null 2>&1 &
            end
        end
    ' >/dev/null 2>&1 &
    disown
end

# Load Claude aliases and functions
if test -f ~/.claude/aliases.fish
    source ~/.claude/aliases.fish
end

# ============================================================
# End Claude Code Environment
# ============================================================

# ============================================================
# OpenTofu Aliases
# ============================================================

# Basic commands
alias tf='tofu'
alias tfi='tofu init'
alias tfp='tofu plan'
alias tfa='tofu apply'
alias tfd='tofu destroy'
alias tfv='tofu validate'
alias tff='tofu fmt'
alias tfs='tofu show'
alias tfo='tofu output'

# Auto-approve variants
alias tfaa='tofu apply -auto-approve'
alias tfda='tofu destroy -auto-approve'

# Common workflows
alias tfir='tofu init -reconfigure'
alias tfiu='tofu init -upgrade'
alias tfpd='tofu plan -destroy'
alias tfpo='tofu plan -out=tfplan'
alias tfao='tofu apply tfplan'

# State management
alias tfsl='tofu state list'
alias tfss='tofu state show'
alias tfsm='tofu state mv'
alias tfsrm='tofu state rm'
alias tfsp='tofu state pull'
alias tfspu='tofu state push'

# Workspace management
alias tfwl='tofu workspace list'
alias tfwn='tofu workspace new'
alias tfws='tofu workspace select'
alias tfwd='tofu workspace delete'

# Import and taint
alias tfim='tofu import'
alias tftaint='tofu taint'
alias tfuntaint='tofu untaint'

# Console and graph
alias tfc='tofu console'
alias tfg='tofu graph'

# Provider management
alias tfpi='tofu providers'
alias tfpl='tofu providers lock'
alias tfps='tofu providers schema'

# ============================================================
# End OpenTofu Aliases
# ============================================================
EOF
            echo -e "${GREEN}✓ Fish shell configured${NC}"
            echo -e "${YELLOW}  Run: source ~/.config/fish/config.fish${NC}"
        fi
        ;;

    bash|zsh)
        if [ "$SHELL_TYPE" = "bash" ]; then
            RC_FILE="$HOME/.bashrc"
        else
            RC_FILE="$HOME/.zshrc"
        fi

        # Check if already configured
        if grep -q "Claude Code Environment" "$RC_FILE" 2>/dev/null; then
            echo -e "${YELLOW}! $SHELL_TYPE already configured${NC}"
            if prompt_yes_no "Reconfigure $SHELL_TYPE?"; then
                cp "$RC_FILE" "${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
                sed -i.bak '/# ===.*Claude Code Environment/,/# ===.*End Claude Code Environment/d' "$RC_FILE"
            else
                echo -e "${YELLOW}→ Skipping $SHELL_TYPE configuration${NC}"
                SHELL_TYPE="skip"
            fi
        fi

        if [ "$SHELL_TYPE" != "skip" ]; then
            cat >> "$RC_FILE" << 'EOF'

# ============================================================
# Claude Code Environment
# ============================================================

# Load Claude aliases and functions
if [ -f ~/.claude/aliases.sh ]; then
    source ~/.claude/aliases.sh
fi

# ============================================================
# End Claude Code Environment
# ============================================================
EOF
            echo -e "${GREEN}✓ $SHELL_TYPE configured${NC}"
            echo -e "${YELLOW}  Run: source $RC_FILE${NC}"
        fi
        ;;

    *)
        echo -e "${YELLOW}! Unknown shell type, please configure manually${NC}"
        ;;
esac

# Create initial backup
echo ""
echo -e "${YELLOW}→ Creating initial backup...${NC}"
if [ -x ~/.claude/manage-context.sh ]; then
    ~/.claude/manage-context.sh backup "Initial setup" >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ Initial backup created${NC}"
fi

# Test Docker services
if command_exists docker && docker info >/dev/null 2>&1; then
    echo ""
    echo -e "${YELLOW}→ Testing Docker services...${NC}"
    if [ -x ~/.claude/claude-services.sh ]; then
        if ~/.claude/claude-services.sh start >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Docker services started${NC}"
            sleep 2
            if ~/.claude/claude-services.sh test >/dev/null 2>&1; then
                echo -e "${GREEN}✓ Vector database is accessible${NC}"
            fi
        fi
    fi
fi

# Optional: Setup Git Auto-sync
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Git Auto-sync (Optional)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Git auto-sync will automatically commit and push your changes"
echo "to GitHub every 4 hours. This keeps your machines in sync."
echo ""

if [ -d "$CLAUDE_DIR/.git" ] && git -C "$CLAUDE_DIR" remote get-url origin >/dev/null 2>&1; then
    if prompt_yes_no "Setup git auto-sync?"; then
        echo ""
        echo -e "${BLUE}Setting up git auto-sync...${NC}"
        if bash "$CLAUDE_DIR/bin/setup-git-sync.sh" install; then
            echo -e "${GREEN}✓ Git auto-sync configured${NC}"
        else
            echo -e "${YELLOW}⚠ Git auto-sync setup failed (you can set it up later)${NC}"
        fi
    else
        echo -e "${YELLOW}Skipped. You can enable it later with: claude-env git-sync install${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Git repository not initialized or no remote configured${NC}"
    echo "  To set up git sync later:"
    echo "  1. Initialize git: cd ~/.claude && git init"
    echo "  2. Add remote: git remote add origin git@github.com:USER/.claude.git"
    echo "  3. Push: git push -u origin main"
    echo "  4. Enable sync: claude-env git-sync install"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Setup Complete!                                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Claude environment installed to: ~/.claude/${NC}"
echo -e "${GREEN}✓ Shell integration configured${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo -e "1. Reload your shell:"
case "$SHELL_TYPE" in
    fish)
        echo -e "   ${BLUE}source ~/.config/fish/config.fish${NC}"
        ;;
    bash)
        echo -e "   ${BLUE}source ~/.bashrc${NC}"
        ;;
    zsh)
        echo -e "   ${BLUE}source ~/.zshrc${NC}"
        ;;
    *)
        echo -e "   ${BLUE}source your shell configuration file${NC}"
        ;;
esac
echo ""
echo -e "2. Check environment health:"
echo -e "   ${BLUE}claude-health${NC}"
echo ""
echo -e "3. Initialize vector database:"
echo -e "   ${BLUE}claude-init-db${NC}"
echo ""
echo -e "4. View all commands:"
echo -e "   ${BLUE}claude-status${NC}"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo -e "  ~/.claude/FISH_SETUP.md"
echo -e "  ~/.claude/DOCKER_SETUP.md"
echo -e "  ~/.claude/OPENTOFU_ALIASES.md"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"

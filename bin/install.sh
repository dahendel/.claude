#!/usr/bin/env bash
# Quick installer - downloads and runs the full setup script

set -e

echo "🚀 Claude Environment Quick Installer"
echo ""

# Create temp directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Determine source location
if [ -d "$(dirname "$0")" ] && [ -f "$(dirname "$0")/setup-claude-env.sh" ]; then
    # Running from local directory
    echo "→ Installing from local files..."
    bash "$(dirname "$0")/setup-claude-env.sh"
else
    # Download from repository (customize this URL)
    REPO_URL="${CLAUDE_REPO_URL:-https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/.claude}"

    echo "→ Downloading setup script from: $REPO_URL"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$REPO_URL/setup-claude-env.sh" -o "$TMP_DIR/setup-claude-env.sh"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TMP_DIR/setup-claude-env.sh" "$REPO_URL/setup-claude-env.sh"
    else
        echo "Error: Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    chmod +x "$TMP_DIR/setup-claude-env.sh"
    bash "$TMP_DIR/setup-claude-env.sh"
fi

#!/usr/bin/env bash
#
# Package Claude environment for transfer to another machine
# Creates a tarball with all necessary files
#

set -e

OUTPUT_FILE="${1:-$HOME/claude-env-$(date +%Y%m%d).tar.gz}"
CLAUDE_DIR="$HOME/.claude"

echo "📦 Packaging Claude environment..."
echo ""

# Check if .claude directory exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Error: ~/.claude directory not found"
    exit 1
fi

# Create temporary directory for packaging
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

mkdir -p "$TMP_DIR/.claude"

# Copy essential files
echo "→ Copying essential files..."
for file in \
    setup-claude-env.sh \
    install.sh \
    aliases.fish \
    aliases.sh \
    claude-services.sh \
    docker-compose.yml \
    init-vectordb.py \
    manage-context.sh \
    monitor.py \
    CLAUDE.md
do
    if [ -f "$CLAUDE_DIR/$file" ]; then
        cp "$CLAUDE_DIR/$file" "$TMP_DIR/.claude/"
        echo "  ✓ $file"
    else
        echo "  ⚠ $file not found (skipping)"
    fi
done

# Copy documentation
echo ""
echo "→ Copying documentation..."
for file in \
    SETUP_README.md \
    QUICK_INSTALL_GUIDE.md \
    DOCKER_SETUP.md \
    DOCKER_QUICKSTART.md \
    FISH_SETUP.md \
    OPENTOFU_ALIASES.md \
    QUICK_COMMANDS.md \
    IMPLEMENTATION_SUMMARY.md \
    CHANGELOG.md
do
    if [ -f "$CLAUDE_DIR/$file" ]; then
        cp "$CLAUDE_DIR/$file" "$TMP_DIR/.claude/"
        echo "  ✓ $file"
    fi
done

# Optionally include data (with prompt)
echo ""
read -p "Include vector database and backups? [y/N]: " include_data
if [[ "$include_data" =~ ^[Yy]$ ]]; then
    if [ -d "$CLAUDE_DIR/chroma-data" ]; then
        echo "→ Copying vector database..."
        cp -r "$CLAUDE_DIR/chroma-data" "$TMP_DIR/.claude/"
        echo "  ✓ chroma-data/"
    fi

    if [ -d "$CLAUDE_DIR/backups" ]; then
        echo "→ Copying backups..."
        cp -r "$CLAUDE_DIR/backups" "$TMP_DIR/.claude/"
        echo "  ✓ backups/"
    fi
fi

# Create tarball
echo ""
echo "→ Creating archive..."
cd "$TMP_DIR"
tar -czf "$OUTPUT_FILE" .claude/

# Get file size
SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

echo ""
echo "✓ Package created successfully!"
echo ""
echo "  File: $OUTPUT_FILE"
echo "  Size: $SIZE"
echo ""
echo "To transfer to another machine:"
echo ""
echo "  # Via SCP:"
echo "  scp $OUTPUT_FILE user@machine:~/"
echo ""
echo "  # On the new machine:"
echo "  cd ~"
echo "  tar -xzf $(basename $OUTPUT_FILE)"
echo "  bash .claude/setup-claude-env.sh"
echo ""

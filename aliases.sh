#!/bin/bash
# Claude Code Aliases and Helper Functions
# Add to your ~/.bashrc or ~/.zshrc:
#   source ~/.claude/aliases.sh

# === Context Management Aliases ===
alias claude-status='python3 ~/.claude/monitor.py'
alias claude-backup='~/.claude/manage-context.sh backup'
alias claude-restore='~/.claude/manage-context.sh restore'
alias claude-usage='~/.claude/manage-context.sh usage'
alias claude-clean='~/.claude/manage-context.sh clean'

# === Docker Services Aliases ===
alias claude-services='~/.claude/claude-services.sh'
alias claude-start='~/.claude/claude-services.sh start'
alias claude-stop='~/.claude/claude-services.sh stop'
alias claude-restart='~/.claude/claude-services.sh restart'
alias claude-logs='~/.claude/claude-services.sh logs'
alias claude-test='~/.claude/claude-services.sh test'

# === Vector DB Aliases ===
alias claude-init-db='python3 ~/.claude/init-vectordb.py'

# === Quick Navigation ===
alias cdclaude='cd ~/.claude'
alias cdprojects='cd ~/projects'

# === Log Viewing ===
alias claude-logs='tail -f ~/.config/Claude/logs/mcp*.log 2>/dev/null || echo "Claude Desktop logs not found"'
alias claude-logs-all='tail -f ~/.config/Claude/logs/*.log 2>/dev/null || echo "Claude Desktop logs not found"'

# === Database Management ===
alias claude-db-size='du -sh ~/.claude/chroma-data 2>/dev/null || echo "Database not found"'
alias claude-db-check='sqlite3 ~/.claude/chroma-data/chroma.sqlite3 "PRAGMA integrity_check;" 2>/dev/null || echo "Database not initialized"'

# === Quick CLAUDE.md Editing ===
alias claude-edit-global='${EDITOR:-nano} ~/.claude/CLAUDE.md'
alias claude-edit-project='${EDITOR:-nano} ./CLAUDE.md'
alias claude-view-global='cat ~/.claude/CLAUDE.md'
alias claude-view-project='cat ./CLAUDE.md 2>/dev/null || echo "No project CLAUDE.md found"'

# === Helper Functions ===

# Create a new project with CLAUDE.md template
claude-init-project() {
    local project_name="${1:-my-project}"
    local project_dir="${2:-.}"

    cat > "$project_dir/CLAUDE.md" << EOF
# Project: $project_name

## Overview
[Brief description of what this project does]

## Tech Stack
- Language: [e.g., Python 3.11+]
- Framework: [e.g., FastAPI]
- Database: [e.g., PostgreSQL]
- Other: [Additional tools/libraries]

## Architecture
[High-level architecture description or link to docs]

## Setup & Development

### Prerequisites
\`\`\`bash
# List prerequisites
\`\`\`

### Installation
\`\`\`bash
# Installation commands
\`\`\`

### Common Commands
\`\`\`bash
# Development
# Add your dev commands here

# Testing
# Add your test commands here

# Building
# Add your build commands here

# Deployment
# Add your deploy commands here
\`\`\`

## Code Style & Standards
- [Style guideline 1]
- [Style guideline 2]
- [Testing requirements]

## Current Focus
[What we're currently working on]

## Important Decisions
1. [Decision with rationale and date]
2. [Decision with rationale and date]

## Resources
- [Link to docs]
- [Link to wiki]
- [Link to design docs]

---
Last updated: $(date +%Y-%m-%d)
EOF

    echo "✓ Created CLAUDE.md in $project_dir"
    echo "  Edit with: ${EDITOR:-nano} $project_dir/CLAUDE.md"
}

# Quick context health check
claude-health() {
    echo "=== Claude Environment Health Check ==="
    echo ""

    # Check global CLAUDE.md
    if [ -f ~/.claude/CLAUDE.md ]; then
        lines=$(wc -l < ~/.claude/CLAUDE.md)
        echo "✓ Global CLAUDE.md: $lines lines"
        if [ $lines -gt 200 ]; then
            echo "  ⚠️  Warning: Exceeds 200 lines"
        fi
    else
        echo "✗ Global CLAUDE.md not found"
    fi

    # Check project CLAUDE.md
    if [ -f ./CLAUDE.md ]; then
        lines=$(wc -l < ./CLAUDE.md)
        echo "✓ Project CLAUDE.md: $lines lines"
    else
        echo "⚠️  No project CLAUDE.md in current directory"
    fi

    # Check vector DB
    if [ -d ~/.claude/chroma-data ]; then
        size=$(du -sh ~/.claude/chroma-data 2>/dev/null | cut -f1)
        echo "✓ Vector database: $size"
    else
        echo "⚠️  Vector database not initialized"
    fi

    # Check backups
    backup_count=$(ls -1 ~/.claude/backups/chroma_backup_*.tar.gz 2>/dev/null | wc -l)
    if [ $backup_count -gt 0 ]; then
        echo "✓ Backups: $backup_count found"

        latest=$(ls -t ~/.claude/backups/chroma_backup_*.tar.gz 2>/dev/null | head -1)
        if [ -n "$latest" ]; then
            age=$((( $(date +%s) - $(stat -c %Y "$latest" 2>/dev/null || stat -f %m "$latest" 2>/dev/null) ) / 86400))
            if [ $age -gt 7 ]; then
                echo "  ⚠️  Last backup is $age days old"
            else
                echo "  ✓ Last backup: $age days ago"
            fi
        fi
    else
        echo "⚠️  No backups found"
    fi

    echo ""
    echo "For detailed report, run: claude-status"
}

# Store important information in vector DB (when MCP is available)
claude-store() {
    local message="$*"
    if [ -z "$message" ]; then
        echo "Usage: claude-store <message to store>"
        echo "Example: claude-store We decided to use FastAPI for async support"
        return 1
    fi

    echo "To store in Claude's vector DB:"
    echo "  Run Claude Code and say:"
    echo "  'Store in memory: $message'"
}

# Quick backup before risky operations
claude-backup-quick() {
    local reason="${1:-manual backup}"
    echo "Creating quick backup: $reason"
    ~/.claude/manage-context.sh backup
}

# Show most recent session summary (if history exists)
claude-recent() {
    if [ -f ~/.claude/history.jsonl ]; then
        echo "=== Recent Claude Sessions ==="
        tail -5 ~/.claude/history.jsonl | while IFS= read -r line; do
            # Try to extract timestamp if it's JSON
            echo "$line" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    print(f\"Session: {data.get('timestamp', 'Unknown')} - {data.get('type', 'Unknown')}\")
except:
    print(sys.stdin.read()[:100])
" 2>/dev/null || echo "$line" | head -c 100
            echo ""
        done
    else
        echo "No session history found"
    fi
}

# Setup MCP configuration helper
claude-setup-mcp() {
    local config_dir=""

    # Detect OS and set config directory
    if [ -d "$HOME/Library/Application Support/Claude" ]; then
        config_dir="$HOME/Library/Application Support/Claude"
    elif [ -d "$HOME/.config/Claude" ]; then
        config_dir="$HOME/.config/Claude"
    else
        echo "⚠️  Claude Desktop not found."
        echo "   Install Claude Desktop from: https://claude.ai/download"
        return 1
    fi

    local config_file="$config_dir/claude_desktop_config.json"

    if [ -f "$config_file" ]; then
        echo "✓ Claude Desktop config exists: $config_file"
        echo ""
        echo "Current configuration:"
        cat "$config_file" | python3 -m json.tool 2>/dev/null || cat "$config_file"
    else
        echo "⚠️  No MCP configuration found"

        if [ -f ~/.claude/claude_desktop_config.template.json ]; then
            echo ""
            echo "Template available at: ~/.claude/claude_desktop_config.template.json"
            echo ""
            echo -n "Copy template to Claude Desktop config? (yes/no): "
            read confirm

            if [ "$confirm" = "yes" ]; then
                mkdir -p "$config_dir"
                cp ~/.claude/claude_desktop_config.template.json "$config_file"
                echo "✓ Configuration created: $config_file"
                echo "  Restart Claude Desktop to activate MCP servers"
            fi
        fi
    fi
}

# Export function for use in shell
export -f claude-init-project 2>/dev/null
export -f claude-health 2>/dev/null
export -f claude-store 2>/dev/null
export -f claude-backup-quick 2>/dev/null
export -f claude-recent 2>/dev/null
export -f claude-setup-mcp 2>/dev/null

echo "✓ Claude Code aliases loaded"
echo "  Run 'claude-health' for quick status check"
echo "  Run 'claude-status' for detailed monitoring"

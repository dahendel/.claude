# Claude Code Aliases and Functions for Fish Shell
# Add to your ~/.config/fish/config.fish:
#   source ~/.claude/aliases.fish

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
alias claude-logs-all='tail -f ~/.config/Claude/logs/*.log 2>/dev/null; or echo "Claude Desktop logs not found"'

# === Database Management ===
alias claude-db-size='du -sh ~/.claude/chroma-data 2>/dev/null; or echo "Database not found"'
alias claude-db-check='sqlite3 ~/.claude/chroma-data/chroma.sqlite3 "PRAGMA integrity_check;" 2>/dev/null; or echo "Database not initialized"'

# === Quick CLAUDE.md Editing ===
alias claude-edit-global='$EDITOR ~/.claude/CLAUDE.md'
alias claude-edit-project='$EDITOR ./CLAUDE.md'
alias claude-view-global='cat ~/.claude/CLAUDE.md'
alias claude-view-project='cat ./CLAUDE.md 2>/dev/null; or echo "No project CLAUDE.md found"'

# === Distribution and Transfer ===
alias claude-package='~/.claude/package-for-transfer.sh'
alias claude-setup='bash ~/.claude/setup-claude-env.sh'

# === Helper Functions ===

function claude-init-project
    set -l project_name (test (count $argv) -ge 1; and echo $argv[1]; or echo "my-project")
    set -l project_dir (test (count $argv) -ge 2; and echo $argv[2]; or echo ".")
    set -l today (date +%Y-%m-%d)

    # Use printf for better multiline string handling in Fish
    printf "# Project: %s

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
Last updated: %s
" "$project_name" "$today" > "$project_dir/CLAUDE.md"

    echo "✓ Created CLAUDE.md in $project_dir"
    echo "  Edit with: \$EDITOR $project_dir/CLAUDE.md"
end

function claude-health
    echo "=== Claude Environment Health Check ==="
    echo ""

    # Check global CLAUDE.md
    if test -f ~/.claude/CLAUDE.md
        set lines (wc -l < ~/.claude/CLAUDE.md)
        echo "✓ Global CLAUDE.md: $lines lines"
        if test $lines -gt 200
            echo "  ⚠️  Warning: Exceeds 200 lines"
        end
    else
        echo "✗ Global CLAUDE.md not found"
    end

    # Check project CLAUDE.md
    if test -f ./CLAUDE.md
        set lines (wc -l < ./CLAUDE.md)
        echo "✓ Project CLAUDE.md: $lines lines"
    else
        echo "⚠️  No project CLAUDE.md in current directory"
    end

    # Check vector DB
    if test -d ~/.claude/chroma-data
        set size (du -sh ~/.claude/chroma-data 2>/dev/null | cut -f1)
        echo "✓ Vector database: $size"
    else
        echo "⚠️  Vector database not initialized"
    end

    # Check backups
    set backup_count (ls -1 ~/.claude/backups/chroma_backup_*.tar.gz 2>/dev/null | wc -l)
    if test $backup_count -gt 0
        echo "✓ Backups: $backup_count found"

        set latest (ls -t ~/.claude/backups/chroma_backup_*.tar.gz 2>/dev/null | head -1)
        if test -n "$latest"
            # Get file modification time
            if test (uname) = Darwin
                set age_seconds (math (date +%s) - (stat -f %m "$latest"))
            else
                set age_seconds (math (date +%s) - (stat -c %Y "$latest"))
            end
            set age (math -s0 "$age_seconds / 86400")

            if test $age -gt 7
                echo "  ⚠️  Last backup is $age days old"
            else
                echo "  ✓ Last backup: $age days ago"
            end
        end
    else
        echo "⚠️  No backups found"
    end

    echo ""
    echo "For detailed report, run: claude-status"
end

function claude-store
    if test (count $argv) -eq 0
        echo "Usage: claude-store <message to store>"
        echo "Example: claude-store We decided to use FastAPI for async support"
        return 1
    end

    set message $argv

    echo "To store in Claude's vector DB:"
    echo "  Run Claude Code and say:"
    echo "  'Store in memory: $message'"
end

function claude-backup-quick
    set reason (test (count $argv) -ge 1; and echo $argv[1]; or echo "manual backup")
    echo "Creating quick backup: $reason"
    ~/.claude/manage-context.sh backup
end

function claude-recent
    if test -f ~/.claude/history.jsonl
        echo "=== Recent Claude Sessions ==="
        tail -5 ~/.claude/history.jsonl | while read -l line
            # Try to extract timestamp if it's JSON
            echo $line | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    print(f\"Session: {data.get('timestamp', 'Unknown')} - {data.get('type', 'Unknown')}\")
except:
    print(sys.stdin.read()[:100])
" 2>/dev/null; or echo $line | string sub -l 100
            echo ""
        end
    else
        echo "No session history found"
    end
end

function claude-setup-mcp
    set config_dir ""

    # Detect OS and set config directory
    if test -d "$HOME/Library/Application Support/Claude"
        set config_dir "$HOME/Library/Application Support/Claude"
    else if test -d "$HOME/.config/Claude"
        set config_dir "$HOME/.config/Claude"
    else
        echo "⚠️  Claude Desktop not found."
        echo "   Install Claude Desktop from: https://claude.ai/download"
        return 1
    end

    set config_file "$config_dir/claude_desktop_config.json"

    if test -f "$config_file"
        echo "✓ Claude Desktop config exists: $config_file"
        echo ""
        echo "Current configuration:"
        cat "$config_file" | python3 -m json.tool 2>/dev/null; or cat "$config_file"
    else
        echo "⚠️  No MCP configuration found"

        if test -f ~/.claude/claude_desktop_config_docker.json
            echo ""
            echo "Template available at: ~/.claude/claude_desktop_config_docker.json"
            echo ""
            read -P "Copy template to Claude Desktop config? (yes/no): " confirm

            if test "$confirm" = "yes"
                mkdir -p "$config_dir"
                cp ~/.claude/claude_desktop_config_docker.json "$config_file"
                echo "✓ Configuration created: $config_file"
                echo "  Restart Claude Desktop to activate MCP servers"
            end
        end
    end
end

# Fish-specific completion
function __claude_complete_services
    echo start\t"Start all services"
    echo stop\t"Stop all services"
    echo restart\t"Restart all services"
    echo status\t"Show service status"
    echo logs\t"Show service logs"
    echo test\t"Test service connections"
    echo clean\t"Clean all data volumes"
end

complete -c claude-services -f -a '(__claude_complete_services)'

# Display loaded message
echo "✓ Claude Code aliases loaded (Fish shell)"
echo "  Run 'claude-health' for quick status check"
echo "  Run 'claude-status' for detailed monitoring"

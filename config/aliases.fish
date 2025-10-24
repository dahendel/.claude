# Claude Code Aliases and Functions for Fish Shell
# Add to your ~/.config/fish/config.fish:
#   source ~/.claude/config/aliases.fish

# Main CLI wrapper
set -gx PATH ~/.claude $PATH

# === Quick Aliases (using wrapper) ===
alias claude-health='~/.claude/claude-env health'
alias claude-status='~/.claude/claude-env status'
alias claude-backup='~/.claude/claude-env backup'
alias claude-restore='~/.claude/claude-env restore'
alias claude-usage='~/.claude/claude-env usage'
alias claude-clean='~/.claude/claude-env clean'
alias claude-start='~/.claude/claude-env start'
alias claude-stop='~/.claude/claude-env stop'
alias claude-restart='~/.claude/claude-env restart'
alias claude-logs='~/.claude/claude-env logs'
alias claude-test='~/.claude/claude-env test'
alias claude-init-db='~/.claude/claude-env init-db'
alias claude-package='~/.claude/claude-env package'
alias claude-setup='~/.claude/claude-env setup'

# === Direct Script Access (for advanced use) ===
alias claude-services='~/.claude/bin/claude-services.sh'

# === Quick Navigation ===
alias cdclaude='cd ~/.claude'
alias cdprojects='cd ~/projects'

# === Log Viewing ===
alias claude-logs-all='tail -f ~/.config/Claude/logs/*.log 2>/dev/null; or echo "Claude Desktop logs not found"'

# === Database Management ===
alias claude-db-size='du -sh ~/.claude/data/chroma-data 2>/dev/null; or echo "Database not found"'
alias claude-db-check='sqlite3 ~/.claude/data/chroma-data/chroma.sqlite3 "PRAGMA integrity_check;" 2>/dev/null; or echo "Database not initialized"'

# === Quick CLAUDE.md Editing ===
alias claude-edit-global='$EDITOR ~/.claude/CLAUDE.md'
alias claude-edit-project='$EDITOR ./CLAUDE.md'
alias claude-view-global='cat ~/.claude/CLAUDE.md'
alias claude-view-project='cat ./CLAUDE.md 2>/dev/null; or echo "No project CLAUDE.md found"'

# === Helper Functions ===

function claude-init-project
    set -l project_name (test (count $argv) -ge 1; and echo $argv[1]; or echo "my-project")
    set -l project_dir (test (count $argv) -ge 2; and echo $argv[2]; or echo ".")
    set -l today (date +%Y-%m-%d)

    printf "# Project: %s\n\n## Overview\n\nCreated: %s\n\n## Architecture\n\n## Development Notes\n\n## Commands\n\n" "$project_name" "$today" > "$project_dir/CLAUDE.md"
    
    echo "✓ Created $project_dir/CLAUDE.md"
    echo "  Edit with: claude-edit-project"
end

function claude-health
    ~/.claude/claude-env health
end

# Show load message
echo "✓ Claude Code aliases loaded (Fish shell)"
echo "  Run 'claude-env help' for available commands"

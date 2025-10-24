# Claude Code Optimization - Fish Shell Integration
# Add this to your ~/.config/fish/config.fish

# ============================================================
# Claude Code Environment
# ============================================================

# Load Claude aliases and functions
if test -f ~/.claude/aliases.fish
    source ~/.claude/aliases.fish
end

# Optional: Set default editor for Claude configs
set -gx CLAUDE_EDITOR $EDITOR

# Optional: Auto-backup on shell exit (uncomment if desired)
# function claude_exit_handler --on-event fish_exit
#     claude-backup-quick "auto-backup on exit" 2>/dev/null
# end

# Auto-start Docker vector database on new shell
function claude_autostart --on-event fish_prompt --on-variable PWD
    # Only run once per session
    if not set -q CLAUDE_DOCKER_CHECKED
        set -g CLAUDE_DOCKER_CHECKED 1

        # Check if Docker is running and start Chroma if needed
        if docker info >/dev/null 2>&1
            if not docker ps --format '{{.Names}}' 2>/dev/null | grep -q claude-chroma
                echo "🚀 Starting Claude vector database..."
                ~/.claude/claude-services.sh start >/dev/null 2>&1
                if test $status -eq 0
                    echo "✓ Vector database started"
                end
            end
        end
    end
end

# Optional: Show quick status on new shell (uncomment if desired)
# if type -q claude-health
#     echo ""
#     claude-health
#     echo ""
# end

# ============================================================
# End Claude Code Environment
# ============================================================

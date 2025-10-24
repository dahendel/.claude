#!/bin/bash
# Claude Code Optimization - Shell Integration
# Add this to your ~/.bashrc or ~/.zshrc

# ============================================================
# Claude Code Environment
# ============================================================

# Load Claude aliases and functions
if [ -f ~/.claude/aliases.sh ]; then
    source ~/.claude/aliases.sh
fi

# Optional: Set default editor for Claude configs
export CLAUDE_EDITOR="${EDITOR:-nano}"

# Optional: Auto-backup on shell exit (uncomment if desired)
# trap 'claude-backup-quick "auto-backup on exit" 2>/dev/null' EXIT

# Optional: Show quick status on new shell (uncomment if desired)
# if command -v claude-health &> /dev/null; then
#     echo ""
#     claude-health
#     echo ""
# fi

# ============================================================
# End Claude Code Environment
# ============================================================

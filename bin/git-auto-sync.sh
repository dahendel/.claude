#!/bin/bash
# Git Auto-sync Script
# Automatically commits and syncs ~/.claude to GitHub
# Designed for cron jobs and scheduled tasks

set -e

CLAUDE_DIR="$HOME/.claude"
LOG_FILE="$CLAUDE_DIR/data/git-sync.log"
MAX_LOG_SIZE=1048576  # 1MB

# Ensure data directory exists
mkdir -p "$CLAUDE_DIR/data"

# Rotate log if too large
if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
    mv "$LOG_FILE" "$LOG_FILE.old"
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Git Auto-sync Started ==="

cd "$CLAUDE_DIR" || {
    log "ERROR: Could not change to $CLAUDE_DIR"
    exit 1
}

# Check if git repo
if [ ! -d ".git" ]; then
    log "ERROR: Not a git repository"
    exit 1
fi

# Fetch latest changes from remote
log "Fetching from remote..."
if git fetch origin main 2>&1 | tee -a "$LOG_FILE"; then
    log "✓ Fetch successful"
else
    log "✗ Fetch failed"
    exit 1
fi

# Check for uncommitted changes
if git diff-index --quiet HEAD --; then
    log "No local changes to commit"
    HAS_CHANGES=false
else
    log "Found local changes"
    HAS_CHANGES=true
fi

# Commit local changes if any
if [ "$HAS_CHANGES" = true ]; then
    HOSTNAME=$(hostname)
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    log "Staging changes..."
    git add -A 2>&1 | tee -a "$LOG_FILE"

    log "Creating commit..."
    git commit -m "auto-sync: ${HOSTNAME} at ${TIMESTAMP}

Automated sync from ${HOSTNAME}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>" 2>&1 | tee -a "$LOG_FILE"

    log "✓ Changes committed"
fi

# Check if remote has changes
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
    log "Already up to date"
elif [ "$LOCAL" = "$BASE" ]; then
    log "Remote has changes, pulling..."
    if git pull --rebase origin main 2>&1 | tee -a "$LOG_FILE"; then
        log "✓ Pull successful"
    else
        log "✗ Pull failed - may need manual intervention"
        exit 1
    fi
elif [ "$REMOTE" = "$BASE" ]; then
    log "Local has changes, pushing..."
    if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
        log "✓ Push successful"
    else
        log "✗ Push failed"
        exit 1
    fi
else
    log "WARNING: Branches have diverged!"
    log "Local and remote have different commits"
    log "Attempting rebase..."
    if git pull --rebase origin main 2>&1 | tee -a "$LOG_FILE"; then
        log "✓ Rebase successful"
        if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
            log "✓ Push successful after rebase"
        else
            log "✗ Push failed after rebase"
            exit 1
        fi
    else
        log "✗ Rebase failed - manual intervention required"
        log "Run: cd ~/.claude && git status"
        exit 1
    fi
fi

log "=== Git Auto-sync Completed Successfully ==="
log ""

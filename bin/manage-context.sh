#!/bin/bash
# Claude Context Management Script
# Usage: claude-manage [backup|restore|usage|clean]

CLAUDE_DIR="$HOME/.claude"
CHROMA_DIR="$CLAUDE_DIR/chroma-data"
BACKUP_DIR="$CLAUDE_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

case "$1" in
  backup)
    echo "Creating backup of Claude context..."
    mkdir -p "$BACKUP_DIR"

    # Backup vector database
    if [ -d "$CHROMA_DIR" ]; then
      tar -czf "$BACKUP_DIR/chroma_backup_$TIMESTAMP.tar.gz" -C "$CHROMA_DIR" .
      echo "✓ Vector database backed up to: $BACKUP_DIR/chroma_backup_$TIMESTAMP.tar.gz"
    fi

    # Backup CLAUDE.md files
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
      cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE_backup_$TIMESTAMP.md"
      echo "✓ Global CLAUDE.md backed up"
    fi

    # Clean old backups (keep last 10)
    cd "$BACKUP_DIR" && ls -t chroma_backup_*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

    echo "✓ Backup complete!"
    ;;

  restore)
    echo "Available backups:"
    ls -lth "$BACKUP_DIR"/chroma_backup_*.tar.gz 2>/dev/null | head -5
    echo ""
    echo -n "Enter backup filename to restore (or 'latest'): "
    read backup_file

    if [ "$backup_file" = "latest" ]; then
      backup_file=$(ls -t "$BACKUP_DIR"/chroma_backup_*.tar.gz 2>/dev/null | head -1)
    else
      backup_file="$BACKUP_DIR/$backup_file"
    fi

    if [ -f "$backup_file" ]; then
      echo "⚠️  This will overwrite current vector database!"
      echo -n "Continue? (yes/no): "
      read confirm

      if [ "$confirm" = "yes" ]; then
        rm -rf "$CHROMA_DIR"/*
        tar -xzf "$backup_file" -C "$CHROMA_DIR"
        echo "✓ Restored from: $backup_file"
      else
        echo "Restore cancelled."
      fi
    else
      echo "✗ Backup file not found: $backup_file"
      exit 1
    fi
    ;;

  usage)
    echo "=== Claude Context Usage Report ==="
    echo ""

    # Vector database size
    if [ -d "$CHROMA_DIR" ]; then
      db_size=$(du -sh "$CHROMA_DIR" 2>/dev/null | cut -f1)
      echo "Vector Database: $db_size"

      if [ -f "$CHROMA_DIR/chroma.sqlite3" ]; then
        record_count=$(sqlite3 "$CHROMA_DIR/chroma.sqlite3" "SELECT COUNT(*) FROM embeddings;" 2>/dev/null || echo "N/A")
        echo "Embeddings stored: $record_count"
      fi
    else
      echo "Vector Database: Not initialized"
    fi

    echo ""

    # Backups
    backup_count=$(ls -1 "$BACKUP_DIR"/chroma_backup_*.tar.gz 2>/dev/null | wc -l)
    backup_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
    echo "Backups: $backup_count files ($backup_size total)"

    echo ""

    # CLAUDE.md size
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
      claude_md_lines=$(wc -l < "$CLAUDE_DIR/CLAUDE.md")
      claude_md_size=$(du -h "$CLAUDE_DIR/CLAUDE.md" | cut -f1)
      echo "Global CLAUDE.md: $claude_md_lines lines ($claude_md_size)"

      if [ $claude_md_lines -gt 200 ]; then
        echo "⚠️  Warning: CLAUDE.md exceeds recommended 200 lines"
      fi
    fi

    echo ""
    echo "=== Recommendations ==="

    # Check if backups are recent
    latest_backup=$(ls -t "$BACKUP_DIR"/chroma_backup_*.tar.gz 2>/dev/null | head -1)
    if [ -n "$latest_backup" ]; then
      backup_age=$(( ($(date +%s) - $(stat -c %Y "$latest_backup" 2>/dev/null || stat -f %m "$latest_backup" 2>/dev/null)) / 86400 ))
      if [ $backup_age -gt 7 ]; then
        echo "⚠️  Last backup is $backup_age days old. Run: claude-manage backup"
      else
        echo "✓ Backups are up to date (last backup: $backup_age days ago)"
      fi
    else
      echo "⚠️  No backups found. Run: claude-manage backup"
    fi
    ;;

  clean)
    echo "=== Cleaning Claude Context ==="
    echo ""
    echo "This will:"
    echo "1. Remove backups older than 30 days"
    echo "2. Optimize vector database"
    echo ""
    echo -n "Continue? (yes/no): "
    read confirm

    if [ "$confirm" = "yes" ]; then
      # Clean old backups
      find "$BACKUP_DIR" -name "chroma_backup_*.tar.gz" -mtime +30 -delete 2>/dev/null
      old_claude_md=$(find "$BACKUP_DIR" -name "CLAUDE_backup_*.md" -mtime +30 | wc -l)
      find "$BACKUP_DIR" -name "CLAUDE_backup_*.md" -mtime +30 -delete 2>/dev/null
      echo "✓ Removed old backups"

      # Optimize SQLite database
      if [ -f "$CHROMA_DIR/chroma.sqlite3" ]; then
        sqlite3 "$CHROMA_DIR/chroma.sqlite3" "VACUUM;" 2>/dev/null
        echo "✓ Optimized vector database"
      fi

      echo "✓ Cleanup complete!"
    else
      echo "Cleanup cancelled."
    fi
    ;;

  *)
    echo "Claude Context Management Tool"
    echo ""
    echo "Usage: claude-manage [command]"
    echo ""
    echo "Commands:"
    echo "  backup   - Create backup of vector database and CLAUDE.md"
    echo "  restore  - Restore from a previous backup"
    echo "  usage    - Show current usage and health metrics"
    echo "  clean    - Clean old backups and optimize database"
    echo ""
    echo "Examples:"
    echo "  claude-manage backup"
    echo "  claude-manage usage"
    echo "  claude-manage restore"
    ;;
esac

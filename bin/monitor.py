#!/usr/bin/env python3
"""
Claude Environment Monitoring Dashboard
Shows real-time status of vector DB, backups, and usage metrics
"""

import os
import sqlite3
from pathlib import Path
from datetime import datetime, timedelta
import json

# Constants
CLAUDE_DIR = Path.home() / ".claude"
CHROMA_DIR = CLAUDE_DIR / "chroma-data"
BACKUP_DIR = CLAUDE_DIR / "backups"
CLAUDE_MD = CLAUDE_DIR / "CLAUDE.md"

def format_size(bytes_size):
    """Format bytes to human readable size"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes_size < 1024.0:
            return f"{bytes_size:.1f} {unit}"
        bytes_size /= 1024.0
    return f"{bytes_size:.1f} TB"

def get_directory_size(path):
    """Calculate total size of directory"""
    total = 0
    for entry in Path(path).rglob('*'):
        if entry.is_file():
            total += entry.stat().st_size
    return total

def check_vector_db():
    """Check vector database status"""
    print("📊 Vector Database Status")
    print("=" * 60)

    if not CHROMA_DIR.exists():
        print("❌ Vector database not initialized")
        print(f"   Run: mkdir -p {CHROMA_DIR}")
        return

    db_path = CHROMA_DIR / "chroma.sqlite3"

    if not db_path.exists():
        print("⚠️  Database directory exists but no data yet")
        print("   Start using vector DB to create database")
        return

    # Get database size
    db_size = db_path.stat().st_size
    total_size = get_directory_size(CHROMA_DIR)

    print(f"Database file: {format_size(db_size)}")
    print(f"Total size:    {format_size(total_size)}")

    # Try to get record counts
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # Get table counts
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()

        if tables:
            print(f"\nTables: {len(tables)}")

            for table in tables:
                table_name = table[0]
                try:
                    cursor.execute(f"SELECT COUNT(*) FROM {table_name};")
                    count = cursor.fetchone()[0]
                    if count > 0:
                        print(f"  - {table_name}: {count:,} records")
                except:
                    pass

        conn.close()
        print("✓ Database healthy")

    except Exception as e:
        print(f"⚠️  Could not read database: {e}")

    print()

def check_backups():
    """Check backup status"""
    print("💾 Backup Status")
    print("=" * 60)

    if not BACKUP_DIR.exists():
        print("❌ Backup directory not found")
        print(f"   Run: mkdir -p {BACKUP_DIR}")
        return

    # Find all backups
    backups = list(BACKUP_DIR.glob("chroma_backup_*.tar.gz"))

    if not backups:
        print("⚠️  No backups found")
        print("   Run: ~/.claude/manage-context.sh backup")
        return

    # Sort by modification time
    backups.sort(key=lambda x: x.stat().st_mtime, reverse=True)

    print(f"Total backups: {len(backups)}")
    print(f"Total size:    {format_size(get_directory_size(BACKUP_DIR))}")
    print()

    # Show recent backups
    print("Recent backups:")
    for backup in backups[:5]:
        mtime = datetime.fromtimestamp(backup.stat().st_mtime)
        age = datetime.now() - mtime
        size = format_size(backup.stat().st_size)

        status = "✓"
        if age.days > 7:
            status = "⚠️"
        if age.days > 30:
            status = "❌"

        print(f"  {status} {backup.name}")
        print(f"     Age: {age.days}d {age.seconds//3600}h | Size: {size}")

    # Check if backup is needed
    latest = backups[0]
    age = datetime.now() - datetime.fromtimestamp(latest.stat().st_mtime)

    print()
    if age.days > 7:
        print("⚠️  Backup is overdue (>7 days old)")
        print("   Run: ~/.claude/manage-context.sh backup")
    else:
        print(f"✓ Last backup: {age.days}d {age.seconds//3600}h ago")

    print()

def check_claude_md():
    """Check CLAUDE.md file status"""
    print("📝 CLAUDE.md Files")
    print("=" * 60)

    if not CLAUDE_MD.exists():
        print("⚠️  Global CLAUDE.md not found")
        print(f"   Create: {CLAUDE_MD}")
        return

    # Read file
    content = CLAUDE_MD.read_text()
    lines = content.split('\n')
    size = CLAUDE_MD.stat().st_size

    print(f"Global config: {CLAUDE_MD}")
    print(f"  Lines: {len(lines)}")
    print(f"  Size:  {format_size(size)}")

    if len(lines) > 200:
        print(f"  ⚠️  Warning: {len(lines)} lines exceeds recommended 200")
        print("     Consider moving some content to project CLAUDE.md")
    else:
        print("  ✓ Size is optimal")

    # Check for project CLAUDE.md
    cwd_claude_md = Path.cwd() / "CLAUDE.md"
    if cwd_claude_md.exists():
        proj_content = cwd_claude_md.read_text()
        proj_lines = proj_content.split('\n')
        proj_size = cwd_claude_md.stat().st_size

        print(f"\nProject config: {cwd_claude_md}")
        print(f"  Lines: {len(proj_lines)}")
        print(f"  Size:  {format_size(proj_size)}")

        if len(proj_lines) > 300:
            print("  ⚠️  Warning: Consider splitting into multiple files")
        else:
            print("  ✓ Size is good")

    print()

def check_mcp_config():
    """Check MCP configuration"""
    print("🔌 MCP Configuration")
    print("=" * 60)

    # Check for config file
    config_paths = [
        Path.home() / ".config/Claude/claude_desktop_config.json",
        Path.home() / "Library/Application Support/Claude/claude_desktop_config.json"
    ]

    config_found = False
    for config_path in config_paths:
        if config_path.exists():
            config_found = True
            print(f"Config found: {config_path}")

            try:
                with open(config_path) as f:
                    config = json.load(f)

                if "mcpServers" in config:
                    servers = config["mcpServers"]
                    print(f"\nConfigured servers: {len(servers)}")
                    for name, settings in servers.items():
                        print(f"  ✓ {name}")
                        print(f"    Command: {settings.get('command', 'N/A')}")
                else:
                    print("⚠️  No MCP servers configured")

            except Exception as e:
                print(f"⚠️  Could not read config: {e}")

            break

    if not config_found:
        template = CLAUDE_DIR / "claude_desktop_config.template.json"
        if template.exists():
            print("⚠️  Claude Desktop config not found")
            print(f"   Template available: {template}")
            print("   Copy to appropriate location when using Claude Desktop")
        else:
            print("⚠️  No MCP configuration found")

    print()

def show_recommendations():
    """Show actionable recommendations"""
    print("💡 Recommendations")
    print("=" * 60)

    recommendations = []

    # Check database
    if not (CHROMA_DIR / "chroma.sqlite3").exists():
        recommendations.append(
            "📊 Initialize vector database:\n"
            "   In Claude: 'Store in memory: Setup complete on $(date)'"
        )

    # Check backups
    backups = list(BACKUP_DIR.glob("chroma_backup_*.tar.gz"))
    if backups:
        latest = max(backups, key=lambda x: x.stat().st_mtime)
        age = datetime.now() - datetime.fromtimestamp(latest.stat().st_mtime)
        if age.days > 7:
            recommendations.append(
                "💾 Create fresh backup:\n"
                "   Run: ~/.claude/manage-context.sh backup"
            )
    else:
        recommendations.append(
            "💾 Create initial backup:\n"
            "   Run: ~/.claude/manage-context.sh backup"
        )

    # Check CLAUDE.md
    if CLAUDE_MD.exists():
        lines = len(CLAUDE_MD.read_text().split('\n'))
        if lines > 200:
            recommendations.append(
                "📝 Optimize CLAUDE.md:\n"
                f"   Current: {lines} lines, recommended: <200\n"
                "   Move project-specific content to ./CLAUDE.md"
            )

    if recommendations:
        for i, rec in enumerate(recommendations, 1):
            print(f"{i}. {rec}")
            print()
    else:
        print("✓ Everything looks good!")
        print()

def main():
    """Main monitoring dashboard"""
    print()
    print("╔" + "═" * 58 + "╗")
    print("║" + " " * 10 + "Claude Environment Monitor" + " " * 22 + "║")
    print("╚" + "═" * 58 + "╝")
    print()
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    check_vector_db()
    check_backups()
    check_claude_md()
    check_mcp_config()
    show_recommendations()

    print("=" * 60)
    print("For detailed management, use: ~/.claude/manage-context.sh")
    print()

if __name__ == "__main__":
    main()

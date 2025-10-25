#!/usr/bin/env python3
"""
Claude Environment Health Monitor
Tracks context usage, cache performance, and system health
"""

import json
import sqlite3
import os
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import subprocess

# Paths
CLAUDE_DIR = Path.home() / ".claude"
CHROMA_DB = CLAUDE_DIR / "chroma-data" / "chroma.sqlite3"
STATS_DB = CLAUDE_DIR / "stats.db"
LOGS_DIR = Path.home() / ".config" / "Claude" / "logs"


class ClaudeMonitor:
    def __init__(self):
        self.ensure_stats_db()

    def ensure_stats_db(self):
        """Create stats database if it doesn't exist"""
        conn = sqlite3.connect(STATS_DB)
        cursor = conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                max_context_pct REAL,
                auto_compacts INTEGER DEFAULT 0,
                manual_compacts INTEGER DEFAULT 0,
                cache_hit_rate REAL,
                vector_queries INTEGER DEFAULT 0
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS health_checks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                component TEXT,
                status TEXT,
                details TEXT
            )
        """)

        conn.commit()
        conn.close()

    def check_vector_db(self) -> Dict:
        """Check vector database health"""
        if not CHROMA_DB.exists():
            return {
                "status": "❌ Not initialized",
                "size": 0,
                "collections": 0,
                "last_modified": None
            }

        try:
            # Get database size
            size_mb = CHROMA_DB.stat().st_size / (1024 * 1024)
            last_modified = datetime.fromtimestamp(CHROMA_DB.stat().st_mtime)

            # Try to count collections
            conn = sqlite3.connect(CHROMA_DB)
            cursor = conn.cursor()

            try:
                cursor.execute("SELECT COUNT(*) FROM collections")
                collection_count = cursor.fetchone()[0]
            except:
                collection_count = "Unknown"

            conn.close()

            status = "✅ Healthy" if size_mb > 0 else "⚠️ Empty"

            return {
                "status": status,
                "size": f"{size_mb:.2f} MB",
                "collections": collection_count,
                "last_modified": last_modified.strftime("%Y-%m-%d %H:%M")
            }
        except Exception as e:
            return {
                "status": f"❌ Error: {str(e)}",
                "size": 0,
                "collections": 0,
                "last_modified": None
            }

    def check_docker_services(self) -> Dict:
        """Check Docker service status"""
        services = {}

        try:
            result = subprocess.run(
                ["docker", "ps", "--format", "{{.Names}}"],
                capture_output=True,
                text=True,
                timeout=5
            )

            running = result.stdout.strip().split("\n") if result.stdout else []

            services["chroma"] = "✅ Running" if "claude-chroma" in running else "⚠️ Stopped"
            services["qdrant"] = "✅ Running" if "claude-qdrant" in running else "ℹ️ Optional"
            services["ollama"] = "✅ Running" if "claude-ollama" in running else "ℹ️ Optional"

        except subprocess.TimeoutExpired:
            services["docker"] = "❌ Timeout"
        except FileNotFoundError:
            services["docker"] = "❌ Not installed"
        except Exception as e:
            services["docker"] = f"❌ Error: {str(e)}"

        return services

    def check_backups(self) -> Dict:
        """Check backup status"""
        backup_dir = CLAUDE_DIR / "backups"

        if not backup_dir.exists():
            return {
                "status": "⚠️ No backups",
                "count": 0,
                "latest": None,
                "total_size": "0 MB"
            }

        backups = list(backup_dir.glob("*.tar.gz"))

        if not backups:
            return {
                "status": "⚠️ No backups",
                "count": 0,
                "latest": None,
                "total_size": "0 MB"
            }

        latest = max(backups, key=lambda p: p.stat().st_mtime)
        latest_age = datetime.now() - datetime.fromtimestamp(latest.stat().st_mtime)

        total_size = sum(b.stat().st_size for b in backups) / (1024 * 1024)

        status = "✅ Current" if latest_age.days < 7 else "⚠️ Outdated"

        return {
            "status": status,
            "count": len(backups),
            "latest": latest.name,
            "latest_age": f"{latest_age.days} days ago",
            "total_size": f"{total_size:.2f} MB"
        }

    def check_config(self) -> Dict:
        """Check configuration files"""
        checks = {}

        # Global CLAUDE.md
        global_md = CLAUDE_DIR / "CLAUDE.md"
        if global_md.exists():
            lines = len(global_md.read_text().splitlines())
            status = "✅ Present" if lines > 0 else "⚠️ Empty"
            checks["global_claude_md"] = f"{status} ({lines} lines)"
        else:
            checks["global_claude_md"] = "❌ Missing"

        # MCP Config (for Claude Desktop)
        mcp_config = Path.home() / ".config" / "Claude" / "claude_desktop_config.json"
        if mcp_config.exists():
            try:
                with open(mcp_config) as f:
                    config = json.load(f)
                    server_count = len(config.get("mcpServers", {}))
                    checks["mcp_config"] = f"✅ Present ({server_count} servers)"
            except:
                checks["mcp_config"] = "⚠️ Invalid JSON"
        else:
            checks["mcp_config"] = "ℹ️ Not needed (Claude Code)"

        # Docker Compose
        docker_compose = CLAUDE_DIR / "docker-compose.yml"
        checks["docker_compose"] = "✅ Present" if docker_compose.exists() else "⚠️ Missing"

        return checks

    def generate_health_score(self) -> int:
        """Calculate overall health score (0-100)"""
        score = 100

        # Vector DB check (-20 if missing)
        db_status = self.check_vector_db()
        if "❌" in db_status["status"]:
            score -= 20

        # Docker services (-10 if Chroma not running)
        services = self.check_docker_services()
        if services.get("chroma", "").startswith("⚠️"):
            score -= 10

        # Backups (-15 if outdated or missing)
        backups = self.check_backups()
        if "⚠️" in backups["status"] or "❌" in backups["status"]:
            score -= 15

        # Config (-10 if CLAUDE.md missing)
        config = self.check_config()
        if "❌" in config.get("global_claude_md", ""):
            score -= 10

        return max(0, score)

    def print_dashboard(self):
        """Print full health dashboard"""
        print("\n" + "="*60)
        print("  Claude Environment Health Dashboard")
        print("="*60 + "\n")

        # Health Score
        score = self.generate_health_score()
        score_color = "🟢" if score >= 80 else "🟡" if score >= 60 else "🔴"
        print(f"{score_color} Overall Health Score: {score}/100\n")

        # Vector Database
        print("💾 Vector Database")
        db = self.check_vector_db()
        print(f"  Status: {db['status']}")
        print(f"  Size: {db['size']}")
        print(f"  Collections: {db['collections']}")
        if db['last_modified']:
            print(f"  Last Modified: {db['last_modified']}")
        print()

        # Docker Services
        print("🐳 Docker Services")
        services = self.check_docker_services()
        for service, status in services.items():
            print(f"  {service.capitalize()}: {status}")
        print()

        # Backups
        print("💼 Backups")
        backups = self.check_backups()
        print(f"  Status: {backups['status']}")
        print(f"  Count: {backups['count']}")
        if backups['latest']:
            print(f"  Latest: {backups['latest']}")
            print(f"  Age: {backups['latest_age']}")
        print(f"  Total Size: {backups['total_size']}")
        print()

        # Configuration
        print("🔧 Configuration")
        config = self.check_config()
        for key, value in config.items():
            display_key = key.replace("_", " ").title()
            print(f"  {display_key}: {value}")
        print()

        # Performance Targets
        print("🎯 Performance Targets")
        print("  Auto-compacts: Target 0/month")
        print("  Context usage: Keep <70% average")
        print("  Monthly cost: Target <$10 (100 sessions)")
        print("  Cache hit rate: Target >70%")
        print("  Backup age: <7 days")
        print()

        # Quick Actions
        if score < 80:
            print("⚡ Recommended Actions:")
            if "❌" in db["status"]:
                print("  • Run 'claude-init-db' to initialize vector database")
            if services.get("chroma", "").startswith("⚠️"):
                print("  • Run 'claude-start' to start Docker services")
            if "⚠️" in backups["status"]:
                print("  • Run 'claude-backup' to create a backup")
            print()

    def log_health_check(self):
        """Log current health check to database"""
        conn = sqlite3.connect(STATS_DB)
        cursor = conn.cursor()

        # Log overall status
        score = self.generate_health_score()
        cursor.execute(
            "INSERT INTO health_checks (component, status, details) VALUES (?, ?, ?)",
            ("overall", str(score), f"Health score: {score}/100")
        )

        # Log vector DB status
        db = self.check_vector_db()
        cursor.execute(
            "INSERT INTO health_checks (component, status, details) VALUES (?, ?, ?)",
            ("vector_db", db["status"], json.dumps(db))
        )

        conn.commit()
        conn.close()


def main():
    monitor = ClaudeMonitor()
    monitor.print_dashboard()
    monitor.log_health_check()


if __name__ == "__main__":
    main()

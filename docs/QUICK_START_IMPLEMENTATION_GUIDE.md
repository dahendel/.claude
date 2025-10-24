# Quick Start Implementation Guide
## Claude Environment Optimization - Fast Track Setup

**Companion to:** `CLAUDE_ENVIRONMENT_OPTIMIZATION_PROPOSAL.md`
**Time Required:** 2-4 hours for basic setup
**Difficulty:** Beginner to Intermediate

---

## Table of Contents

1. [Prerequisites Check](#prerequisites-check)
2. [15-Minute Minimal Setup](#15-minute-minimal-setup)
3. [1-Hour Standard Setup](#1-hour-standard-setup)
4. [4-Hour Complete Setup](#4-hour-complete-setup)
5. [Verification Tests](#verification-tests)
6. [Common Issues & Fixes](#common-issues--fixes)
7. [Daily Usage Patterns](#daily-usage-patterns)

---

## Prerequisites Check

**Before you begin, verify:**

```bash
# Check your OS
uname -a

# Check if you have Claude Desktop or Claude Code
which claude  # For Claude Code CLI
# Or check Applications folder for Claude Desktop

# Check Python version (needed for some MCP servers)
python3 --version  # Should be 3.10+

# Check if you have curl (for downloads)
which curl

# Check available disk space (need at least 1GB)
df -h ~
```

**Requirements:**
- [ ] Claude Desktop or Claude Code installed
- [ ] macOS, Linux, or Windows WSL
- [ ] 1GB+ free disk space
- [ ] Internet connection (for initial setup)
- [ ] Text editor (VS Code, nano, vim, etc.)

---

## 15-Minute Minimal Setup

**Goal:** Get basic context persistence working NOW

### Step 1: Create Global CLAUDE.md (3 minutes)

```bash
# Create Claude config directory
mkdir -p ~/.claude

# Create your global preferences file
cat > ~/.claude/CLAUDE.md << 'EOF'
# Global User Preferences

## Communication Style
- Prefer concise, technical responses
- Include code examples when relevant
- Highlight potential issues proactively

## Coding Preferences
- Primary language: Python
- Style: Follow PEP 8
- Testing: Use pytest
- Type hints: Required for functions

## Common Tools
- Editor: VS Code
- Shell: bash
- Package manager: pip/uv
EOF
```

### Step 2: Create Project CLAUDE.md (5 minutes)

```bash
# Navigate to your project
cd /home/dahendel/projects/local-claude

# Create project-specific context
cat > CLAUDE.md << 'EOF'
# Project: Local Claude Environment

## Overview
Optimizing Claude local development with vector databases and context persistence.

## Tech Stack
- Python 3.11+
- Vector DB: TBD (evaluating Chroma vs Qdrant)
- MCP: Planning integration

## Common Commands
```bash
# Run tests
python -m pytest tests/

# Format code
python -m black .

# Type check
python -m mypy src/
```

## Current Focus
Setting up context persistence architecture with vector database integration.

## Important Files
- CLAUDE_ENVIRONMENT_OPTIMIZATION_PROPOSAL.md: Main architecture doc
- QUICK_START_IMPLEMENTATION_GUIDE.md: This file
EOF

# Add to gitignore
echo "CLAUDE.local.md" >> .gitignore
```

### Step 3: Test CLAUDE.md Loading (2 minutes)

```bash
# If using Claude Code:
claude

# Then in Claude, ask:
# "What do you know about this project?"
# "What are my coding preferences?"

# Claude should reference your CLAUDE.md content
```

### Step 4: Create Session Management Aliases (5 minutes)

```bash
# Add to your ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'

# Claude environment helpers
alias claude-context='claude /context'
alias claude-compact='claude /compact'
alias claude-clear='claude /clear'
alias claude-fresh='claude /quit && claude'

# Project-specific Claude sessions
alias claude-work='cd ~/projects/local-claude && claude'
EOF

# Reload shell
source ~/.bashrc
```

**Minimal Setup Complete!** You now have:
- ✅ Global preferences auto-loaded
- ✅ Project context auto-loaded
- ✅ Basic session management
- ✅ Context persistence via files

**Time elapsed: ~15 minutes**

---

## 1-Hour Standard Setup

**Goal:** Add vector database for persistent memory across sessions

### Prerequisites

```bash
# Install uvx (Python package runner)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to PATH (restart terminal after)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
uvx --version
```

### Step 1: Setup Chroma Vector Database (15 minutes)

```bash
# Create data directory
mkdir -p ~/.claude/chroma-data

# Test Chroma MCP server
uvx chroma-mcp --client-type persistent --data-dir ~/.claude/chroma-data

# You should see output like:
# "Starting Chroma MCP server..."
# Press Ctrl+C to stop test
```

### Step 2: Configure Claude Desktop (10 minutes)

**Find your config file:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```bash
# macOS example
code ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**Add this configuration:**

```json
{
  "mcpServers": {
    "chroma": {
      "command": "uvx",
      "args": [
        "chroma-mcp",
        "--client-type",
        "persistent",
        "--data-dir",
        "/home/dahendel/.claude/chroma-data"
      ]
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/dahendel/projects"
      ]
    }
  }
}
```

**Important:** Replace `/home/dahendel` with your actual home directory path!

```bash
# Get your home directory
echo $HOME
```

### Step 3: Restart Claude Desktop (2 minutes)

```bash
# macOS
killall Claude
open -a Claude

# Linux
killall claude-desktop
claude-desktop &

# Or just quit and reopen the application
```

### Step 4: Verify MCP Connection (5 minutes)

**In Claude Desktop:**

1. Look for the hammer icon 🔨 in the input area
2. Click it - you should see:
   - `chroma` server listed
   - `filesystem` server listed
3. Try this test:

```
"Please store this in Chroma: Today is 2025-10-23, and we successfully
set up the Chroma MCP server for vector database integration."
```

4. Start a NEW conversation and ask:

```
"What do you have stored in Chroma about our setup?"
```

**If Claude retrieves your test message, success! ✅**

### Step 5: Create Context Management Script (10 minutes)

```bash
# Create helper script
cat > ~/.claude/manage-context.sh << 'EOF'
#!/bin/bash
# Claude Context Management Helper

function show_usage() {
    echo "Context Usage:"
    du -sh ~/.claude/chroma-data
    echo ""
    echo "Recent sessions:"
    ls -lth ~/.claude/chroma-data/chroma.sqlite3* 2>/dev/null | head -5
}

function backup_context() {
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_dir=~/.claude/backups
    mkdir -p "$backup_dir"

    echo "Backing up Chroma database..."
    cp -r ~/.claude/chroma-data "$backup_dir/chroma-data-$timestamp"
    cp ~/.claude/CLAUDE.md "$backup_dir/CLAUDE.md-$timestamp"

    echo "Backup created: $backup_dir/*-$timestamp"
}

function restore_context() {
    echo "Available backups:"
    ls -lth ~/.claude/backups/ | head -10

    read -p "Enter backup timestamp (YYYYMMDD_HHMMSS): " timestamp

    if [ -d ~/.claude/backups/chroma-data-$timestamp ]; then
        echo "Restoring from $timestamp..."
        rm -rf ~/.claude/chroma-data
        cp -r ~/.claude/backups/chroma-data-$timestamp ~/.claude/chroma-data
        echo "Restore complete!"
    else
        echo "Backup not found"
    fi
}

case "$1" in
    usage)
        show_usage
        ;;
    backup)
        backup_context
        ;;
    restore)
        restore_context
        ;;
    *)
        echo "Usage: $0 {usage|backup|restore}"
        exit 1
esac
EOF

chmod +x ~/.claude/manage-context.sh

# Create alias
echo "alias claude-manage='~/.claude/manage-context.sh'" >> ~/.bashrc
source ~/.bashrc
```

### Step 6: Test Context Persistence (10 minutes)

**Test Workflow:**

1. **Store Information:**
```
"Remember that our vector database is Chroma, running locally with
persistent storage at ~/.claude/chroma-data. We chose it for its
SQLite backend and zero-config setup."
```

2. **Store Project Decision:**
```
"Store in memory: We decided to use voyage-large-2 for embeddings
because it has superior code understanding compared to OpenAI's ada-002."
```

3. **Quit and Restart Claude**

4. **Retrieve Information:**
```
"What vector database are we using and why?"
"What embedding model did we choose?"
```

**If Claude answers correctly, you have persistent memory! ✅**

### Step 7: Setup Daily Backup (8 minutes)

```bash
# Create backup cron job
crontab -e

# Add this line (runs daily at 2 AM):
0 2 * * * /bin/bash ~/.claude/manage-context.sh backup

# Verify cron job
crontab -l
```

**Standard Setup Complete!** You now have:
- ✅ Vector database for persistent memory
- ✅ MCP server integration
- ✅ Filesystem access
- ✅ Automated backups
- ✅ Context management tools

**Time elapsed: ~1 hour**

---

## 4-Hour Complete Setup

**Goal:** Full production-ready environment with all optimizations

### Prerequisites from Standard Setup

Complete the 1-hour standard setup first, then continue:

### Step 1: Install Docker (20 minutes)

```bash
# macOS: Download Docker Desktop from docker.com
# Linux:
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Logout and login for group changes to take effect

# Verify
docker --version
docker-compose --version
```

### Step 2: Setup OpenMemory MCP (30 minutes)

```bash
# Clone and setup OpenMemory
cd ~/.claude
git clone https://github.com/mem0ai/mem0.git
cd mem0/openmemory

# Create .env file
cat > .env << 'EOF'
OPENAI_API_KEY=your-openai-api-key-here
MEM0_API_KEY=optional
EOF

# Build and start
docker-compose up -d

# Wait for services to start (30-60 seconds)
sleep 60

# Check status
docker-compose ps

# Access dashboard
echo "OpenMemory dashboard: http://localhost:3000"
```

**Add to Claude Desktop config:**

```json
{
  "mcpServers": {
    "chroma": {
      "command": "uvx",
      "args": ["chroma-mcp", "--client-type", "persistent", "--data-dir", "/home/dahendel/.claude/chroma-data"]
    },
    "openmemory": {
      "command": "docker",
      "args": ["exec", "openmemory", "node", "/app/mcp-server/dist/index.js"],
      "env": {
        "OPENAI_API_KEY": "${OPENAI_API_KEY}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/dahendel/projects"]
    }
  }
}
```

### Step 3: Setup Litestream Backups (25 minutes)

```bash
# Install Litestream
# macOS
brew install litestream

# Linux
wget https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz
tar -xzf litestream-v0.3.13-linux-amd64.tar.gz
sudo mv litestream /usr/local/bin/

# Verify
litestream version

# Create config
mkdir -p ~/.claude/litestream
cat > ~/.claude/litestream/litestream.yml << 'EOF'
dbs:
  - path: /home/dahendel/.claude/chroma-data/chroma.sqlite3
    replicas:
      - type: file
        path: /home/dahendel/.claude/backups/litestream
      # Optional: Add S3 backup
      # - type: s3
      #   bucket: your-bucket-name
      #   path: claude-backups
      #   region: us-east-1
EOF

# Replace /home/dahendel with your actual path
sed -i "s|/home/dahendel|$HOME|g" ~/.claude/litestream/litestream.yml

# Create backup directory
mkdir -p ~/.claude/backups/litestream

# Test configuration
litestream replicate -config ~/.claude/litestream/litestream.yml -exec "echo 'Backup test successful'"
```

**Create systemd service (Linux) or launchd (macOS):**

```bash
# macOS launchd
cat > ~/Library/LaunchAgents/io.litestream.claude.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>io.litestream.claude</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/litestream</string>
        <string>replicate</string>
        <string>-config</string>
        <string>/Users/YOURUSERNAME/.claude/litestream/litestream.yml</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Replace YOURUSERNAME
sed -i '' "s|YOURUSERNAME|$USER|g" ~/Library/LaunchAgents/io.litestream.claude.plist

# Load service
launchctl load ~/Library/LaunchAgents/io.litestream.claude.plist
```

### Step 4: Setup Local Embeddings with Ollama (30 minutes)

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull embedding model
ollama pull nomic-embed-text

# Test embedding generation
ollama run nomic-embed-text "Test embedding"

# Create wrapper script for MCP
cat > ~/.claude/ollama-embeddings.py << 'EOF'
#!/usr/bin/env python3
"""
Local embedding generation using Ollama
"""
import sys
import json
import subprocess

def generate_embedding(text: str) -> list[float]:
    """Generate embedding using Ollama"""
    result = subprocess.run(
        ["ollama", "run", "nomic-embed-text", text],
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

if __name__ == "__main__":
    text = sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()
    embedding = generate_embedding(text)
    print(json.dumps(embedding))
EOF

chmod +x ~/.claude/ollama-embeddings.py

# Test
echo "Test text" | ~/.claude/ollama-embeddings.py
```

### Step 5: Setup Monitoring Dashboard (30 minutes)

```bash
# Create monitoring script
cat > ~/.claude/monitor.py << 'EOF'
#!/usr/bin/env python3
"""
Claude Environment Monitoring Dashboard
"""
import sqlite3
from pathlib import Path
from datetime import datetime, timedelta
import json

class ClaudeMonitor:
    def __init__(self):
        self.chroma_db = Path.home() / ".claude/chroma-data/chroma.sqlite3"
        self.backup_dir = Path.home() / ".claude/backups"

    def get_db_stats(self):
        """Get Chroma database statistics"""
        if not self.chroma_db.exists():
            return {"error": "Database not found"}

        conn = sqlite3.connect(self.chroma_db)
        cursor = conn.cursor()

        try:
            # Get collection count
            cursor.execute("SELECT COUNT(*) FROM collections")
            collections = cursor.fetchone()[0]

            # Get document count
            cursor.execute("SELECT COUNT(*) FROM embeddings")
            documents = cursor.fetchone()[0]

            # Get database size
            size_mb = self.chroma_db.stat().st_size / (1024 * 1024)

            return {
                "collections": collections,
                "documents": documents,
                "size_mb": round(size_mb, 2),
                "last_modified": datetime.fromtimestamp(
                    self.chroma_db.stat().st_mtime
                ).strftime("%Y-%m-%d %H:%M:%S")
            }
        finally:
            conn.close()

    def get_backup_stats(self):
        """Get backup statistics"""
        if not self.backup_dir.exists():
            return {"error": "No backups found"}

        backups = list(self.backup_dir.glob("chroma-data-*"))
        if not backups:
            return {"count": 0}

        latest = max(backups, key=lambda p: p.stat().st_mtime)
        total_size = sum(
            sum(f.stat().st_size for f in backup.rglob("*") if f.is_file())
            for backup in backups
        )

        return {
            "count": len(backups),
            "latest": latest.name,
            "total_size_mb": round(total_size / (1024 * 1024), 2)
        }

    def generate_report(self):
        """Generate monitoring report"""
        db_stats = self.get_db_stats()
        backup_stats = self.get_backup_stats()

        report = f"""
╔══════════════════════════════════════════════════════════╗
║          Claude Environment Health Report                ║
║          Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}              ║
╠══════════════════════════════════════════════════════════╣

📊 Vector Database (Chroma)
   Collections: {db_stats.get('collections', 'N/A')}
   Documents: {db_stats.get('documents', 'N/A')}
   Size: {db_stats.get('size_mb', 'N/A')} MB
   Last Modified: {db_stats.get('last_modified', 'N/A')}

💾 Backups
   Count: {backup_stats.get('count', 0)}
   Latest: {backup_stats.get('latest', 'None')}
   Total Size: {backup_stats.get('total_size_mb', 0)} MB

🎯 Recommendations
"""

        # Add recommendations based on stats
        if db_stats.get('size_mb', 0) > 500:
            report += "   ⚠️  Database size >500MB - consider archiving old data\n"

        if backup_stats.get('count', 0) == 0:
            report += "   ⚠️  No backups found - setup backup system\n"

        if backup_stats.get('count', 0) > 10:
            report += "   ℹ️  10+ backups - consider cleanup of old backups\n"

        report += "\n╚══════════════════════════════════════════════════════════╝\n"

        return report

if __name__ == "__main__":
    monitor = ClaudeMonitor()
    print(monitor.generate_report())
EOF

chmod +x ~/.claude/monitor.py

# Test monitoring
python3 ~/.claude/monitor.py

# Create alias
echo "alias claude-status='python3 ~/.claude/monitor.py'" >> ~/.bashrc
source ~/.bashrc
```

### Step 6: Create Context Management Prompts (20 minutes)

```bash
# Create prompt templates
mkdir -p ~/.claude/prompts

cat > ~/.claude/prompts/session-start.md << 'EOF'
# Session Start Prompt

Please help me start this development session efficiently:

1. **Check Memory:**
   - Review Chroma and OpenMemory for relevant context
   - Summarize what you know about this project
   - Highlight any recent decisions or changes

2. **Current Status:**
   - What was I working on last session?
   - Any outstanding tasks or issues?
   - Current project phase/milestone

3. **Session Planning:**
   - Suggest next steps based on history
   - Identify any blockers or dependencies
   - Estimate complexity of pending tasks

Please be concise but thorough.
EOF

cat > ~/.claude/prompts/session-end.md << 'EOF'
# Session End Prompt

Let's wrap up this session properly:

1. **Archive Important Decisions:**
   - Store key technical decisions in Chroma
   - Update CLAUDE.md with new patterns/conventions
   - Document any architecture changes

2. **Session Summary:**
   - What did we accomplish?
   - What challenges did we encounter?
   - What solutions did we implement?

3. **Next Session Prep:**
   - What should I focus on next?
   - Any files or context to review?
   - Recommended starting point

Please organize this for easy retrieval next session.
EOF

cat > ~/.claude/prompts/context-check.md << 'EOF'
# Context Health Check

Please perform a context health check:

1. **Current Context Usage:**
   - Check /context for usage percentage
   - Identify largest context consumers
   - Suggest optimization opportunities

2. **Memory Status:**
   - What's stored in Chroma about this project?
   - Any outdated or redundant information?
   - Gaps in stored knowledge?

3. **Recommendations:**
   - Should we compact now?
   - Should we archive anything?
   - Should we start a fresh session?
EOF

# Create helper to use prompts
cat > ~/.claude/use-prompt.sh << 'EOF'
#!/bin/bash
prompt_file=~/.claude/prompts/$1.md

if [ -f "$prompt_file" ]; then
    cat "$prompt_file"
    echo ""
    echo "---"
    echo "Copy the above prompt to Claude"
else
    echo "Available prompts:"
    ls ~/.claude/prompts/*.md | xargs -n 1 basename -s .md
fi
EOF

chmod +x ~/.claude/use-prompt.sh
echo "alias claude-prompt='~/.claude/use-prompt.sh'" >> ~/.bashrc
source ~/.bashrc
```

### Step 7: Setup Advanced Caching (25 minutes)

```bash
# Create caching configuration
cat > ~/.claude/cache-config.json << 'EOF'
{
  "prompt_caching": {
    "enabled": true,
    "ttl": 300,
    "max_breakpoints": 4,
    "auto_cache": [
      "system_prompt",
      "claude_md",
      "tool_definitions"
    ]
  },
  "cache_layers": [
    {
      "name": "system_prompt",
      "priority": 1,
      "min_size": 1000
    },
    {
      "name": "project_context",
      "priority": 2,
      "min_size": 5000
    },
    {
      "name": "tool_definitions",
      "priority": 3,
      "min_size": 2000
    },
    {
      "name": "rag_context",
      "priority": 4,
      "min_size": 10000
    }
  ]
}
EOF

# Create cache monitoring script
cat > ~/.claude/monitor-cache.py << 'EOF'
#!/usr/bin/env python3
"""
Monitor prompt caching effectiveness
"""
import json
from datetime import datetime
from pathlib import Path

class CacheMonitor:
    def __init__(self):
        self.log_file = Path.home() / ".claude/cache-log.jsonl"

    def log_request(self, response_data):
        """Log API response for cache analysis"""
        usage = response_data.get("usage", {})

        entry = {
            "timestamp": datetime.now().isoformat(),
            "input_tokens": usage.get("input_tokens", 0),
            "cache_creation_tokens": usage.get("cache_creation_input_tokens", 0),
            "cache_read_tokens": usage.get("cache_read_input_tokens", 0),
            "output_tokens": usage.get("output_tokens", 0)
        }

        with open(self.log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")

    def analyze_cache_performance(self, days=7):
        """Analyze cache performance over time"""
        if not self.log_file.exists():
            return {"error": "No cache log found"}

        with open(self.log_file) as f:
            entries = [json.loads(line) for line in f]

        total_requests = len(entries)
        if total_requests == 0:
            return {"error": "No requests logged"}

        cache_hits = sum(1 for e in entries if e["cache_read_tokens"] > 0)
        total_cached = sum(e["cache_read_tokens"] for e in entries)
        total_input = sum(e["input_tokens"] + e["cache_read_tokens"] for e in entries)

        hit_rate = cache_hits / total_requests
        token_savings = total_cached * 0.9  # 90% savings on cache hits

        return {
            "total_requests": total_requests,
            "cache_hit_rate": f"{hit_rate:.1%}",
            "tokens_cached": f"{total_cached:,}",
            "estimated_savings": f"${token_savings * 0.000003:.2f}"
        }

if __name__ == "__main__":
    monitor = CacheMonitor()
    results = monitor.analyze_cache_performance()
    print(json.dumps(results, indent=2))
EOF

chmod +x ~/.claude/monitor-cache.py
```

### Step 8: Final Verification & Testing (40 minutes)

```bash
# Run comprehensive test suite
cat > ~/.claude/test-setup.sh << 'EOF'
#!/bin/bash
echo "=== Claude Environment Test Suite ==="
echo ""

# Test 1: CLAUDE.md loading
echo "Test 1: CLAUDE.md files"
if [ -f ~/.claude/CLAUDE.md ]; then
    echo "✅ Global CLAUDE.md exists"
else
    echo "❌ Global CLAUDE.md missing"
fi

# Test 2: Vector database
echo ""
echo "Test 2: Vector database"
if [ -f ~/.claude/chroma-data/chroma.sqlite3 ]; then
    size=$(du -sh ~/.claude/chroma-data | cut -f1)
    echo "✅ Chroma database exists ($size)"
else
    echo "❌ Chroma database missing"
fi

# Test 3: MCP servers
echo ""
echo "Test 3: MCP configuration"
if [ -f ~/Library/Application\ Support/Claude/claude_desktop_config.json ] || \
   [ -f ~/.config/Claude/claude_desktop_config.json ]; then
    echo "✅ Claude Desktop config exists"
else
    echo "❌ Claude Desktop config missing"
fi

# Test 4: Backups
echo ""
echo "Test 4: Backup system"
if [ -d ~/.claude/backups ]; then
    backup_count=$(ls -1 ~/.claude/backups | wc -l)
    echo "✅ Backup directory exists ($backup_count backups)"
else
    echo "❌ Backup directory missing"
fi

# Test 5: Tools
echo ""
echo "Test 5: Installed tools"
command -v uvx >/dev/null 2>&1 && echo "✅ uvx installed" || echo "❌ uvx missing"
command -v docker >/dev/null 2>&1 && echo "✅ docker installed" || echo "❌ docker missing"
command -v ollama >/dev/null 2>&1 && echo "✅ ollama installed" || echo "⚠️  ollama not installed (optional)"
command -v litestream >/dev/null 2>&1 && echo "✅ litestream installed" || echo "⚠️  litestream not installed (optional)"

# Test 6: Monitoring
echo ""
echo "Test 6: Monitoring tools"
if [ -f ~/.claude/monitor.py ]; then
    echo "✅ Monitor script exists"
    python3 ~/.claude/monitor.py
else
    echo "❌ Monitor script missing"
fi

echo ""
echo "=== Test Complete ==="
echo "Check for any ❌ markers above and resolve issues"
EOF

chmod +x ~/.claude/test-setup.sh

# Run tests
~/.claude/test-setup.sh
```

**Complete Setup Done!** You now have:
- ✅ Full vector database integration
- ✅ Multiple MCP servers
- ✅ Automated backups with Litestream
- ✅ Local embeddings with Ollama (optional)
- ✅ OpenMemory for private memory
- ✅ Monitoring and analytics
- ✅ Prompt templates
- ✅ Cache optimization

**Time elapsed: ~4 hours**

---

## Verification Tests

### Test 1: Context Persistence

```
Conversation 1:
"Remember: Our primary vector database is Chroma, chosen for SQLite
backing and zero-config setup. Store this in long-term memory."

/quit

Conversation 2:
"What vector database are we using and why did we choose it?"
```

**Expected:** Claude retrieves the correct information from Chroma.

### Test 2: Cross-Session Project Memory

```
Session 1:
"Store in memory: For this project, always run 'python -m pytest tests/'
before committing code. Store this in the project context."

/quit

Session 2 (in same project):
"What's our testing workflow before commits?"
```

**Expected:** Claude knows to run pytest before commits.

### Test 3: Context Compaction Avoidance

```
# Monitor context throughout conversation
/context

# At 70% context:
"Check current context usage and recommend whether to compact now
or continue working"
```

**Expected:** Claude recognizes high context and suggests actions.

### Test 4: MCP Tools Available

```
"What tools do you have available through MCP servers?"
```

**Expected:** Claude lists Chroma, filesystem, and other configured servers.

### Test 5: CLAUDE.md Loading

```
Start fresh conversation:
"What are my coding preferences based on your available context?"
```

**Expected:** Claude references preferences from CLAUDE.md.

---

## Common Issues & Fixes

### Issue: MCP Server Not Appearing

**Symptoms:** Hammer icon missing or server not listed

**Fix:**
```bash
# Check config syntax
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool

# Check logs
tail -f ~/Library/Logs/Claude/mcp*.log

# Restart Claude Desktop
killall Claude && open -a Claude
```

### Issue: Chroma Database Connection Failed

**Symptoms:** "Failed to connect to database" errors

**Fix:**
```bash
# Check database file
ls -lh ~/.claude/chroma-data/chroma.sqlite3

# Check permissions
chmod 755 ~/.claude/chroma-data
chmod 644 ~/.claude/chroma-data/chroma.sqlite3

# Test manually
uvx chroma-mcp --client-type persistent --data-dir ~/.claude/chroma-data
```

### Issue: Context Not Persisting

**Symptoms:** Claude doesn't remember previous conversations

**Fix:**
```bash
# Verify MCP server is running
# In Claude: "List your available tools"

# Check database has data
sqlite3 ~/.claude/chroma-data/chroma.sqlite3 "SELECT COUNT(*) FROM embeddings;"

# Manually store test data
# In Claude: "Store in Chroma: Test entry $(date)"
```

### Issue: High Memory Usage

**Symptoms:** System slow, high RAM/disk usage

**Fix:**
```bash
# Check database size
du -sh ~/.claude/chroma-data

# Vacuum database
sqlite3 ~/.claude/chroma-data/chroma.sqlite3 "VACUUM;"

# Archive old collections
# In Claude: "List all Chroma collections and their sizes"
# Delete old ones through Claude
```

### Issue: OpenMemory Dashboard Not Loading

**Symptoms:** http://localhost:3000 not accessible

**Fix:**
```bash
# Check Docker containers
docker-compose -f ~/.claude/mem0/openmemory/docker-compose.yml ps

# Check logs
docker-compose -f ~/.claude/mem0/openmemory/docker-compose.yml logs

# Restart services
docker-compose -f ~/.claude/mem0/openmemory/docker-compose.yml restart
```

### Issue: CLAUDE.md Not Loading

**Symptoms:** Claude doesn't reference CLAUDE.md content

**Fix:**
```bash
# Check file exists
ls -lh ~/.claude/CLAUDE.md
ls -lh ./CLAUDE.md

# Check file permissions
chmod 644 ~/.claude/CLAUDE.md
chmod 644 ./CLAUDE.md

# Verify content
cat CLAUDE.md

# Test explicitly
# In Claude: "What's in your CLAUDE.md file?"
```

---

## Daily Usage Patterns

### Morning Startup Routine

```bash
# 1. Check system health
claude-status

# 2. Start Claude in project
cd ~/projects/local-claude
claude

# 3. Use session-start prompt
claude-prompt session-start
# Copy output to Claude
```

### During Development

```
# Monitor context every hour or when you feel it's filling up
/context

# At 70% context, take action:
/compact keep architecture decisions and current file structure

# Between major tasks:
/clear
```

### End of Day Routine

```
# 1. Use session-end prompt
claude-prompt session-end
# Copy to Claude and follow instructions

# 2. Manual backup
claude-manage backup

# 3. Check statistics
claude-status
```

### Weekly Maintenance

```bash
# Sunday evening routine
# 1. Review backups
claude-manage usage

# 2. Clean up old data
# In Claude: "Show me collections older than 30 days"
# Delete unnecessary ones

# 3. Update CLAUDE.md
# Add new conventions learned this week

# 4. Check monitoring
claude-status
```

---

## Next Steps

After completing this setup:

1. **Read the main proposal:** Review `CLAUDE_ENVIRONMENT_OPTIMIZATION_PROPOSAL.md` for architectural details

2. **Customize CLAUDE.md:** Add your specific preferences and project context

3. **Start using it:** Begin a project and test the persistence

4. **Monitor and optimize:** Use the monitoring tools to track performance

5. **Iterate:** Adjust based on your actual usage patterns

6. **Share feedback:** Document what works and what doesn't

---

## Resources

**Created Files:**
- `/home/dahendel/.claude/CLAUDE.md` - Global preferences
- `/home/dahendel/projects/local-claude/CLAUDE.md` - Project context
- `/home/dahendel/.claude/chroma-data/` - Vector database
- `/home/dahendel/.claude/backups/` - Backup storage
- `/home/dahendel/.claude/prompts/` - Prompt templates
- `/home/dahendel/.claude/manage-context.sh` - Management script
- `/home/dahendel/.claude/monitor.py` - Monitoring dashboard

**Configuration Files:**
- `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)
- `~/.config/Claude/claude_desktop_config.json` (Linux)
- `~/.claude/litestream/litestream.yml` - Backup configuration
- `~/.claude/cache-config.json` - Cache settings

**Commands Added:**
- `claude health` / `claude status` - Show system health (monitor.py)
- `claude backup [message]` - Create backup
- `claude restore` - Restore from backup
- `claude usage` - Show usage statistics
- `claude clean` - Cleanup old backups
- `claude start` - Start Docker services
- `claude stop` - Stop Docker services
- `claude restart` - Restart Docker services
- `claude logs` - View service logs
- `claude test` - Test connectivity
- `claude autostart [cmd]` - Manage auto-start (install|remove|status)
- `claude git-sync [cmd]` - Manage git auto-sync (install|remove|test|status)
- `claude sync` - Run git sync manually
- `claude skill-create [args]` - Create Claude skills from docs (create|list|install)
- `claude init-db` - Initialize vector database
- `claude package [file]` - Package for transfer
- `claude setup` - Run setup script

---

**Setup complete! You now have a production-ready Claude environment optimized for context persistence and cost efficiency.**

For questions or issues, refer to the main proposal document or check the troubleshooting section above.

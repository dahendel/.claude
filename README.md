# Claude Code User Environment

Optimized user-level environment for Claude Code with persistent memory, monitoring, and workflow automation.

## Quick Start

```bash
# Source aliases (add to ~/.bashrc or ~/.zshrc)
source ~/.claude/scripts/aliases.sh

# Check system health
claude-health

# Start all services
claude-start

# Initialize vector database
claude-init-db
```

## Directory Structure

```
~/.claude/
├── scripts/              # Executable scripts and tools
│   ├── aliases.sh        # Shell convenience commands
│   ├── monitor.py        # Health monitoring system
│   └── init-vectordb.py  # Vector DB initialization
├── docs/
│   ├── setup/           # Setup and architecture guides
│   └── reference/       # Quick command references
├── config/              # Configuration files
│   ├── docker-compose.yml
│   └── templates/       # Config templates
├── CLAUDE.md            # Global preferences (auto-loaded)
└── .gitignore          # Git sync configuration
```

## Key Features

### Three-Layer Memory Architecture
1. **CLAUDE.md files** - Auto-loaded context (free, instant)
2. **Vector Database** - Persistent cross-session memory (Chroma)
3. **Prompt Caching** - 90% cost savings on repeated context

### Proactive Context Management
- Monitor with: `claude-context-check`
- Target: Keep under 70% for optimal quality
- Compact at 70%, never wait for auto-compact at 95%

### Service Orchestration
- **Chroma** (port 8000): Vector database for memory
- **Qdrant** (port 6333): Alternative vector store
- **Ollama** (port 11434): Local LLM support

## Essential Commands

```bash
# Daily Workflow
claude-status              # Check services and context
claude-backup             # Create backup
claude-health             # Full health check (0-100 score)

# Service Management
claude-start              # Start all Docker services
claude-stop               # Stop all services
claude-restart            # Restart services

# Context Management
claude-store "info"       # Store in vector DB
claude-search "query"     # Search memory
claude-context-check      # Check usage percentage

# Database
claude-init-db           # Initialize vector DB
claude-db-info           # Show DB statistics
```

## Performance Targets

- Monthly cost: <$10 for 100 sessions
- Cache hit rate: >70%
- Context usage: Keep under 70%
- Zero auto-compacts per month

## Configuration

### MCP Servers
Configured in `~/.config/Claude/claude_desktop_config.json`:
- Chroma: Vector database for persistent memory
- rapid7: Documentation lookup

### Git Sync
Repository: `git@github.com:dahendel/.claude.git`
- Syncs: Scripts, docs, config, CLAUDE.md
- Excludes: Runtime data, backups, databases, credentials

## Documentation

- **Quick Commands**: `docs/reference/QUICK_COMMANDS.md`
- **Setup Complete**: `docs/setup/SETUP_COMPLETE.md`
- **Project Level Guide**: `docs/setup/PROJECT_LEVEL_GUIDE.md`
- **Sync Comparison**: `docs/setup/SYNC_COMPARISON.md`

## Troubleshooting

```bash
# Check MCP server status
claude-mcp-status

# View logs
tail -f ~/.config/Claude/logs/mcp*.log

# Test vector DB connection
python ~/.claude/scripts/init-vectordb.py

# Full health report
claude-health
```

## Key Principles

1. **Proactive over Reactive** - Manage context before problems
2. **Persistent over Ephemeral** - Store important information
3. **Efficient over Verbose** - Use tokens wisely
4. **Quality over Speed** - Never compromise on testing
5. **Private by Default** - Security and privacy first

---

**Status**: Production-ready
**Last Updated**: 2025-10-25
**Documentation**: See `docs/` for detailed guides

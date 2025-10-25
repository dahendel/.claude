# Claude Code Quick Commands Reference

## 🚀 Daily Workflow

### Morning Start
```bash
# Source aliases (add to ~/.bashrc for automatic loading)
source ~/.claude/aliases.sh

# Check system health
claude-health

# Start Docker services
claude-start

# View full dashboard
claude-status
```

### During Work
```bash
# In Claude sessions, monitor context:
/context                    # Check current usage

# At 70% context:
/compact keep {critical info}

# Store important decisions:
"Store in memory: {decision/context}"

# Retrieve past context:
"What do you remember about {topic}?"
```

### Evening Wrap-up
```bash
# Create backup (recommended weekly)
claude-backup

# Optional: Stop services to save resources
claude-stop
```

---

## 📊 Health & Status Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `claude-status` | Full dashboard with all metrics | Weekly check-in |
| `claude-health` | Quick pass/fail status | Daily health check |
| `claude-usage` | Disk usage statistics | Monthly cleanup |

**Example Output:**
```
claude-health
  Vector DB: ✅
  Chroma: ✅
  Backups: ✅ (7)
  CLAUDE.md: ✅
```

---

## 💾 Backup & Restore

### Create Backup
```bash
claude-backup
# Creates: ~/.claude/backups/claude-backup-YYYYMMDD_HHMMSS.tar.gz
# Automatically keeps 7 most recent backups
```

### Restore from Backup
```bash
# List available backups
claude-restore

# Restore specific backup
claude-restore ~/.claude/backups/claude-backup-20251025_120000.tar.gz
```

### Clean Old Backups
```bash
# Keep 7 most recent (default)
claude-clean

# Keep specific number
claude-clean 5
```

---

## 🐳 Docker Service Management

### Basic Operations
```bash
claude-start          # Start all services (Chroma, optional: Qdrant, Ollama)
claude-stop           # Stop all services
claude-restart        # Restart all services
```

### Monitoring
```bash
claude-services       # List running containers
claude-logs           # View Chroma logs (live tail)
claude-logs qdrant    # View specific service logs
```

### Service Endpoints
- **Chroma:** http://localhost:8000
- **Qdrant:** http://localhost:6333 (if enabled)
- **Ollama:** http://localhost:11434 (if enabled)

---

## 🗄️ Database Management

### Initialize Database
```bash
claude-init-db
# Creates standard collections:
#   - claude-memory (general context)
#   - code-context (code snippets)
#   - architecture-decisions (design decisions)
#   - project-notes (project-specific)
```

### Test Database Connection
```bash
claude-test
# Tests:
#   - Chroma API connectivity
#   - Database file existence
#   - Docker daemon access
```

---

## ⚙️ Configuration Management

### Edit Global Preferences
```bash
claude-edit-global
# Opens: ~/.claude/CLAUDE.md
# Auto-loaded in ALL Claude sessions
```

### Edit Project Configuration
```bash
cd /path/to/project
claude-edit-project
# Opens: ./CLAUDE.md (creates if missing)
# Loaded when working in this directory
```

---

## 📈 Context Management in Claude

### Check Context Usage
```
/context
```

### Context Zones & Actions

| Zone | Usage | Status | Action |
|------|-------|--------|--------|
| 🟢 Green | 0-70% | Normal | Continue working |
| 🟠 Orange | 70-85% | Caution | Plan compaction or save to vector DB |
| 🔴 Red | 85-95% | Critical | Stop work, save state, restart session |
| ⚠️ Danger | 95%+ | Emergency | Never reach - auto-compact degrades quality |

### Proactive Compaction
```
# At 70% - Manual compact with retention
/compact keep architecture decisions and current implementation approach

# Between unrelated tasks
/clear

# For major features
/quit
# Then restart Claude
```

### Memory Storage
```
# Store important context in vector DB
"Store in memory: We chose FastAPI because it has async support and automatic OpenAPI docs"

# Retrieve stored context
"What do you remember about our framework decision?"

# Session handoff
"Summarize this session and store key decisions"
```

---

## 🎯 Performance Targets

| Metric | Target | How to Achieve |
|--------|--------|----------------|
| Auto-compacts | 0/month | Manual compact at 70% |
| Context usage | <70% avg | Frequent /clear, store in vector DB |
| Monthly cost | <$10 | Cache hit >70%, efficient retrieval |
| Cache hit rate | >70% | Use CLAUDE.md, vector DB retrieval |
| Backup age | <7 days | Weekly `claude-backup` |

---

## 🆘 Troubleshooting

### Vector Database Issues
```bash
# Database not found
claude-init-db

# Chroma not responding
claude-restart
claude-test

# Verify Docker is running
docker ps
```

### MCP Server Issues
```bash
# Check MCP status in Claude
/mcp

# View MCP logs (if using Claude Desktop)
tail -f ~/.config/Claude/logs/mcp*.log

# Test Chroma MCP manually
uvx chroma-mcp --client-type persistent --data-dir ~/.claude/chroma-data
```

### Context Quality Degraded
```bash
# Check if auto-compact occurred (in Claude)
# Look for quality issues, repeated questions, generic responses

# Recovery:
/quit                                    # Exit session
"What do you remember about {topic}?"   # Retrieve from vector DB
# Share relevant CLAUDE.md sections again
```

### High Costs
```bash
# Check cache performance
claude-status  # Look for cache hit rate

# Review context usage patterns
# - Are you exceeding 70% regularly?
# - Using /clear between tasks?
# - Storing context in vector DB?
```

---

## 🔧 Advanced Operations

### Enable Optional Services
```bash
# Start Qdrant (high-performance vector DB)
docker compose --profile optional up -d qdrant

# Start Ollama (local embeddings)
docker compose --profile optional up -d ollama

# Pull embedding model (after starting Ollama)
docker exec claude-ollama ollama pull nomic-embed-text
```

### Custom Collection Management
```python
# In Python with chromadb installed
import chromadb
client = chromadb.HttpClient(host="localhost", port=8000)

# Create custom collection
collection = client.create_collection(
    name="my-custom-collection",
    metadata={"description": "Custom context storage"}
)

# Add documents
collection.add(
    ids=["id1"],
    documents=["Your context here"],
    metadatas=[{"type": "custom", "project": "my-app"}]
)
```

### Backup to Remote Storage
```bash
# Manual sync to remote (example with rsync)
rsync -avz ~/.claude/backups/ user@remote:/backups/claude/

# Or use S3 (requires aws-cli)
aws s3 sync ~/.claude/backups/ s3://my-bucket/claude-backups/
```

---

## 💡 Pro Tips

1. **Source aliases permanently:**
   ```bash
   echo 'source ~/.claude/aliases.sh' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Weekly backup reminder (cron):**
   ```bash
   crontab -e
   # Add: 0 9 * * 0 ~/.claude/aliases.sh && claude-backup
   ```

3. **Monitor context proactively:**
   - Check `/context` every 30-60 minutes during long sessions
   - Set personal rule: Manual compact at 65-70%
   - Never let it reach 85%+

4. **Efficient memory usage:**
   - Store architecture decisions immediately
   - Use CLAUDE.md for repeated context
   - Query vector DB before re-explaining

5. **Cost optimization:**
   - Keep CLAUDE.md under 200 lines
   - Use vector DB retrieval (5K tokens) vs re-loading context (20K tokens)
   - Maintain >70% cache hit rate

---

## 📚 Additional Resources

- **Full Documentation:** `~/.claude/README.md`
- **Setup Guide:** See local-claude project docs
- **Optimization Proposal:** Complete architecture details
- **Health Dashboard:** `python3 ~/.claude/monitor.py`

---

**Quick Help:**
```bash
claude-help    # Show all available commands
```

**Last Updated:** 2025-10-25

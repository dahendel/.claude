# Docker Vector Database - Quick Start

**Get your local vector database running in 5 minutes!**

---

## ⚡ Ultra-Quick Start (30 seconds)

```bash
# 1. Load aliases
source ~/.claude/aliases.sh

# 2. Start vector database
claude-start

# 3. Initialize collections
claude-init-db

# 4. Test connection
claude-test
```

**Done!** Vector database is now running at `http://localhost:8000`

---

## 📋 What You Need

✅ Docker installed and running
✅ Shell aliases loaded (`source ~/.claude/aliases.sh`)

---

## 🚀 Step-by-Step Setup

### 1. Start Services (20 seconds)

```bash
claude-start
```

**Expected output:**
```
╔════════════════════════════════════════════════════════╗
║     Claude Services Manager                            ║
╚════════════════════════════════════════════════════════╝

Starting Claude services...

✓ Services started successfully

Services are running!

Access points:
  Chroma API:  http://localhost:8000
  Chroma UI:   http://localhost:8000/api/v1
```

### 2. Initialize Collections (10 seconds)

```bash
claude-init-db
```

**Creates these collections:**
- `claude-memory` - General conversation memory
- `code-context` - Code snippets and context
- `architecture-decisions` - Design decisions
- `project-notes` - Project-specific notes

### 3. Test Everything (5 seconds)

```bash
claude-test
```

**Should show:**
```
Testing Service Connections:

Chroma API... ✓ OK
  Version: 0.x.x
  Collections: 4 found
    - claude-memory
    - code-context
    - architecture-decisions
    - project-notes
```

---

## 💻 Daily Usage

### Start Your Day

```bash
# Start vector database
claude-start

# Check it's healthy
claude-services status
```

### During Work

Use Claude normally - it will use the vector database automatically once MCP is configured!

```
"Store in memory: We decided to use FastAPI for async support"
"What do you remember about our framework decisions?"
```

### End of Day

```bash
# Optional: Create backup
claude-backup

# Optional: Stop services (or leave running)
claude-stop
```

---

## 🔧 Common Commands

### Service Management
```bash
claude-start       # Start vector database
claude-stop        # Stop services
claude-restart     # Restart services
claude-services    # Show help
```

### Health & Monitoring
```bash
claude-test        # Test connectivity
claude-services status
claude-logs        # View logs
```

### Database Operations
```bash
claude-init-db     # Initialize collections
claude-backup      # Backup database
claude-restore     # Restore from backup
```

---

## 🎯 Configure Claude Desktop (Optional)

To enable MCP integration with Claude Desktop:

### 1. Copy Configuration

```bash
# Linux
cp ~/.claude/claude_desktop_config_docker.json \
   ~/.config/Claude/claude_desktop_config.json

# macOS
cp ~/.claude/claude_desktop_config_docker.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### 2. Restart Claude Desktop

Close and reopen the application.

### 3. Verify Connection

In Claude Desktop:
```
/mcp
```

Should show Chroma server connected!

### 4. Test Memory

```
"Store in memory: Docker setup completed successfully on 2025-10-23"
```

New conversation:
```
"What do you remember about the Docker setup?"
```

---

## 🐛 Troubleshooting

### Services Won't Start

**Check Docker:**
```bash
docker info
```

If not running:
```bash
# Linux
sudo systemctl start docker

# macOS
# Open Docker Desktop app
```

### Port 8000 Already In Use

```bash
# Find what's using it
lsof -i :8000

# Kill it or change port in docker-compose.yml
```

### Cannot Connect

```bash
# Check container is running
docker ps | grep chroma

# View logs
claude-logs

# Restart services
claude-restart
```

### Collections Not Created

```bash
# Reinitialize
claude-init-db

# Or create manually via API
curl -X POST http://localhost:8000/api/v1/collections \
  -H "Content-Type: application/json" \
  -d '{"name":"test-collection"}'
```

---

## 📊 What's Running?

### Chroma Container

```bash
docker ps
```

Shows:
```
CONTAINER ID   IMAGE          PORTS                    NAMES
abc123...      chroma:latest  0.0.0.0:8000->8000/tcp  claude-chroma
```

### Data Location

```
~/.claude/chroma-data/
```

All your vector embeddings and documents are stored here persistently.

### Network

```
claude-network (bridge)
```

Isolated Docker network for Claude services.

---

## 🎓 Next Level

### Add Local Embeddings (Zero API Cost)

Edit `~/.claude/docker-compose.yml` and uncomment the Ollama section.

```bash
claude-restart

# Install embedding model
docker exec claude-ollama ollama pull nomic-embed-text
```

### Try Qdrant (Faster Alternative)

Edit `~/.claude/docker-compose.yml` and uncomment the Qdrant section.

```bash
claude-restart
```

Access dashboard: `http://localhost:6333/dashboard`

### Automate Backups

```bash
# Add to crontab
crontab -e

# Backup every Sunday at 2 AM
0 2 * * 0 /home/dahendel/.claude/manage-context.sh backup
```

---

## 📚 Full Documentation

- **Complete Guide:** `cat ~/.claude/DOCKER_SETUP.md`
- **API Reference:** Included in DOCKER_SETUP.md
- **Troubleshooting:** Detailed section in DOCKER_SETUP.md

---

## ✅ Checklist

After following this guide, you should have:

- [x] Vector database running in Docker
- [x] Chroma accessible at http://localhost:8000
- [x] 4 collections initialized
- [x] Connection tested and working
- [x] Shell commands available
- [ ] MCP configured (optional, for Claude Desktop)
- [ ] Tested storing/retrieving memories (after MCP)

---

## 🎉 Success!

Your local vector database is now running!

**Verify with:**
```bash
claude-test
```

**Use from command line:**
```bash
curl http://localhost:8000/api/v1/heartbeat
```

**View in browser:**
```
http://localhost:8000/api/v1
```

---

**Questions?** See `~/.claude/DOCKER_SETUP.md` for complete documentation

**Having issues?** Run `claude-logs` to see what's happening

**Want more features?** Check the Advanced Configuration section in DOCKER_SETUP.md

---

**Happy coding with persistent memory! 🚀**

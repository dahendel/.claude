# Docker-Based Vector Database Setup

**Complete guide to running a local vector database with Docker for Claude Code optimization**

---

## Overview

This setup provides:
- **Chroma vector database** running in Docker
- **Persistent storage** in `~/.claude/chroma-data`
- **HTTP API** on `localhost:8000`
- **MCP integration** for Claude Desktop/Code
- **Easy management** via shell commands

---

## Prerequisites

### 1. Install Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in for group changes
```

**macOS:**
```bash
brew install --cask docker
# Open Docker Desktop application
```

**Windows (WSL2):**
```bash
curl -fsSL https://get.docker.com | sh
sudo service docker start
```

### 2. Verify Installation

```bash
docker --version
docker compose version  # or docker-compose --version
```

---

## Quick Start

### 1. Start Vector Database

```bash
# Load aliases if not already loaded
source ~/.claude/aliases.sh

# Start Chroma vector database
claude-start

# Wait for startup (about 10 seconds)
# Check status
claude-services status
```

### 2. Initialize Collections

```bash
# Create standard collections
claude-init-db

# Or with sample data
claude-init-db --with-samples
```

### 3. Test Connection

```bash
# Test API connectivity
claude-test

# Or manually
curl http://localhost:8000/api/v1/heartbeat
```

### 4. Configure MCP (Claude Desktop)

```bash
# Copy Docker-based MCP config
cp ~/.claude/claude_desktop_config_docker.json \
   ~/.config/Claude/claude_desktop_config.json

# Restart Claude Desktop
```

---

## Service Management

### Start Services

```bash
claude-start
# or
claude-services start
```

**What this does:**
- Pulls latest Chroma image (first time)
- Creates Docker network
- Mounts `~/.claude/chroma-data` volume
- Starts container on port 8000
- Runs health checks

### Stop Services

```bash
claude-stop
# or
claude-services stop
```

**What this does:**
- Gracefully stops containers
- Preserves all data in volumes
- Network remains for future use

### Restart Services

```bash
claude-restart
# or
claude-services restart
```

### Check Status

```bash
claude-services status
```

**Shows:**
- Container status (running/stopped)
- Health check results
- Collection count
- Volume sizes
- Access URLs

### View Logs

```bash
# Recent logs
claude-logs

# Follow logs (live)
claude-logs -f

# Specific service
claude-logs chroma
```

### Test Connectivity

```bash
claude-test
```

**Tests:**
- Chroma API health
- Collection listing
- Version information

---

## Collections Management

### Create Collections

Collections are automatically created by `claude-init-db`:

- **claude-memory** - General conversation memory
- **code-context** - Code snippets and technical context
- **architecture-decisions** - Architecture decisions and rationale
- **project-notes** - Project-specific notes

### Custom Collection

```python
import requests

response = requests.post(
    "http://localhost:8000/api/v1/collections",
    json={
        "name": "my-collection",
        "metadata": {"description": "Custom collection"}
    }
)
```

### List Collections

```bash
curl http://localhost:8000/api/v1/collections | python3 -m json.tool
```

### Delete Collection

```bash
curl -X DELETE http://localhost:8000/api/v1/collections/collection-name
```

---

## Data Management

### Backup

The standard backup script includes vector DB data:

```bash
claude-backup
```

This creates:
```
~/.claude/backups/chroma_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Restore

```bash
claude-restore
```

Restores from backup archives.

### Clean Data (DESTRUCTIVE)

```bash
# Removes ALL vector DB data
claude-services clean
```

⚠️ **Warning:** This deletes all collections and documents!

### Manual Backup

```bash
# Stop services first
claude-stop

# Backup data directory
tar -czf ~/chroma-backup.tar.gz -C ~/.claude chroma-data/

# Restart services
claude-start
```

---

## MCP Integration

### Claude Desktop Configuration

**File:** `~/.config/Claude/claude_desktop_config.json` (Linux)
**File:** `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)

**Content:**
```json
{
  "mcpServers": {
    "chroma": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-chroma",
        "http://localhost:8000"
      ]
    }
  }
}
```

### Verify MCP Connection

1. Restart Claude Desktop
2. In Claude: Check available tools with `/mcp`
3. Should show Chroma server connected

### Using from Claude

```
"Store in memory: Important architecture decision about using FastAPI"
"What do you remember about FastAPI?"
"Search memory for decisions made last week"
```

---

## Advanced Configuration

### Enable Qdrant (Alternative)

Edit `~/.claude/docker-compose.yml`:

```yaml
# Uncomment the qdrant service section
```

Then:
```bash
claude-restart
```

Access:
- API: http://localhost:6333
- Dashboard: http://localhost:6333/dashboard

### Enable Local Embeddings (Ollama)

Edit `~/.claude/docker-compose.yml`:

```yaml
# Uncomment the ollama service section
```

Then:
```bash
claude-restart

# Install embedding model
docker exec claude-ollama ollama pull nomic-embed-text
```

**Benefits:**
- Zero API costs for embeddings
- Faster embedding generation
- Complete privacy (no external calls)

### Custom Port

Edit `~/.claude/docker-compose.yml`:

```yaml
ports:
  - "9000:8000"  # Change 8000 to your preferred port
```

Update MCP config accordingly.

---

## Troubleshooting

### Services Won't Start

**Check Docker:**
```bash
docker info
sudo systemctl status docker  # Linux
open -a Docker  # macOS
```

**Check port conflicts:**
```bash
lsof -i :8000  # Check if port 8000 is in use
```

**View detailed logs:**
```bash
claude-logs -f
```

### Cannot Connect to API

**Verify service is running:**
```bash
docker ps | grep claude-chroma
```

**Test directly:**
```bash
curl http://localhost:8000/api/v1/heartbeat
```

**Check firewall:**
```bash
sudo ufw status  # Linux
```

### MCP Not Connecting

**Check Claude Desktop config:**
```bash
cat ~/.config/Claude/claude_desktop_config.json | python3 -m json.tool
```

**Verify services running:**
```bash
claude-test
```

**Check Claude Desktop logs:**
```bash
tail -f ~/.config/Claude/logs/mcp*.log
```

### Data Not Persisting

**Check volume mount:**
```bash
docker inspect claude-chroma | grep Mounts -A 10
```

**Verify data directory:**
```bash
ls -la ~/.claude/chroma-data/
```

**Check permissions:**
```bash
chmod 755 ~/.claude/chroma-data
```

### High Memory Usage

**Check container stats:**
```bash
docker stats claude-chroma
```

**Limit memory (edit docker-compose.yml):**
```yaml
services:
  chroma:
    deploy:
      resources:
        limits:
          memory: 1G
```

---

## Performance Tuning

### Memory Limits

```yaml
services:
  chroma:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 512M
```

### Restart Policies

```yaml
services:
  chroma:
    restart: always  # or: on-failure, unless-stopped
```

### Health Check Tuning

```yaml
healthcheck:
  interval: 60s      # Increase for less overhead
  timeout: 10s
  retries: 3
  start_period: 30s  # Reduce if starts quickly
```

---

## Monitoring

### Container Stats

```bash
docker stats claude-chroma
```

Shows:
- CPU usage
- Memory usage
- Network I/O
- Disk I/O

### Collection Stats

```bash
curl http://localhost:8000/api/v1/collections | python3 -c "
import sys, json
collections = json.load(sys.stdin)
for coll in collections:
    print(f\"{coll['name']}: {coll.get('count', 0)} documents\")
"
```

### Log Analysis

```bash
docker logs claude-chroma --since 1h | grep ERROR
```

---

## Security

### Network Isolation

By default, Chroma only listens on localhost (127.0.0.1).

**Do NOT expose to internet without authentication!**

### Authentication (Optional)

Chroma doesn't have built-in auth. For production:

1. Use reverse proxy (nginx) with basic auth
2. Use VPN for remote access
3. Use SSH tunneling

Example nginx config:
```nginx
location /chroma/ {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:8000/;
}
```

### Backup Encryption

```bash
# Encrypt backup
claude-backup
gpg --symmetric ~/.claude/backups/chroma_backup_*.tar.gz

# Decrypt
gpg --decrypt backup.tar.gz.gpg > backup.tar.gz
```

---

## Docker Compose Reference

### Full docker-compose.yml

Located at: `~/.claude/docker-compose.yml`

### Environment Variables

```yaml
environment:
  - IS_PERSISTENT=TRUE           # Enable persistence
  - ANONYMIZED_TELEMETRY=FALSE   # Disable telemetry
  - ALLOW_RESET=TRUE             # Allow database reset
  # - CHROMA_API_IMPL=rest       # API implementation
  # - CHROMA_HOST=0.0.0.0        # Listen address (default: localhost)
```

### Volume Configuration

```yaml
volumes:
  - ${HOME}/.claude/chroma-data:/chroma/chroma  # Data storage
  # - ./config:/chroma/config                   # Custom config
```

---

## Upgrading

### Update Chroma Image

```bash
# Stop services
claude-stop

# Pull latest image
cd ~/.claude
docker compose pull

# Restart services
claude-start

# Verify version
claude-test
```

### Rollback

```bash
# Stop services
claude-stop

# Edit docker-compose.yml to pin version
# image: ghcr.io/chroma-core/chroma:0.4.15

# Start with specific version
claude-start
```

---

## API Reference

### Base URL

```
http://localhost:8000/api/v1
```

### Common Endpoints

```bash
# Health check
GET /heartbeat

# List collections
GET /collections

# Create collection
POST /collections
Body: {"name": "my-collection", "metadata": {...}}

# Add documents
POST /collections/{collection}/add
Body: {"ids": [...], "documents": [...], "metadatas": [...]}

# Query
POST /collections/{collection}/query
Body: {"query_texts": ["search text"], "n_results": 10}

# Delete collection
DELETE /collections/{collection}
```

### Python Example

```python
import requests

# Add document
response = requests.post(
    "http://localhost:8000/api/v1/collections/claude-memory/add",
    json={
        "ids": ["doc1"],
        "documents": ["This is important information"],
        "metadatas": [{"source": "manual", "timestamp": "2025-10-23"}]
    }
)

# Query
response = requests.post(
    "http://localhost:8000/api/v1/collections/claude-memory/query",
    json={
        "query_texts": ["important information"],
        "n_results": 5
    }
)

results = response.json()
```

---

## Next Steps

### After Setup

1. ✅ Services running: `claude-services status`
2. ✅ Collections created: `claude-init-db`
3. ✅ MCP configured: Copy config to Claude Desktop
4. ✅ Test integration: "Store in memory: Setup complete"

### Daily Usage

```bash
# Morning
claude-start           # Start services

# During work
# Use Claude with persistent memory

# Evening
claude-backup          # Weekly backup (automate if desired)
# Leave running or:
claude-stop            # Stop services
```

### Monitoring

```bash
# Weekly check
claude-status          # Overall health
claude-services status # Docker services
claude-usage           # Usage statistics
```

---

## Resources

**Official Documentation:**
- Chroma: https://docs.trychroma.com
- Docker: https://docs.docker.com
- MCP: https://modelcontextprotocol.io

**Chroma Docker Image:**
- Repository: https://github.com/chroma-core/chroma
- Image: ghcr.io/chroma-core/chroma

**Support:**
- Chroma Discord: https://discord.gg/MMeYNTmh3x
- Issues: https://github.com/chroma-core/chroma/issues

---

**Last Updated:** 2025-10-23
**Version:** 1.0
**Status:** Production Ready 🚀

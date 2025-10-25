# Project-Level Claude Integration Guide

## Architecture Decision: Hybrid Approach

Use **BOTH** user-level and project-level configurations for maximum flexibility:

```
User-Level (~/.claude/)          Project-Level (./project/)
├── Personal preferences         ├── CLAUDE.md (team-shared)
├── Global vector DB             ├── .claude/ (team tools, COMMITTED)
├── Convenience scripts          └── .claude-local/ (data, GITIGNORED)
└── Docker orchestration
```

---

## Project-Level Setup

### 1. Directory Structure

```bash
# In your project root
mkdir -p .claude .claude-local/chroma-data

# Add to .gitignore
cat >> .gitignore << 'EOF'
# Claude local data (NEVER commit these)
.claude-local/
*.sqlite3
credentials.json
.env
EOF
```

### 2. Project CLAUDE.md (COMMIT THIS)

```markdown
# Project: YourProject

## Team Context
- Tech Stack: Python 3.11+, FastAPI, PostgreSQL
- Vector DB: Chroma (project-local)
- MCP Servers: Chroma, filesystem

## Architecture
See docs/architecture.md

## Common Commands
\`\`\`bash
# Development
docker compose up -d
python -m pytest tests/
\`\`\`

## GHA Integration
This project uses Claude context in CI/CD pipelines.
See .github/workflows/claude-context.yml
```

### 3. Project Docker Compose (.claude/docker-compose.yml)

```yaml
version: '3.8'

services:
  chroma:
    image: chromadb/chroma:latest
    container_name: ${PROJECT_NAME:-project}-chroma
    ports:
      - "${CHROMA_PORT:-8001}:8000"
    volumes:
      - ../.claude-local/chroma-data:/chroma/chroma
    environment:
      - IS_PERSISTENT=TRUE
      - ANONYMIZED_TELEMETRY=FALSE
    restart: unless-stopped
```

**Key differences from global:**
- Uses `.claude-local/` for data (gitignored)
- Custom port to avoid conflicts
- Project-specific container name

### 4. Project Initialization Script (.claude/init-project.sh)

```bash
#!/bin/bash
# Initialize project-level Claude environment

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_LOCAL="$PROJECT_ROOT/.claude-local"

echo "Initializing Claude project environment..."

# Create directories
mkdir -p "$CLAUDE_LOCAL/chroma-data"
mkdir -p "$CLAUDE_LOCAL/backups"

# Start project Chroma (different port)
cd "$PROJECT_ROOT/.claude"
docker compose up -d

# Wait for Chroma
echo "Waiting for Chroma to start..."
sleep 5

# Initialize collections
python3 << 'PYTHON'
import chromadb
import os

# Connect to project Chroma
client = chromadb.HttpClient(host="localhost", port=8001)

# Create project-specific collections
collections = [
    "project-memory",
    "code-context",
    "test-results",
    "deployment-logs"
]

for coll in collections:
    try:
        client.create_collection(coll)
        print(f"✓ Created collection: {coll}")
    except:
        print(f"  Collection exists: {coll}")

print("\n✅ Project environment initialized")
PYTHON

echo ""
echo "Project Chroma: http://localhost:8001"
echo "Data location: .claude-local/chroma-data/"
```

---

## GitHub Actions Integration

### Security Considerations

#### ❌ **NEVER COMMIT:**
- Vector database files (`.sqlite3`)
- API keys or credentials
- Personal preferences
- Full conversation history
- `.claude-local/` directory

#### ✅ **SAFE TO COMMIT:**
- Project CLAUDE.md (team context)
- Initialization scripts
- Docker compose files
- MCP server configurations
- `.claude/` directory (tools only)

### GHA Workflow Example

**.github/workflows/claude-context.yml:**

```yaml
name: Claude Context Integration

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  CHROMA_PORT: 8001
  PROJECT_NAME: ${{ github.event.repository.name }}

jobs:
  setup-claude-context:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install chromadb

      - name: Start Chroma (ephemeral)
        run: |
          cd .claude
          docker compose up -d
          sleep 5

      - name: Initialize project context
        run: |
          bash .claude/init-project.sh

      - name: Load project knowledge base
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Index codebase for Claude
          python3 .claude/index-codebase.py

      - name: Run tests with Claude context
        run: |
          # Your test commands here
          python -m pytest tests/

      - name: Cleanup
        if: always()
        run: |
          docker compose down
          rm -rf .claude-local/
```

### Security Best Practices for GHA

#### 1. **Use Ephemeral Databases**
```yaml
# GHA: Start fresh each time
- name: Start Chroma
  run: |
    docker run -d --rm -p 8001:8000 chromadb/chroma:latest
```

#### 2. **Never Store Secrets in Vector DB**
```python
# BAD: Don't do this
collection.add(
    documents=[f"API Key: {api_key}"],  # ❌ NEVER
    ids=["secret_1"]
)

# GOOD: Use GitHub Secrets
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

#### 3. **Encrypt Persistent Context (if needed)**
```bash
# If you must persist context between runs:
- name: Cache encrypted context
  uses: actions/cache@v3
  with:
    path: .claude-local/chroma-data
    key: ${{ runner.os }}-chroma-${{ hashFiles('src/**') }}

# Encrypt before caching
- name: Encrypt context
  run: |
    tar -czf context.tar.gz .claude-local/
    openssl enc -aes-256-cbc -salt \
      -in context.tar.gz \
      -out context.tar.gz.enc \
      -pass pass:${{ secrets.ENCRYPTION_KEY }}
```

#### 4. **Limit Scope**
```yaml
permissions:
  contents: read        # Read-only access to repo
  issues: write         # Only if needed for comments
  pull-requests: write  # Only if needed for PR comments
```

---

## Security Implications Summary

### ⚠️ **Risks of Project-Level Context:**

1. **Credential Leakage**
   - Risk: API keys in vector DB committed to repo
   - Mitigation: Use `.claude-local/` (gitignored), GitHub Secrets

2. **Sensitive Code Exposure**
   - Risk: Internal architecture in embeddings
   - Mitigation: Separate public/private contexts, encrypt at rest

3. **Data Persistence in CI**
   - Risk: Context bleeding between builds
   - Mitigation: Ephemeral containers, clean state each run

4. **Team Member Access**
   - Risk: Everyone sees all stored context
   - Mitigation: Role-based collections, project isolation

### ✅ **Secure Architecture:**

```
Security Layers:

1. Filesystem (GITIGNORED)
   .claude-local/                 # Never committed
   └── chroma-data/              # Local vector DB

2. Docker Isolation
   Container: project-chroma     # Isolated network
   Volume: .claude-local/        # Host filesystem only

3. GitHub Secrets
   ANTHROPIC_API_KEY            # Encrypted at rest
   CHROMA_ENCRYPTION_KEY        # Optional DB encryption

4. Access Control
   GitHub: Branch protection     # Review before merge
   Docker: No external ports     # Localhost only
```

---

## Migration Path: User → Project-Level

### Step 1: Export User-Level Context
```bash
# Export project-relevant context
python3 << 'PYTHON'
import chromadb

# Connect to user-level DB
user_client = chromadb.PersistentClient(path="~/.claude/chroma-data")
user_coll = user_client.get_collection("claude-memory")

# Query project-specific entries
results = user_coll.query(
    query_texts=["project architecture"],
    where={"project": "myproject"},
    n_results=100
)

# Export to JSON
import json
with open("project-context-export.json", "w") as f:
    json.dump(results, f)
PYTHON
```

### Step 2: Initialize Project Environment
```bash
cd /path/to/project
mkdir -p .claude .claude-local/chroma-data

# Copy initialization scripts
cp ~/.claude/docker-compose.yml .claude/
# Modify ports, paths as needed
```

### Step 3: Import Context
```bash
# Start project Chroma
cd .claude && docker compose up -d

# Import exported context
python3 << 'PYTHON'
import chromadb
import json

# Connect to project DB
client = chromadb.HttpClient(host="localhost", port=8001)
coll = client.create_collection("project-memory")

# Load exported context
with open("project-context-export.json") as f:
    data = json.load(f)

# Import (sanitize first!)
for doc, meta in zip(data["documents"], data["metadatas"]):
    # Remove any credentials
    if "api_key" in doc.lower() or "secret" in doc.lower():
        continue  # Skip sensitive data

    coll.add(
        ids=[meta["id"]],
        documents=[doc],
        metadatas=[meta]
    )
PYTHON
```

### Step 4: Update Team Documentation
```markdown
# Add to project README.md

## Claude Context Setup

This project uses project-level Claude integration for consistent AI assistance.

### Setup:
\`\`\`bash
# Initialize project environment
bash .claude/init-project.sh

# Verify
curl http://localhost:8001/api/v1/heartbeat
\`\`\`

### Usage:
- Project context auto-loads from CLAUDE.md
- Vector DB: http://localhost:8001
- Data stored in .claude-local/ (gitignored)
```

---

## Recommendation: **Hybrid Approach**

### For Your Setup:

1. **Keep user-level (~/.claude/)** for:
   - Personal preferences
   - Cross-project learning
   - Global convenience scripts
   - Development environment

2. **Add project-level** for:
   - Team-shared context (CLAUDE.md)
   - GHA pipeline integration
   - Project-specific vector DB
   - Reproducible setup

### Implementation:
```bash
# Global (existing)
~/.claude/
├── CLAUDE.md              # Personal preferences
├── aliases.sh             # Convenience commands
├── chroma-data/           # Global vector DB (port 8000)
└── docker-compose.yml     # Global services

# Project (new)
./project/
├── CLAUDE.md              # Team context (COMMITTED)
├── .claude/               # Tools (COMMITTED)
│   ├── docker-compose.yml # Project services (port 8001)
│   └── init-project.sh    # Setup script
└── .claude-local/         # Data (GITIGNORED)
    └── chroma-data/       # Project vector DB
```

This gives you:
- ✅ GHA integration (project-level)
- ✅ Personal productivity (user-level)
- ✅ Security (proper gitignore)
- ✅ Team collaboration (shared tools)

Would you like me to create the project-level setup files for a specific project?
# Git Sync Guide for .claude Directory

**Keep WSL (personal) and macOS (work) environments in sync via Git**

---

## 🎯 Strategy

- ✅ **Sync**: Scripts, configs, documentation, aliases
- ❌ **Don't sync**: Vector DB data, backups, personal data
- 🔒 **Privacy**: WSL personal data stays local, Mac work data stays local

---

## 🚀 Quick Setup

### One-Time Setup (WSL - Personal Machine)

```bash
cd ~/.claude

# Initialize Git repo
git init
git add .
git commit -m "Initial Claude environment setup"

# Create GitHub repo (private!)
gh repo create claude-env --private --source=. --remote=origin --push

# Or manually:
# 1. Create private repo on GitHub: https://github.com/new
# 2. git remote add origin https://github.com/YOUR_USERNAME/claude-env.git
# 3. git push -u origin main
```

### Clone on Mac (Work Machine)

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/claude-env.git ~/.claude-tmp
cd ~/.claude-tmp

# Run setup
bash setup-claude-env.sh

# The setup script will:
# - Copy files to ~/.claude/
# - Configure your Mac shell
# - Set up Docker services
# - Create EMPTY chroma-data/ and backups/ directories
```

---

## 📦 What Gets Synced

### ✅ Synced to Git (Configuration & Scripts)

```
~/.claude/
├── .gitignore                   # This file protects your data
├── setup-claude-env.sh          # Setup script
├── package-for-transfer.sh      # Packaging tool
├── aliases.fish                 # Shell aliases
├── aliases.sh                   # Shell aliases
├── claude-services.sh           # Docker management
├── docker-compose.yml           # Docker config
├── init-vectordb.py             # DB initialization
├── manage-context.sh            # Backup/restore
├── monitor.py                   # Health monitoring
├── CLAUDE.md                    # Your preferences
├── *.md                         # All documentation
├── bashrc_snippet.sh            # Shell snippets
└── fish_config_snippet.fish     # Shell snippets
```

### ❌ NOT Synced (Personal/Runtime Data)

```
~/.claude/
├── chroma-data/                 # Vector database (PERSONAL DATA)
├── backups/                     # Backup archives (PERSONAL DATA)
├── *.tar.gz                     # Transfer packages
├── *.backup                     # Backup files
├── *.log                        # Log files
└── *.sqlite3                    # Database files
```

---

## 🔄 Daily Workflow

### Making Changes on WSL (Personal)

```bash
cd ~/.claude

# Make changes to scripts or configs
vim aliases.fish
vim CLAUDE.md

# Commit and push
git add -A
git commit -m "Update Fish aliases and preferences"
git push
```

### Sync to Mac (Work)

```bash
cd ~/.claude

# Pull latest changes
git pull

# Restart shell to apply changes
exec fish  # or: source ~/.bashrc
```

### Making Changes on Mac (Work)

```bash
cd ~/.claude

# Make changes
vim setup-claude-env.sh

# Commit and push
git add -A
git commit -m "Improve setup script for macOS"
git push
```

### Sync to WSL (Personal)

```bash
cd ~/.claude

# Pull latest changes
git pull

# Restart shell if needed
exec fish
```

---

## 🔒 Privacy Protection

### The .gitignore File

This ensures your personal data never gets committed:

```gitignore
# Personal data
chroma-data/      # Your vector database
backups/          # Your backups
*.tar.gz          # Transfer packages

# Sensitive
*.sqlite3         # Database files
*.log             # Log files
```

### Verify What's Tracked

```bash
cd ~/.claude

# See what would be committed
git status

# See all tracked files
git ls-files

# Should NOT see:
# - chroma-data/
# - backups/
# - *.tar.gz
```

---

## 🚨 Important: Keep Repo Private

Your `CLAUDE.md` contains your workflow preferences and might reference:
- Project paths
- Tool configurations
- Development patterns

**Always use a private GitHub repository!**

```bash
# Verify repo is private
gh repo view

# Make existing repo private
gh repo edit --visibility private
```

---

## 📝 Recommended Git Workflow

### Branch Strategy

```bash
# Main branch: stable, tested configs
git checkout main

# Feature branch: test new changes
git checkout -b feature/new-aliases
# ... make changes ...
git commit -m "Add new aliases"
git push -u origin feature/new-aliases

# Test on other machine before merging
# If good, merge:
git checkout main
git merge feature/new-aliases
git push
```

### Commit Messages

Use conventional commits:

```bash
# Configuration changes
git commit -m "feat: add OpenTofu workspace aliases"
git commit -m "fix: correct Fish shell syntax in aliases"
git commit -m "docs: update transfer guide"

# Updates
git commit -m "chore: update setup script for Ubuntu 24.04"
git commit -m "refactor: simplify Docker service management"
```

---

## 🔧 Machine-Specific Customization

### Use CLAUDE.local.md (Optional)

Create machine-specific notes that DON'T sync:

```bash
# On WSL (personal)
cat > ~/.claude/CLAUDE.local.md << 'EOF'
# WSL Personal Machine

## Local Preferences
- Projects: ~/projects
- Docker: Desktop via Windows
- Primary language: Personal projects

## Local Notes
- This is my personal development environment
EOF

# On Mac (work)
cat > ~/.claude/CLAUDE.local.md << 'EOF'
# Mac Work Machine

## Local Preferences
- Projects: ~/work
- Docker: Docker Desktop
- Primary language: Work projects only

## Local Notes
- This is my work environment
- No personal projects here
EOF
```

Uncomment `CLAUDE.local.md` in `.gitignore` if you want these to stay local.

---

## 🎯 Best Practices

### DO ✅

- Commit configuration changes immediately
- Use descriptive commit messages
- Pull before making changes
- Keep the repo private
- Test changes on one machine before pushing
- Review `git status` before committing

### DON'T ❌

- Commit personal data (backups, vector DB)
- Make the repo public
- Commit API keys or tokens
- Commit machine-specific paths
- Force push (unless you know what you're doing)
- Commit large binary files

---

## 🆘 Troubleshooting

### Accidentally Committed Personal Data

```bash
# Remove from Git but keep locally
git rm --cached -r chroma-data/
git rm --cached -r backups/
git commit -m "Remove personal data from Git"
git push

# Add to .gitignore
echo "chroma-data/" >> .gitignore
echo "backups/" >> .gitignore
git add .gitignore
git commit -m "Update .gitignore"
git push
```

### Merge Conflicts

```bash
# Pull and see conflicts
git pull
# CONFLICT in CLAUDE.md

# Edit the file to resolve
vim CLAUDE.md

# Mark as resolved
git add CLAUDE.md
git commit -m "Merge: resolve CLAUDE.md conflict"
git push
```

### Reset to Remote

```bash
# Discard local changes and match remote
git fetch origin
git reset --hard origin/main

# WARNING: This deletes uncommitted changes!
```

---

## 🔄 Sync Automation (Optional)

### Auto-Pull on Shell Start

Add to your Fish config:

```fish
# Auto-pull Claude config on shell start (optional)
if status is-interactive; and not set -q CLAUDE_GIT_PULLED
    set -g CLAUDE_GIT_PULLED 1

    # Silent git pull in background
    fish -c 'cd ~/.claude && git pull --quiet >/dev/null 2>&1' &
    disown
end
```

### Daily Backup and Push (Optional)

```bash
# Add to crontab
crontab -e

# Daily at 11 PM: commit and push any changes
0 23 * * * cd ~/.claude && git add -A && git commit -m "Auto: daily sync $(date +\%Y-\%m-\%d)" && git push >/dev/null 2>&1
```

---

## 📊 Setup Verification

### After Initial Setup on WSL

```bash
cd ~/.claude

# Should show clean working tree
git status

# Should list all config files but NOT data
git ls-files | grep -E "(chroma-data|backups)"
# (should return nothing)
```

### After Clone on Mac

```bash
cd ~/.claude

# Should have all scripts
ls -la *.sh *.py *.md

# Should NOT have personal data
ls chroma-data/ backups/
# (should be empty or not exist)
```

---

## 🎓 Example: Full Sync Cycle

### Day 1: WSL → Mac

```bash
# On WSL (personal)
cd ~/.claude
vim aliases.fish  # Add new alias
git add aliases.fish
git commit -m "feat: add claude-logs-full alias"
git push

# On Mac (work)
cd ~/.claude
git pull
exec fish  # Reload shell
claude-logs-full  # New alias works!
```

### Day 2: Mac → WSL

```bash
# On Mac (work)
cd ~/.claude
vim setup-claude-env.sh  # Improve macOS detection
git add setup-claude-env.sh
git commit -m "fix: improve macOS architecture detection"
git push

# On WSL (personal)
cd ~/.claude
git pull
# Updated script ready to use
```

---

## 📋 Quick Command Reference

```bash
# Daily sync
cd ~/.claude
git pull
git add -A
git commit -m "Update: description"
git push

# Check status
git status
git log --oneline -5

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard origin/main

# See what changed
git diff
git diff HEAD~1
```

---

**Created:** 2025-10-24
**Privacy:** WSL personal data stays local, Mac work data stays local
**Synced:** Scripts, configs, documentation only

# Claude Environment

**Clean, organized Claude Code environment with vector database and cross-platform sync**

---

## 📁 Directory Structure

```
~/.claude/
├── README.md                # This file
├── CLAUDE.md                # Your preferences (auto-loaded)
├── claude                   # Main CLI wrapper
│
├── bin/                     # Executable scripts
│   ├── setup-claude-env.sh
│   ├── claude-services.sh
│   ├── manage-context.sh
│   ├── monitor.py
│   ├── init-vectordb.py
│   ├── package-for-transfer.sh
│   └── install.sh
│
├── config/                  # Configuration files
│   ├── aliases.fish
│   ├── aliases.sh
│   ├── docker-compose.yml
│   └── ...
│
├── docs/                    # Documentation
│   ├── INDEX.md            # Documentation index
│   ├── guides/             # How-to guides
│   └── reference/          # Reference docs
│
└── data/                    # Runtime data (gitignored)
    ├── chroma-data/        # Vector database
    └── backups/            # Backup archives
```

---

## 🚀 Quick Start

### Main Commands

```bash
claude help              # Show all commands
claude health            # Check environment status
claude start             # Start Docker services
claude backup "msg"      # Create backup
```

### All Available Commands

```bash
# Status & Health
claude health            # Quick health check
claude status            # Detailed monitoring

# Docker Services
claude start             # Start vector database
claude stop              # Stop services
claude restart           # Restart services
claude logs              # View logs
claude test              # Test connectivity

# Context Management
claude backup [msg]      # Create backup
claude restore           # Restore from backup
claude usage             # Show usage stats
claude clean             # Cleanup old backups

# Setup & Distribution
claude init-db           # Initialize vector database
claude package [file]    # Package for transfer
claude setup             # Run setup script

# Documentation
claude docs              # View documentation index
```

---

## 📚 Documentation

- **[docs/INDEX.md](docs/INDEX.md)** - Complete documentation index

### Guides
- **[TRANSFER_GUIDE.md](docs/guides/TRANSFER_GUIDE.md)** - Move to another machine
- **[QUICK_INSTALL_GUIDE.md](docs/guides/QUICK_INSTALL_GUIDE.md)** - Installation steps
- **[GIT_SYNC_GUIDE.md](docs/guides/GIT_SYNC_GUIDE.md)** - Git sync workflow
- **[DOCKER_SETUP.md](docs/guides/DOCKER_SETUP.md)** - Docker configuration
- **[FISH_SETUP.md](docs/guides/FISH_SETUP.md)** - Fish shell setup

### Reference
- **[QUICK_COMMANDS.md](docs/reference/QUICK_COMMANDS.md)** - Command reference
- **[OPENTOFU_ALIASES.md](docs/reference/OPENTOFU_ALIASES.md)** - OpenTofu shortcuts
- **[IMPLEMENTATION_SUMMARY.md](docs/reference/IMPLEMENTATION_SUMMARY.md)** - Technical details

---

## ⚙️ Features

✅ **Clean CLI** - Single `claude` command for everything
✅ **Organized Structure** - Logical file organization
✅ **Vector Database** - Chroma with Docker
✅ **Git Sync** - Sync configs between machines
✅ **Backup System** - Automated backups
✅ **Cross-Platform** - macOS and Linux support
✅ **OpenTofu Shortcuts** - 34+ time-saving aliases
✅ **Comprehensive Docs** - Detailed guides

---

## 🔧 Shell Integration

### Fish Shell

Your shell is already configured! Commands available:
```bash
claude-health            # Same as: claude health
claude-start             # Same as: claude start
# ... and more
```

### OpenTofu Shortcuts

34+ aliases already configured:
```bash
tf, tfa, tfaa, tfp, tfd, tfv, tff, tfs, tfo
tfsl, tfss, tfwl, tfwn, tfws
# ... and many more
```

See [docs/reference/OPENTOFU_ALIASES.md](docs/reference/OPENTOFU_ALIASES.md) for complete list.

---

## 🔄 Git Sync

Your environment is ready to sync via Git:

```bash
# Check status
cd ~/.claude
git status

# Commit changes
git add -A
git commit -m "Update: description"
git push

# On another machine
git pull
```

**What's synced:** Scripts, configs, docs
**What's NOT synced:** data/ (vector DB, backups, logs)

See [docs/guides/GIT_SYNC_GUIDE.md](docs/guides/GIT_SYNC_GUIDE.md) for details.

---

## 📦 Transfer to Another Machine

```bash
# On this machine
claude package

# Transfer ~/claude-env-YYYYMMDD.tar.gz to new machine

# On new machine
tar -xzf claude-env-*.tar.gz
cd .claude
bash bin/setup-claude-env.sh
```

See [docs/guides/TRANSFER_GUIDE.md](docs/guides/TRANSFER_GUIDE.md) for full guide.

---

## 🆘 Quick Troubleshooting

### Commands not found
```bash
source ~/.claude/config/aliases.fish  # Reload aliases
```

### Docker not running
```bash
# Start Docker Desktop (macOS/Windows)
# Or: sudo systemctl start docker (Linux)
claude start
```

### Check environment
```bash
claude health
```

---

## 📖 Learn More

```bash
# View documentation index
cat ~/.claude/docs/INDEX.md

# View quick commands
cat ~/.claude/docs/reference/QUICK_COMMANDS.md

# Get help
claude help
```

---

**Created:** 2025-10-24
**Version:** 2.0 (Reorganized)
**Platforms:** macOS (Intel/ARM), Linux (x86_64/ARM), WSL2
**Shells:** Fish, Bash, Zsh

# Claude Environment

**Cross-platform Claude Code optimization with vector database and context persistence**

---

## 🚀 Quick Start

### On This Machine (Already Installed)
```bash
claude-health          # Check status
claude-status          # Detailed info
claude-start           # Start services
```

### Transfer to Another Machine
```bash
# 1. Package
claude-package

# 2. Transfer file to new machine
scp ~/claude-env-*.tar.gz user@machine:~/

# 3. On new machine
tar -xzf claude-env-*.tar.gz
bash .claude/setup-claude-env.sh
```

---

## 📚 Documentation

**Start here:** [INDEX.md](INDEX.md) - Complete documentation index

### Essential Guides
- **[TRANSFER_GUIDE.md](TRANSFER_GUIDE.md)** - Move to new machine (⭐ Most Popular)
- **[QUICK_INSTALL_GUIDE.md](QUICK_INSTALL_GUIDE.md)** - Installation walkthrough
- **[QUICK_COMMANDS.md](QUICK_COMMANDS.md)** - Command reference

### Platform-Specific
- **[FISH_SETUP.md](FISH_SETUP.md)** - Fish shell users
- **[DOCKER_SETUP.md](DOCKER_SETUP.md)** - Docker configuration
- **[OPENTOFU_ALIASES.md](OPENTOFU_ALIASES.md)** - OpenTofu shortcuts

### Technical
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Architecture details
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## 🛠️ Available Commands

### Status & Health
```bash
claude-health          # Quick health check
claude-status          # Detailed monitoring
```

### Docker Services
```bash
claude-start           # Start vector database
claude-stop            # Stop services
claude-restart         # Restart services
claude-test            # Test connectivity
claude-logs            # View logs
```

### Context Management
```bash
claude-backup "msg"    # Create backup
claude-restore         # Restore from backup
claude-clean           # Cleanup old backups
claude-usage           # Show usage statistics
```

### Configuration
```bash
claude-edit-global     # Edit global preferences
claude-edit-project    # Edit project settings
claude-view-global     # View global config
claude-view-project    # View project config
```

### Distribution
```bash
claude-package         # Package for transfer
claude-setup           # Re-run setup script
```

### Database
```bash
claude-init-db         # Initialize vector database
claude-db-size         # Show database size
claude-db-check        # Check database integrity
```

### OpenTofu (34+ shortcuts)
```bash
tf, tfa, tfaa, tfp, tfd, tfv, tff, tfs, tfo
tfir, tfiu, tfpd, tfpo, tfao
tfsl, tfss, tfsm, tfsrm, tfsp, tfspu
tfwl, tfwn, tfws, tfwd
tfim, tftaint, tfuntaint
tfc, tfg
tfpi, tfpl, tfps
```

---

## 🎯 Common Tasks

### Check Environment
```bash
claude-health
```

### Start Working
```bash
claude-start           # Start services
claude-init-db         # Initialize database (first time)
```

### Before Major Changes
```bash
claude-backup "before refactoring auth module"
```

### End of Day
```bash
claude-clean           # Remove old backups
```

### Transfer to Mac/Linux
```bash
claude-package         # Creates ~/claude-env-YYYYMMDD.tar.gz
# Transfer file
# On new machine: tar -xzf file.tar.gz && bash .claude/setup-claude-env.sh
```

---

## 📂 Directory Structure

```
~/.claude/
├── README.md                    # This file
├── INDEX.md                     # Documentation index
├── TRANSFER_GUIDE.md           # Transfer guide ⭐
│
├── setup-claude-env.sh         # Main setup script
├── package-for-transfer.sh     # Create package
├── aliases.fish                # Fish aliases
├── aliases.sh                  # Bash/Zsh aliases
├── claude-services.sh          # Docker management
├── docker-compose.yml          # Docker config
├── init-vectordb.py            # DB initialization
├── manage-context.sh           # Backup/restore
├── monitor.py                  # Health monitoring
│
├── CLAUDE.md                   # Your preferences
├── chroma-data/                # Vector database
└── backups/                    # Backup archives
```

---

## ⚙️ Features

✅ **Context Persistence**: Never lose context between sessions
✅ **Vector Database**: Semantic search with Chroma
✅ **Auto-Backup**: Automated backup system
✅ **Docker Integration**: Easy service management
✅ **Shell Support**: Fish, Bash, Zsh
✅ **Cross-Platform**: macOS (Intel/ARM), Linux (x86_64/ARM)
✅ **OpenTofu Shortcuts**: 34+ time-saving aliases
✅ **Health Monitoring**: Real-time status checks
✅ **Easy Transfer**: One-command packaging
✅ **Documentation**: Comprehensive guides

---

## 🆘 Quick Troubleshooting

### Commands Not Found
```bash
source ~/.claude/aliases.fish  # Fish
source ~/.claude/aliases.sh    # Bash/Zsh
```

### Docker Not Running
```bash
# macOS: Start Docker Desktop
# Linux: sudo systemctl start docker
claude-start
```

### Database Issues
```bash
claude-restart
claude-test
claude-init-db
```

---

## 📖 Learn More

- **[INDEX.md](INDEX.md)** - Full documentation index
- **[TRANSFER_GUIDE.md](TRANSFER_GUIDE.md)** - Complete transfer guide
- **[QUICK_INSTALL_GUIDE.md](QUICK_INSTALL_GUIDE.md)** - Detailed setup
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Technical details

---

## 🎓 Getting Help

1. **Check health**: `claude-health`
2. **View status**: `claude-status`
3. **Read docs**: `cat ~/.claude/INDEX.md`
4. **Check logs**: `claude-logs`

---

## 📊 System Requirements

**Minimum:**
- macOS 10.15+ or Linux (Ubuntu 20.04+)
- 4GB RAM, 2GB disk space
- Bash, Zsh, or Fish shell

**Recommended:**
- macOS 12+ or Linux (Ubuntu 22.04+)
- 8GB RAM, 10GB disk space
- Docker Desktop/Engine
- Python 3.8+
- Fish shell 3.0+

**Supported:**
- ✅ macOS (Intel x86_64)
- ✅ macOS (Apple Silicon arm64)
- ✅ Linux (x86_64)
- ✅ Linux (arm64)
- ✅ WSL2 (Ubuntu, Debian)

---

**Created:** 2025-10-24
**Version:** 1.0
**Platforms:** macOS, Linux, WSL2
**Shells:** Fish, Bash, Zsh

**🚀 Start here:** `claude-health` or read [INDEX.md](INDEX.md)

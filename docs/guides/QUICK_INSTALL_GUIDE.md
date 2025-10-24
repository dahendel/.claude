# Claude Environment - Quick Install Guide

**🚀 One-command setup for any machine**

---

## Installation Methods

### Method 1: From Your Current Machine (Copy Files)

```bash
# On your current machine, create a tarball
cd ~
tar -czf claude-env.tar.gz .claude/

# Transfer to new machine (via scp, USB, cloud, etc.)
scp claude-env.tar.gz user@newmachine:~

# On the new machine
cd ~
tar -xzf claude-env.tar.gz
bash .claude/setup-claude-env.sh
```

### Method 2: From Git Repository (Recommended)

```bash
# If you have a dotfiles repo with .claude/ directory
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
bash .claude/setup-claude-env.sh
```

### Method 3: Direct Script Execution

```bash
# If hosted on GitHub or web server
curl -fsSL https://example.com/setup-claude-env.sh | bash

# Or download first and inspect
curl -fsSL https://example.com/setup-claude-env.sh -o setup.sh
bash setup.sh
```

---

## What to Copy to New Machines

### Essential Files (Required)
```
.claude/
├── setup-claude-env.sh       # Main setup script
├── aliases.fish              # Fish shell commands
├── aliases.sh                # Bash/Zsh commands
├── claude-services.sh        # Docker management
├── docker-compose.yml        # Docker config
├── init-vectordb.py          # DB initialization
├── manage-context.sh         # Backup/restore
└── monitor.py                # Health checks
```

### Documentation (Optional but Recommended)
```
.claude/
├── CLAUDE.md                 # Your preferences
├── SETUP_README.md           # This guide
├── DOCKER_SETUP.md          # Docker guide
├── FISH_SETUP.md            # Fish guide
├── OPENTOFU_ALIASES.md      # Tofu reference
└── QUICK_INSTALL_GUIDE.md   # Quick start
```

### Data (Backup Before Moving)
```
.claude/
├── chroma-data/             # Vector database
└── backups/                 # Your backups
```

---

## Platform-Specific Notes

### macOS (Intel or Apple Silicon)

**Prerequisites:**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop from:
# https://www.docker.com/products/docker-desktop
```

**After Installation:**
- Docker Desktop must be running
- Python 3 is usually pre-installed
- Fish shell: `brew install fish`

### Linux (Ubuntu/Debian)

**Prerequisites:**
```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# Install Python and pip
sudo apt-get update
sudo apt-get install -y python3 python3-pip

# Install Fish (optional)
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install fish
```

### WSL2 (Windows Subsystem for Linux)

**Prerequisites:**
- Docker Desktop for Windows with WSL2 backend
- Ubuntu or Debian WSL2 distribution

**Setup:**
```bash
# In WSL2 terminal
cd ~
# Copy or download setup script
bash .claude/setup-claude-env.sh
```

**Note:** Docker Desktop on Windows automatically integrates with WSL2

---

## Step-by-Step First Time Setup

### 1. Prepare the Files

**Option A: From Current Machine**
```bash
# Create distribution package
cd ~/.claude
tar -czf ~/claude-env-dist.tar.gz \
    setup-claude-env.sh \
    aliases.fish \
    aliases.sh \
    claude-services.sh \
    docker-compose.yml \
    init-vectordb.py \
    manage-context.sh \
    monitor.py \
    CLAUDE.md \
    *.md
```

**Option B: From Git Repository**
```bash
# Add to your dotfiles repo
cp -r ~/.claude ~/dotfiles/
cd ~/dotfiles
git add .claude/
git commit -m "Add Claude environment setup"
git push
```

### 2. Transfer to New Machine

```bash
# Via SCP
scp claude-env-dist.tar.gz user@newmachine:~

# Via cloud storage
# Upload to Dropbox/Google Drive/etc. and download on new machine

# Via Git
git clone https://github.com/YOUR_USERNAME/dotfiles.git
```

### 3. Run Setup

```bash
# Extract (if using tarball)
cd ~
tar -xzf claude-env-dist.tar.gz

# Run setup script
bash .claude/setup-claude-env.sh
```

### 4. Follow Prompts

The script will ask:
- Backup existing CLAUDE.md? (if it exists)
- Install Docker? (if not found)
- Install Python packages?
- Configure shell integration?
- Create initial backup?

Answer `y` to each unless you have specific reasons not to.

### 5. Reload Shell

```bash
# Fish
exec fish

# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc
```

### 6. Verify Installation

```bash
# Check health
claude-health

# Should show:
# ✓ Global CLAUDE.md: X lines
# ✓ Vector database: X KB
# ✓ Backups: X found
# ✓ Docker: Running
```

---

## Quick Commands Reference

After installation, you'll have access to:

```bash
# Health and Status
claude-health          # Quick check
claude-status          # Detailed info

# Docker Services
claude-start           # Start vector DB
claude-stop            # Stop services
claude-test            # Test connection

# Context Management
claude-backup          # Create backup
claude-restore         # Restore backup
claude-clean           # Cleanup old backups

# Configuration
claude-edit-global     # Edit preferences
claude-view-global     # View preferences

# OpenTofu (if tofu installed)
tf, tfa, tfaa, tfp, tfd, tfv, ...
```

---

## Common Issues and Solutions

### "Docker not found"
```bash
# macOS: Install Docker Desktop
# https://www.docker.com/products/docker-desktop

# Linux:
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

### "Python not found"
```bash
# macOS:
brew install python3

# Linux:
sudo apt-get install python3 python3-pip
```

### "Permission denied" on scripts
```bash
chmod +x ~/.claude/*.sh
chmod +x ~/.claude/*.py
```

### "Fish shell not found"
```bash
# macOS:
brew install fish

# Linux:
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install fish
```

### Shell config not loading
```bash
# Check if config file exists
cat ~/.config/fish/config.fish  # Fish
cat ~/.bashrc                   # Bash
cat ~/.zshrc                    # Zsh

# Manually add if missing
source ~/.claude/aliases.fish   # Fish
source ~/.claude/aliases.sh     # Bash/Zsh
```

---

## Updating Existing Installation

```bash
# On new machine with existing installation
cd ~/.claude
bash setup-claude-env.sh

# Will prompt to:
# - Backup existing files
# - Update configuration
# - Preserve customizations
```

---

## Distribution Checklist

Before sharing with others or moving to new machine:

- [ ] Test setup script on fresh system
- [ ] Update CLAUDE.md with your preferences
- [ ] Remove sensitive data from backups/
- [ ] Update Git repository URLs in docs
- [ ] Test on both macOS and Linux
- [ ] Document any custom configurations
- [ ] Create README in your dotfiles repo

---

## Next Steps After Installation

1. **Configure preferences:**
   ```bash
   claude-edit-global
   ```

2. **Initialize vector database:**
   ```bash
   claude-init-db
   ```

3. **Create first backup:**
   ```bash
   claude-backup "First backup after setup"
   ```

4. **Test Docker services:**
   ```bash
   claude-start
   claude-test
   ```

5. **Read documentation:**
   ```bash
   cat ~/.claude/DOCKER_SETUP.md
   cat ~/.claude/FISH_SETUP.md
   cat ~/.claude/OPENTOFU_ALIASES.md
   ```

---

## Support and Documentation

**Main Documentation:**
- `SETUP_README.md` - Complete setup guide
- `DOCKER_SETUP.md` - Docker configuration
- `FISH_SETUP.md` - Fish shell guide
- `OPENTOFU_ALIASES.md` - Tofu shortcuts

**Quick Reference:**
- `QUICK_INSTALL_GUIDE.md` - This file
- `QUICK_COMMANDS.md` - Command reference

**Configuration:**
- `~/.claude/CLAUDE.md` - Global preferences
- `./CLAUDE.md` - Project preferences

---

**Created:** 2025-10-24
**Platforms:** macOS (Intel/ARM), Linux (x86_64/ARM), WSL2
**Shell Support:** Fish, Bash, Zsh

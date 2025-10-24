# Transfer Your Claude Environment to Another Machine

**Quick reference for moving your setup to macOS or Linux**

---

## 🚀 Quick Start (3 Steps)

### On Your Current Machine:

```bash
# Step 1: Create package
claude-package

# Creates: ~/claude-env-YYYYMMDD.tar.gz
```

### Transfer the File:

```bash
# Step 2: Copy to new machine
scp ~/claude-env-*.tar.gz user@newmachine:~/

# Or use: Dropbox, Google Drive, USB drive, etc.
```

### On Your New Machine:

```bash
# Step 3: Extract and setup
cd ~
tar -xzf claude-env-*.tar.gz
bash .claude/setup-claude-env.sh
```

**Done!** Follow the prompts and reload your shell.

---

## Commands You'll Have

After setup, use these commands on your new machine:

### Package and Setup
```bash
claude-package         # Create transfer package
claude-setup           # Re-run setup (updates)
```

### Daily Use
```bash
claude-health          # Check environment status
claude-status          # Detailed monitoring
claude-start           # Start Docker services
claude-stop            # Stop Docker services
claude-backup          # Create backup
```

### OpenTofu
```bash
tf, tfa, tfaa, tfp, tfd, tfv, tff, ...
# 34+ shortcuts available!
```

---

## What Gets Transferred

### ✅ Always Included:
- Setup scripts
- Shell aliases (Fish, Bash, Zsh)
- Docker configuration
- Documentation
- Your CLAUDE.md preferences

### ❓ Optional (You Choose):
- Vector database data (`chroma-data/`)
- Backup archives (`backups/`)

**Note:** The package script will ask if you want to include data.

---

## Platform Compatibility

| From → To | Compatibility | Notes |
|-----------|---------------|-------|
| macOS → macOS | ✅ Perfect | Works on Intel and Apple Silicon |
| Linux → Linux | ✅ Perfect | x86_64 and ARM64 supported |
| macOS → Linux | ✅ Good | Shell configs adjust automatically |
| Linux → macOS | ✅ Good | Shell configs adjust automatically |
| WSL2 → WSL2 | ✅ Perfect | Includes Docker Desktop integration |
| Any → WSL2 | ✅ Good | Requires Docker Desktop for Windows |

---

## Detailed Transfer Methods

### Method 1: SCP (Secure Copy)

```bash
# Current machine
claude-package
scp ~/claude-env-*.tar.gz user@192.168.1.100:~/

# New machine
cd ~
tar -xzf claude-env-*.tar.gz
bash .claude/setup-claude-env.sh
```

### Method 2: Cloud Storage

```bash
# Current machine
claude-package
# Upload ~/claude-env-*.tar.gz to Dropbox/Drive/OneDrive

# New machine
# Download the file to ~/
cd ~
tar -xzf claude-env-*.tar.gz
bash .claude/setup-claude-env.sh
```

### Method 3: Git Repository

```bash
# Current machine (one-time setup)
cd ~
git init dotfiles
cd dotfiles
cp -r ~/.claude .
git add .claude/
git commit -m "Add Claude environment"
git remote add origin https://github.com/USER/dotfiles.git
git push -u origin main

# New machine (anytime)
git clone https://github.com/USER/dotfiles.git
cd dotfiles
bash .claude/setup-claude-env.sh
```

### Method 4: USB Drive

```bash
# Current machine
claude-package
cp ~/claude-env-*.tar.gz /Volumes/USB/  # macOS
cp ~/claude-env-*.tar.gz /media/usb/    # Linux

# New machine
cp /Volumes/USB/claude-env-*.tar.gz ~/  # macOS
cp /media/usb/claude-env-*.tar.gz ~/    # Linux
cd ~
tar -xzf claude-env-*.tar.gz
bash .claude/setup-claude-env.sh
```

---

## What the Setup Script Does

1. ✅ **Detects your system**: OS and architecture
2. ✅ **Creates directories**: `~/.claude/chroma-data`, `~/.claude/backups`
3. ✅ **Checks dependencies**: Docker, Python, shell
4. ✅ **Preserves existing files**: Backs up before overwriting
5. ✅ **Configures shell**: Adds aliases and auto-start
6. ✅ **Tests everything**: Verifies Docker and services
7. ✅ **Creates backup**: Initial backup of environment

---

## After Setup on New Machine

### 1. Reload Shell

```bash
# Fish
exec fish

# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc
```

### 2. Verify Installation

```bash
claude-health
```

Should show:
```
✓ Global CLAUDE.md: X lines
✓ Vector database: X KB
✓ Backups: X found
✓ Docker: Running
```

### 3. Start Services

```bash
claude-start
claude-test
```

### 4. Initialize Database

```bash
claude-init-db
```

---

## Customization for New Machine

### Update Machine-Specific Settings

```bash
# Edit global preferences
claude-edit-global

# Add machine-specific notes:
# - Different paths
# - Local tools
# - Machine name/purpose
```

### Add Machine to CLAUDE.md

```markdown
## Machines

### MacBook Pro (M3)
- Primary development
- Location: Office
- Docker: Yes
- Projects: ~/Developer

### Linux Workstation (x86_64)
- Heavy compute tasks
- Location: Home office
- Docker: Yes
- Projects: ~/projects
```

---

## Troubleshooting

### Setup Script Fails

```bash
# Check prerequisites
which docker
which python3
which fish  # or bash/zsh

# Install missing dependencies
# See QUICK_INSTALL_GUIDE.md
```

### Shell Config Not Loading

```bash
# Manually add to shell config
# Fish:
echo 'source ~/.claude/aliases.fish' >> ~/.config/fish/config.fish

# Bash:
echo 'source ~/.claude/aliases.sh' >> ~/.bashrc

# Zsh:
echo 'source ~/.claude/aliases.sh' >> ~/.zshrc
```

### Docker Services Won't Start

```bash
# Check Docker is running
docker info

# Start Docker Desktop (macOS)
open /Applications/Docker.app

# Start Docker daemon (Linux)
sudo systemctl start docker
```

### Permission Issues

```bash
# Make scripts executable
chmod +x ~/.claude/*.sh
chmod +x ~/.claude/*.py
```

---

## Keeping Multiple Machines in Sync

### Strategy 1: Git Repository (Recommended)

```bash
# Push changes from any machine
cd ~/dotfiles
cp -r ~/.claude .
git add .claude/
git commit -m "Update Claude config"
git push

# Pull on other machines
cd ~/dotfiles
git pull
bash .claude/setup-claude-env.sh
```

### Strategy 2: Cloud Sync

```bash
# Use Dropbox/Drive/OneDrive
ln -s ~/Dropbox/claude-env ~/.claude

# Or sync regularly
rsync -av ~/.claude/ ~/Dropbox/claude-env/
```

### Strategy 3: Manual Sync

```bash
# Periodically re-package and transfer
claude-package
# Transfer and re-run setup
```

---

## Advanced: Automated Sync

### Using Git Hooks

```bash
# In ~/dotfiles/.git/hooks/post-commit
#!/bin/bash
cp -r ~/.claude ~/dotfiles/
git add .claude/
git commit --amend --no-edit
```

### Using Cron

```bash
# Add to crontab (backup every day at 2 AM)
0 2 * * * ~/.claude/manage-context.sh backup "auto-backup" >/dev/null 2>&1
```

---

## Security Considerations

### Before Transferring:

- [ ] Review `CLAUDE.md` for sensitive paths
- [ ] Check backups for sensitive data
- [ ] Remove API keys or tokens
- [ ] Clean up temporary files

### Clean Before Transfer:

```bash
# Remove sensitive data
rm -rf ~/.claude/backups/*
rm -rf ~/.claude/chroma-data/*

# Package clean version
claude-package
```

### After Transfer:

- [ ] Update paths in `CLAUDE.md`
- [ ] Generate new backups
- [ ] Configure machine-specific settings

---

## Quick Reference Card

### Essential Commands

```bash
# Transfer
claude-package              # Create transfer package
scp package.tar.gz user@machine:~/

# Setup (on new machine)
tar -xzf package.tar.gz
bash .claude/setup-claude-env.sh
exec fish                   # or: source ~/.bashrc

# Verify
claude-health
claude-start
claude-test

# Daily use
claude-status
claude-backup
```

---

## Support Files

- **SETUP_README.md** - Complete setup guide
- **QUICK_INSTALL_GUIDE.md** - Installation walkthrough
- **DOCKER_SETUP.md** - Docker configuration
- **FISH_SETUP.md** - Fish shell guide
- **OPENTOFU_ALIASES.md** - OpenTofu shortcuts

---

**Created:** 2025-10-24
**Platforms:** macOS (Intel/ARM), Linux (x86_64/ARM), WSL2
**Shells:** Fish, Bash, Zsh

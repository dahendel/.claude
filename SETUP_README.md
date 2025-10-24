# Claude Environment Setup

**One-command setup for macOS and Linux (x86_64/arm64)**

---

## Quick Start

### Option 1: From Git Repository (Recommended)

```bash
# Clone your dotfiles repo (or wherever you store this)
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO/.claude

# Run setup
bash setup-claude-env.sh
```

### Option 2: Copy Files Manually

1. Copy the entire `~/.claude/` directory to your new machine
2. Run the setup script:

```bash
cd ~/.claude
bash setup-claude-env.sh
```

### Option 3: Direct Download (if hosted online)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/.claude/setup-claude-env.sh | bash
```

---

## What It Does

✅ **Detects your system**: macOS or Linux, x86_64 or arm64
✅ **Creates directory structure**: `~/.claude/chroma-data`, `~/.claude/backups`
✅ **Preserves existing files**: Backs up before overwriting
✅ **Installs dependencies**: Checks for Docker, Python, and required packages
✅ **Configures your shell**: Bash, Zsh, or Fish (auto-detected)
✅ **Sets up Docker services**: Chroma vector database with auto-start
✅ **Adds OpenTofu aliases**: 34+ shortcuts for Terraform/OpenTofu
✅ **Creates initial backup**: First backup of your environment
✅ **Tests everything**: Verifies Docker services are working

---

## Supported Systems

| OS | Architecture | Status |
|----|--------------|--------|
| macOS | arm64 (M1/M2/M3) | ✅ Supported |
| macOS | x86_64 (Intel) | ✅ Supported |
| Linux | x86_64 | ✅ Supported |
| Linux | arm64 | ✅ Supported |
| Windows | WSL2 | ✅ Supported (via Linux) |

---

## Prerequisites

**Optional but recommended:**
- Docker Desktop (macOS) or Docker Engine (Linux)
- Python 3.7+ (for monitoring and vector DB init)
- Fish shell (if you prefer Fish over Bash/Zsh)

The script will detect and prompt you to install missing dependencies.

---

## What Gets Configured

### 1. Directory Structure
```
~/.claude/
├── aliases.fish              # Fish shell aliases
├── aliases.sh                # Bash/Zsh aliases
├── claude-services.sh        # Docker service management
├── docker-compose.yml        # Docker configuration
├── init-vectordb.py          # Vector DB initialization
├── manage-context.sh         # Backup/restore/cleanup
├── monitor.py                # Health monitoring
├── CLAUDE.md                 # Global preferences
├── DOCKER_SETUP.md          # Docker documentation
├── FISH_SETUP.md            # Fish shell guide
├── OPENTOFU_ALIASES.md      # OpenTofu reference
├── chroma-data/             # Vector database
└── backups/                 # Automatic backups
```

### 2. Shell Integration

**Fish Shell:**
- Auto-start Docker vector database
- Load Claude aliases and functions
- OpenTofu shortcuts

**Bash/Zsh:**
- Load Claude aliases from `~/.claude/aliases.sh`

### 3. Available Commands

**Context Management:**
```bash
claude-health          # Quick health check
claude-status          # Detailed monitoring
claude-backup          # Create backup
claude-restore         # Restore from backup
claude-usage           # Show usage stats
claude-clean           # Cleanup old backups
```

**Docker Services:**
```bash
claude-start           # Start vector database
claude-stop            # Stop services
claude-restart         # Restart services
claude-logs            # View logs
claude-test            # Test connectivity
claude-init-db         # Initialize collections
```

**Configuration:**
```bash
claude-edit-global     # Edit ~/.claude/CLAUDE.md
claude-edit-project    # Edit ./CLAUDE.md
claude-view-global     # View global config
claude-view-project    # View project config
```

**OpenTofu Shortcuts:**
```bash
tf, tfi, tfp, tfa, tfd, tfv, tff, tfs, tfo
tfaa        # apply -auto-approve
tfda        # destroy -auto-approve
tfsl        # state list
tfwl        # workspace list
# ... 34+ more!
```

---

## After Installation

1. **Reload your shell:**
   ```bash
   # Fish
   source ~/.config/fish/config.fish

   # Bash
   source ~/.bashrc

   # Zsh
   source ~/.zshrc
   ```

2. **Check environment:**
   ```bash
   claude-health
   ```

3. **Initialize vector database:**
   ```bash
   claude-init-db
   ```

4. **Test Docker services:**
   ```bash
   claude-test
   ```

---

## Customization

### Global Preferences
Edit `~/.claude/CLAUDE.md` for global preferences across all projects.

### Project-Specific Settings
Create `./CLAUDE.md` in any project directory for project-specific context.

### Disable Auto-Start
Comment out the auto-start section in your shell config:
- Fish: `~/.config/fish/config.fish`
- Bash: `~/.bashrc`
- Zsh: `~/.zshrc`

---

## Troubleshooting

### Docker not starting
```bash
# macOS: Start Docker Desktop
# Linux: Start Docker daemon
sudo systemctl start docker

# Test
docker info
```

### Python packages missing
```bash
python3 -m pip install --user chromadb requests
```

### Shell config not working
```bash
# Check if files exist
ls -la ~/.claude/

# Manually source
source ~/.claude/aliases.sh  # Bash/Zsh
source ~/.claude/aliases.fish  # Fish

# Check for errors
bash -x ~/.claude/aliases.sh
```

### Vector database not accessible
```bash
# Check Docker status
claude-services status

# View logs
claude-logs

# Restart services
claude-restart
```

---

## Updating

To update on an existing machine:

```bash
cd ~/.claude
bash setup-claude-env.sh
```

The script will:
- Backup existing files
- Prompt before overwriting
- Preserve your customizations

---

## Uninstalling

```bash
# Stop Docker services
claude-stop

# Remove directory
rm -rf ~/.claude/

# Remove shell configuration
# Edit your shell config file and remove Claude sections:
# - Fish: ~/.config/fish/config.fish
# - Bash: ~/.bashrc
# - Zsh: ~/.zshrc
```

---

## Distribution

### For Your Dotfiles Repo

1. Copy `~/.claude/` to your dotfiles repository
2. Add to your README:
   ```bash
   bash .claude/setup-claude-env.sh
   ```

### For Direct Download

1. Host on GitHub
2. Share this command:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/.claude/setup-claude-env.sh | bash
   ```

---

## Support

**Files included:**
- `SETUP_README.md` - This file
- `DOCKER_SETUP.md` - Docker configuration guide
- `FISH_SETUP.md` - Fish shell guide
- `OPENTOFU_ALIASES.md` - OpenTofu reference
- `QUICK_COMMANDS.md` - Quick command reference

**Created:** 2025-10-24
**Version:** 1.0
**Platforms:** macOS (arm64/x86_64), Linux (x86_64/arm64)

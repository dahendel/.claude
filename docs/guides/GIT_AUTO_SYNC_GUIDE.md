# Git Auto-sync Guide

**Automatic GitHub Synchronization Every 4 Hours**

Keep your Claude environment synchronized across multiple machines (WSL, macOS, Linux) with automated git commits and pushes.

---

## Overview

Git auto-sync automatically:
- ✅ Commits local changes every 4 hours
- ✅ Pulls remote changes from GitHub
- ✅ Handles merge conflicts with rebase
- ✅ Logs all operations for troubleshooting
- ✅ Works across WSL, macOS, and Linux

**No manual git commands needed** - just work and your changes sync automatically!

---

## Quick Start

### Install Auto-sync

```bash
claude-env git-sync install
```

That's it! Auto-sync is now configured to run every 4 hours.

### Test Sync Manually

```bash
claude-env sync
# or
claude-env git-sync test
```

### Check Status

```bash
claude-env git-sync status
```

---

## How It Works

### Sync Schedule

**Linux/WSL:** Cron job runs every 4 hours
**macOS:** LaunchAgent runs every 4 hours

**Schedule:** 00:00, 04:00, 08:00, 12:00, 16:00, 20:00 (midnight, 4am, 8am, noon, 4pm, 8pm)

### Sync Process

1. **Fetch** latest changes from GitHub
2. **Check** for local uncommitted changes
3. **Commit** local changes if any exist
4. **Pull** remote changes with rebase
5. **Push** local changes to GitHub
6. **Log** all operations

### Commit Messages

Auto-generated commits include:
```
auto-sync: hostname at 2025-10-24 14:30:00

Automated sync from hostname

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Platform-Specific Details

### Linux/WSL (Cron)

**Cron job location:** User crontab
**Log file:** `~/.claude/data/git-sync-cron.log`

**View cron jobs:**
```bash
crontab -l
```

**Edit schedule:**
```bash
crontab -e
# Change: 0 */4 * * *  (every 4 hours)
# To:     0 * * * *    (every hour)
```

**Manual sync:**
```bash
~/.claude/bin/git-auto-sync.sh
```

### macOS (LaunchAgent)

**Service location:** `~/Library/LaunchAgents/com.claude.git-sync.plist`
**Log file:** `~/.claude/data/git-sync-launchd.log`

**Check status:**
```bash
launchctl list | grep claude-git
```

**Manual sync:**
```bash
launchctl start com.claude.git-sync
# or
~/.claude/bin/git-auto-sync.sh
```

**Edit schedule:**
```bash
# Edit ~/Library/LaunchAgents/com.claude.git-sync.plist
# Change <integer>14400</integer>  (4 hours)
# To     <integer>3600</integer>   (1 hour)
launchctl unload ~/Library/LaunchAgents/com.claude.git-sync.plist
launchctl load ~/Library/LaunchAgents/com.claude.git-sync.plist
```

---

## Commands

### Setup Commands

```bash
# Install auto-sync
claude-env git-sync install

# Remove auto-sync
claude-env git-sync remove

# Test sync manually
claude-env git-sync test

# Check status and logs
claude-env git-sync status

# Run sync now (manual)
claude-env sync
```

### Monitoring Commands

```bash
# View recent sync logs
tail -f ~/.claude/data/git-sync.log

# View all logs
less ~/.claude/data/git-sync.log

# Check cron logs (Linux)
tail -f ~/.claude/data/git-sync-cron.log

# Check launchd logs (macOS)
tail -f ~/.claude/data/git-sync-launchd.log
```

---

## Troubleshooting

### Sync Fails: "Not a git repository"

**Problem:** ~/.claude is not a git repository

**Solution:**
```bash
cd ~/.claude
git init
git remote add origin git@github.com:USERNAME/.claude.git
git add .
git commit -m "Initial commit"
git push -u origin main
claude-env git-sync install
```

### Sync Fails: "No git remote configured"

**Problem:** No GitHub remote configured

**Solution:**
```bash
cd ~/.claude
git remote add origin git@github.com:USERNAME/.claude.git
claude-env git-sync test
```

### Sync Fails: "Permission denied (publickey)"

**Problem:** SSH key not configured for GitHub

**Solution:**
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH Keys → New SSH key
```

### Sync Fails: "Branches have diverged"

**Problem:** Local and remote have conflicting commits

**Solution:**
```bash
cd ~/.claude

# See what's different
git log --oneline --all --graph

# Option 1: Keep remote changes
git fetch origin main
git reset --hard origin/main

# Option 2: Keep local changes
git push --force origin main

# Option 3: Merge manually
git pull --rebase origin main
# Fix conflicts if any
git add .
git rebase --continue
git push origin main
```

### Cron Job Not Running (Linux)

**Check cron service:**
```bash
# Is cron running?
systemctl status cron

# Start cron if stopped
sudo systemctl start cron

# View cron logs
grep CRON /var/log/syslog | tail -20
```

**Test cron job:**
```bash
# Run sync manually
~/.claude/bin/git-auto-sync.sh

# Check for errors
tail -20 ~/.claude/data/git-sync.log
```

### LaunchAgent Not Running (macOS)

**Check launchd:**
```bash
# Is agent loaded?
launchctl list | grep claude-git

# Reload agent
launchctl unload ~/Library/LaunchAgents/com.claude.git-sync.plist
launchctl load ~/Library/LaunchAgents/com.claude.git-sync.plist

# Check errors
tail -20 ~/.claude/data/git-sync-launchd.err
```

---

## Advanced Configuration

### Change Sync Frequency

**Linux (cron):**
```bash
crontab -e

# Current: Every 4 hours
0 */4 * * * ~/.claude/bin/git-auto-sync.sh

# Every hour
0 * * * * ~/.claude/bin/git-auto-sync.sh

# Every 2 hours
0 */2 * * * ~/.claude/bin/git-auto-sync.sh

# Daily at 2am
0 2 * * * ~/.claude/bin/git-auto-sync.sh
```

**macOS (launchd):**
```xml
<!-- Edit ~/Library/LaunchAgents/com.claude.git-sync.plist -->

<!-- Current: Every 4 hours (14400 seconds) -->
<key>StartInterval</key>
<integer>14400</integer>

<!-- Every hour (3600 seconds) -->
<key>StartInterval</key>
<integer>3600</integer>

<!-- Every 2 hours (7200 seconds) -->
<key>StartInterval</key>
<integer>7200</integer>

<!-- Then reload -->
<!-- launchctl unload ~/Library/LaunchAgents/com.claude.git-sync.plist -->
<!-- launchctl load ~/Library/LaunchAgents/com.claude.git-sync.plist -->
```

### Sync Only on Weekdays

**Linux (cron):**
```bash
# Monday-Friday at 9am and 5pm
0 9,17 * * 1-5 ~/.claude/bin/git-auto-sync.sh
```

### Custom Commit Messages

Edit `~/.claude/bin/git-auto-sync.sh` line ~45:
```bash
git commit -m "auto-sync: ${HOSTNAME} at ${TIMESTAMP}

Your custom message here
"
```

### Exclude Specific Files

Add to `~/.claude/.gitignore`:
```gitignore
# Don't sync experimental configs
CLAUDE.local.md
experiments/

# Don't sync machine-specific data
.machine-id
```

---

## Best Practices

### ✅ DO

- **Keep commits small** - sync often with incremental changes
- **Review logs regularly** - catch issues early
- **Test after setup** - verify sync works before relying on it
- **Use descriptive file names** - makes git history clearer
- **Keep .gitignore updated** - protect sensitive data

### ❌ DON'T

- **Don't sync sensitive data** - API keys, tokens, passwords
- **Don't force push often** - can lose work from other machines
- **Don't ignore sync failures** - fix issues promptly
- **Don't edit git history** - keep clean linear history
- **Don't disable without reason** - defeats the purpose!

---

## Multi-Machine Workflow

### Setup on First Machine (WSL)

```bash
cd ~/.claude
git init
git remote add origin git@github.com:USERNAME/.claude.git
git add .
git commit -m "Initial setup from WSL"
git push -u origin main
claude-env git-sync install
```

### Setup on Second Machine (macOS)

```bash
git clone git@github.com:USERNAME/.claude.git ~/.claude
cd ~/.claude
bash bin/setup-claude-env.sh
claude-env git-sync install
```

### Daily Use

**On any machine:**
1. Make changes to configs/scripts
2. Changes auto-sync every 4 hours
3. Other machines pull changes automatically
4. No manual git commands needed!

**Check sync status anytime:**
```bash
claude-env git-sync status
```

---

## Uninstall

### Remove Auto-sync (Keep Repository)

```bash
# Remove cron/launchd service only
claude-env git-sync remove

# Git repository remains intact
# Can still manually: git pull, git push
```

### Complete Removal

```bash
# Remove auto-sync
claude-env git-sync remove

# Remove git entirely
cd ~/.claude
rm -rf .git

# Note: This removes ALL git history!
# Make sure you have backups first
```

---

## FAQ

**Q: What if I forget to push manually?**
A: Auto-sync handles it! Your changes will be pushed within 4 hours.

**Q: Will this conflict with manual git commits?**
A: No, auto-sync detects manual commits and just pushes them.

**Q: Can I still use git manually?**
A: Yes! Auto-sync works alongside manual git operations.

**Q: What happens if I'm offline?**
A: Sync fails gracefully, retries next scheduled time when online.

**Q: Does this work with GitHub private repos?**
A: Yes! Just ensure SSH keys are configured properly.

**Q: Can I sync to multiple remotes?**
A: Not directly, but you can modify the script to push to multiple remotes.

**Q: Will this eat up my GitHub storage?**
A: No, configs/scripts are tiny. Vector DB and data/ are excluded.

**Q: What about merge conflicts?**
A: Auto-sync uses rebase to handle conflicts. Manual intervention needed if rebase fails.

---

**Created:** 2025-10-24
**Platforms:** Linux (cron), macOS (launchd), WSL
**Schedule:** Every 4 hours by default
**Log files:** `~/.claude/data/git-sync.log`

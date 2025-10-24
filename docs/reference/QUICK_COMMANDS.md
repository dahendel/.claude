# Claude Code Quick Commands Reference

**Keep this file open for quick reference!**

---

## 🚀 Daily Commands

### Health & Monitoring
```bash
claude-status          # Full health dashboard with recommendations
claude-health          # Quick health check (fast)
claude-usage           # Usage statistics and metrics
```

### Backup & Restore
```bash
claude-backup          # Create backup now
claude-restore         # Restore from backup (interactive)
claude-clean           # Clean old backups and optimize DB
```

### Editing Configuration
```bash
claude-edit-global     # Edit ~/.claude/CLAUDE.md
claude-edit-project    # Edit ./CLAUDE.md
claude-view-global     # View global config
claude-view-project    # View project config
```

---

## 📊 Context Management (In Claude)

### Check Status
```
/context                    # Check current usage
/context --breakdown        # Detailed breakdown
/mcp                        # Check MCP servers
```

### Manage Context
```
/compact                    # Manual compact (at 70%)
/compact keep {info}        # Compact but keep important info
/clear                      # Clear conversation
/quit                       # Exit and start fresh
```

### Memory Operations
```
"Store in memory: {important information}"
"What do you remember about {topic}?"
"Check memory for recent context about {project}"
```

---

## 🎯 Context Budget Guide

| Usage | Zone | Action |
|-------|------|--------|
| 0-70% | 🟢 GREEN | Normal operation |
| 70-85% | 🟠 ORANGE | Plan compaction, store in DB |
| 85-95% | 🔴 RED | Stop work, save context, restart |
| 95%+ | ⚠️ DANGER | Should never reach! |

---

## 🔧 Project Management

### Initialize New Project
```bash
claude-init-project my-app          # Create in current dir
claude-init-project my-app ~/code   # Create in specific dir
```

### Database Operations
```bash
claude-db-size         # Check vector DB size
claude-db-check        # Verify database integrity
```

### View Logs
```bash
claude-logs            # Follow MCP logs
claude-logs-all        # Follow all Claude logs
```

---

## 📝 Session Workflow

### Start Session
```bash
cd ~/projects/my-project
claude
```

In Claude:
```
"Check memory for recent context and summarize what we were working on"
```

### During Session (Every Hour)
```
/context                               # Check usage
```

At 70% usage:
```
/compact keep {important decisions}    # Or...
"Store in memory: {key information}"   # Then /clear
```

### End Session
```
"Summarize this session and store key decisions"
```

Then:
```bash
claude-edit-project    # Update CLAUDE.md if needed
claude-backup          # Weekly backup
/quit                  # Exit cleanly
```

---

## 🎨 Project CLAUDE.md Template

```markdown
# Project: [Name]

## Tech Stack
- Language: [e.g., Python 3.11+]
- Framework: [e.g., FastAPI]

## Common Commands
```bash
# Dev
npm run dev

# Test
npm test

# Build
npm run build
```

## Code Style
- [Convention 1]
- [Convention 2]

## Current Focus
[What you're working on]

## Important Decisions
1. [Decision + rationale]
```

---

## 🔍 Troubleshooting Quick Fixes

### Aliases Not Working
```bash
source ~/.claude/aliases.sh
# Or add to ~/.bashrc:
echo 'source ~/.claude/aliases.sh' >> ~/.bashrc
```

### Vector DB Not Persisting
```bash
ls ~/.claude/chroma-data       # Check exists
claude-db-check                # Verify integrity
```

### CLAUDE.md Not Loading
```bash
ls -l ~/.claude/CLAUDE.md      # Verify exists
chmod 644 ~/.claude/CLAUDE.md  # Fix permissions
```

### Context Still Filling
- Move content to CLAUDE.md
- Store more in vector DB
- Use /clear between tasks
- Start fresh for new features

---

## 💡 Pro Tips

1. **Never wait for 95% auto-compact** - Quality degrades
2. **Keep CLAUDE.md under 200 lines** - Move project-specific to ./CLAUDE.md
3. **Store decisions, not conversations** - Use vector DB wisely
4. **Backup weekly** - Run `claude-backup` every Sunday
5. **Start fresh for major features** - New session = better quality

---

## 📁 Important File Locations

```
~/.claude/
├── CLAUDE.md                  # Global config (auto-loaded)
├── chroma-data/               # Vector database
├── backups/                   # Your backups
├── manage-context.sh          # Management script
├── monitor.py                 # Health monitor
└── aliases.sh                 # Shell aliases

Project:
./CLAUDE.md                    # Project config (auto-loaded)
./CLAUDE.local.md             # Personal notes (gitignored)
```

---

## 🎯 Performance Targets

- ✅ Auto-compacts: 0/month
- ✅ Context usage: <70% average
- ✅ Cache hit rate: >70%
- ✅ Monthly cost: <$10 (100 sessions)
- ✅ Backup age: <7 days

---

## 🆘 Emergency Procedures

### Context Disaster (95%+)
```bash
# In Claude:
"Summarize critical info from this session"
# Copy output, then:
/quit

# Update files
claude-edit-global    # Add critical info
claude-backup         # Save state

# Restart fresh
claude
```

### Database Corruption
```bash
claude-db-check                    # Verify issue
claude-restore                     # Restore from backup
```

---

## 📚 Documentation

- **Local setup guide:** `~/.claude/SETUP_INSTRUCTIONS.md`
- **Full optimization guide:** `~/projects/local-claude/`
- **Global preferences:** `~/.claude/CLAUDE.md`

---

**Made a change? Test it:**
```bash
claude-health    # Quick check
claude-status    # Full report
```

**Questions? Check:**
- Setup guide: `cat ~/.claude/SETUP_INSTRUCTIONS.md`
- Full docs: `cd ~/projects/local-claude && ls`

---

**Last Updated:** 2025-10-23
**Quick help:** `claude-health` or `claude-status`

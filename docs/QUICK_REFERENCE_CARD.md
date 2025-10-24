# Claude Environment Quick Reference Card
**Keep this open while working with Claude**

---

## Daily Commands

### Context Monitoring
```bash
/context                    # Check current usage
/context --breakdown       # Detailed token breakdown
/mcp                       # Check MCP server status
```

### Context Management
```bash
/compact                           # Manual compact (use at 70%)
/compact keep {important info}     # Compact but preserve specific info
/clear                            # Clear conversation, keep CLAUDE.md
/quit                             # Exit and start fresh
```

### Memory Operations
```
"Store in memory: {important info}"           # Save to vector DB
"What do you remember about {topic}?"         # Retrieve from memory
"Check memory for {specific information}"     # Search memory
```

---

## Context Budget Guide

```
┌─────────────────────────────────────────────────┐
│ Context Window: 200K tokens (100%)             │
├─────────────────────────────────────────────────┤
│ 0-50K (0-25%)    │ GREEN ZONE ✅               │
│ Normal operation, no action needed             │
├─────────────────────────────────────────────────┤
│ 50-140K (25-70%) │ YELLOW ZONE ⚠️              │
│ Monitor periodically, plan compaction          │
├─────────────────────────────────────────────────┤
│ 140-170K (70-85%)│ ORANGE ZONE 🟠              │
│ ACTION REQUIRED:                               │
│ - /compact keep important decisions            │
│ - Move info to CLAUDE.md                       │
│ - Store insights in vector DB                  │
├─────────────────────────────────────────────────┤
│ 170-190K (85-95%)│ RED ZONE 🔴                 │
│ STOP WORK:                                     │
│ - Save all important context                   │
│ - Update CLAUDE.md                             │
│ - /quit and restart fresh                      │
├─────────────────────────────────────────────────┤
│ 190K+ (95%+)     │ DANGER ZONE ⚠️⚠️⚠️           │
│ Auto-compact imminent - quality will degrade   │
│ Should not reach here with proper management   │
└─────────────────────────────────────────────────┘
```

---

## Session Workflow

### Session Start
```
1. cd ~/projects/your-project
2. claude
3. (Optional) Use session-start prompt:
   "Check memory for recent context and summarize
    what we were working on last session"
```

### During Session
```
Every hour or at logical milestones:
- Run /context to check usage
- At 70%: /compact keep {key info}
- Store important decisions in memory
- Update CLAUDE.md with new conventions
```

### Session End
```
1. "Please summarize this session and store key
    decisions in memory for next time"
2. Update CLAUDE.md if needed
3. Run backup: claude-manage backup
4. /quit
```

---

## CLAUDE.md Structure Template

```markdown
# Project: [Name]

## Tech Stack
- Language: [Python/TypeScript/etc]
- Framework: [FastAPI/React/etc]
- Database: [PostgreSQL/MongoDB/etc]
- Vector DB: [Chroma/Qdrant]

## Architecture
[Brief description or link to docs]

## Common Commands
```bash
# Development
[your dev commands]

# Testing
[your test commands]

# Deployment
[your deploy commands]
```

## Code Style
- [Convention 1]
- [Convention 2]
- [Convention 3]

## Current Focus
[What you're working on now]

## Important Decisions
1. [Decision with rationale]
2. [Decision with rationale]
```

---

## Troubleshooting Checklist

### MCP Server Not Working
```bash
☐ Check config JSON syntax
☐ Verify paths are absolute
☐ Restart Claude Desktop
☐ Check logs: tail -f ~/Library/Logs/Claude/mcp*.log
☐ Test server manually: uvx chroma-mcp --help
```

### Context Issues
```bash
☐ Run /context to check usage
☐ Verify CLAUDE.md exists and is readable
☐ Check if auto-compact triggered (bad)
☐ Start fresh session if quality degraded
☐ Store important info before restarting
```

### Memory Not Persisting
```bash
☐ Verify MCP server is running: /mcp
☐ Check vector DB exists: ls ~/.claude/chroma-data
☐ Test storage: "Store test: $(date)"
☐ Test retrieval in new conversation
☐ Check database size: du -sh ~/.claude/chroma-data
```

---

## Cost Optimization Checklist

### Before Each Session
```
☐ CLAUDE.md updated with latest preferences
☐ Old conversations archived to vector DB
☐ Prompt caching configured (auto in Desktop)
☐ Clear any unnecessary old context
```

### During Session
```
☐ Use /clear between unrelated tasks
☐ Store repeated context in CLAUDE.md
☐ Query vector DB instead of re-explaining
☐ Keep context under 70% most of the time
```

### Weekly Review
```
☐ Check cache hit rate (aim for >70%)
☐ Review monthly token usage
☐ Clean up old vector DB collections
☐ Optimize CLAUDE.md (keep under 200 lines)
☐ Update backup retention policy
```

---

## File Locations Reference

### Configuration
```
macOS:
~/Library/Application Support/Claude/claude_desktop_config.json

Linux:
~/.config/Claude/claude_desktop_config.json

Windows:
%APPDATA%\Claude\claude_desktop_config.json
```

### Data
```
Vector DB:     ~/.claude/chroma-data/
Backups:       ~/.claude/backups/
Global Config: ~/.claude/CLAUDE.md
Project Config: ./CLAUDE.md
Local Config:  ./CLAUDE.local.md (gitignored)
```

### Logs
```
macOS:   ~/Library/Logs/Claude/
Linux:   ~/.config/Claude/logs/
Windows: %APPDATA%\Claude\logs\
```

---

## Common Prompt Templates

### Store Important Info
```
"Store in memory: {description}

Context: {why this is important}
Date: {date}
Related to: {project/feature}"
```

### Retrieve Context
```
"What do you remember about {topic}?

Include:
- Technical decisions and rationale
- Implementation details
- Any relevant code patterns
- Timeline if available"
```

### Session Handoff
```
"End of session summary:

Accomplished:
- {item 1}
- {item 2}

Next session should:
- {next step 1}
- {next step 2}

Store this for continuity."
```

### Context Health Check
```
"Perform context health check:

1. Current context usage?
2. Any redundant information?
3. Should we compact or continue?
4. What should be moved to CLAUDE.md?
5. Recommendations for next steps?"
```

---

## MCP Server Status Check

### Quick Status
```
In Claude: /mcp

Should show:
✅ chroma (connected)
✅ filesystem (connected)
✅ openmemory (connected) [if installed]
```

### Test Each Server
```bash
# Chroma
"What collections exist in Chroma?"

# Filesystem
"List files in the current directory"

# OpenMemory
"What's stored in OpenMemory about this project?"
```

---

## Performance Targets

### Context Management
```
✅ Auto-compacts per month: 0
✅ Average peak context: <70%
✅ Manual compacts: 3-5/month at 70%
✅ Context-related errors: 0
```

### Cost Efficiency
```
✅ Cache hit rate: >70%
✅ Cost per session: <$0.10
✅ Monthly cost: <$10 (100 sessions)
✅ Token waste: <10%
```

### Memory & Retrieval
```
✅ Retrieval accuracy: >90%
✅ Query latency: <500ms
✅ Cross-session retention: 100%
✅ False positives: <5%
```

### System Health
```
✅ MCP uptime: >99%
✅ Backup success rate: 100%
✅ Database corruption: 0
✅ Restore tests: Pass monthly
```

---

## Emergency Procedures

### Context Disaster (95%+ Usage)
```
1. STOP current work immediately
2. Run: "Summarize critical info from this session"
3. Copy summary to external file
4. Update CLAUDE.md with key points
5. Store in vector DB: "Store session summary: {paste}"
6. /quit
7. Start fresh: claude
8. Resume with: "Load context about {topic} and continue"
```

### MCP Server Failure
```
1. Check status: /mcp
2. View logs: tail -f ~/Library/Logs/Claude/mcp*.log
3. Restart Claude Desktop
4. If still failing, test manually:
   uvx chroma-mcp --client-type persistent --data-dir ~/.claude/chroma-data
5. Check config syntax:
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool
```

### Database Corruption
```
1. STOP using Claude immediately
2. Check database: sqlite3 ~/.claude/chroma-data/chroma.sqlite3 "PRAGMA integrity_check;"
3. Restore from backup: claude-manage restore
4. If no backup, export what you can:
   sqlite3 ~/.claude/chroma-data/chroma.sqlite3 ".dump" > recovery.sql
5. Create fresh database and reimport
```

---

## Useful Aliases

The `claude-env` script is already set up! Add to PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.claude:$PATH"

# Then use these commands directly:
claude health          # Show system health
claude status          # Same as health
claude backup          # Create backup
claude restore         # Restore from backup
claude usage           # Show usage statistics
claude clean           # Cleanup old backups

# Docker services
claude start           # Start Docker services
claude stop            # Stop Docker services
claude restart         # Restart Docker services
claude logs            # View service logs
claude test            # Test connectivity

# Git auto-sync
claude autostart       # Manage auto-start
claude git-sync        # Manage git auto-sync
claude sync            # Run git sync manually

# Skill creation
claude skill-create    # Create Claude skills from docs

# Setup and initialization
claude init-db         # Initialize vector database
claude setup           # Run setup script
claude package         # Package for transfer
```

---

## Weekly Maintenance Routine

### Sunday Evening (15 minutes)
```
☐ Run: claude-status
☐ Check backup count: ls ~/.claude/backups | wc -l
☐ Clean old backups (keep last 10):
  cd ~/.claude/backups && ls -t | tail -n +11 | xargs rm -rf
☐ Review CLAUDE.md files, update as needed
☐ Check vector DB size: du -sh ~/.claude/chroma-data
☐ Archive old collections (>30 days unused)
☐ Run: claude-cache to check cache efficiency
☐ Plan next week's projects
```

---

## Key Metrics to Track

### Track in Spreadsheet or Notion
```
Date | Sessions | Tokens | Cost | Cache Hit% | Compacts | Issues
-----|----------|--------|------|------------|----------|--------
10/23|    5     |  125K  | $0.38|    82%     |    0     |   0
10/24|    3     |   75K  | $0.15|    91%     |    1     |   0
...
```

### Monthly Review Questions
```
1. What's my average cost per session?
2. Am I avoiding auto-compacts?
3. Is my cache hit rate improving?
4. Are there recurring issues?
5. What workflows can be optimized?
```

---

## Best Practices Summary

### DO ✅
- Check /context regularly
- Compact manually at 70%
- Store decisions in vector DB
- Keep CLAUDE.md under 200 lines
- Use /clear between unrelated tasks
- Start fresh sessions for major features
- Run backups weekly
- Monitor performance metrics

### DON'T ❌
- Wait for auto-compact (95%)
- Ignore context warnings
- Skip updating CLAUDE.md
- Let vector DB grow unchecked
- Repeat same context each session
- Continue complex work at 85%+ context
- Forget to backup before major changes
- Ignore MCP server errors

---

## Support Resources

**Quick Answers:**
- Executive Summary: One-page overview and ROI
- Quick Start Guide: Step-by-step setup
- Full Proposal: Complete technical docs

**Getting Help:**
1. Check troubleshooting section
2. Review relevant documentation
3. Check logs for error messages
4. Test components individually
5. Restore from backup if needed

---

**Print this card or keep it open in a separate window while working with Claude**

*Last updated: 2025-10-23 | Version 1.0*

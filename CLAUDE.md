# Global Claude Code Preferences

## Development Standards

- To resolve issues with missing or undefined Object references ALWAYS refer to the documentation. Use rapid7 mcp to pull latest docs for code libraries
- Before tasks are complete ensure all tests pass and there are no build errors
- All repositories that get created should be created as private
- When an error is encountered always use the @agent-research-analyst to search for a solution, write a resolution proposal spec and pass to the appropriate agent

## Context Management

### Proactive Context Control
- Monitor context usage regularly with `/context`
- **NEVER wait for auto-compact at 95%** - quality degrades significantly
- Perform manual compaction at 70% usage: `/compact keep {critical information}`
- Store important decisions in vector DB instead of repeating in conversation
- Use `/clear` between unrelated tasks to keep context lean
- Start fresh sessions (`/quit` then restart) for major features or architectural changes

### Context Budget Targets
- **Green Zone (0-70%):** Normal operation, optimal quality
- **Orange Zone (70-85%):** Plan compaction, move info to CLAUDE.md or vector DB
- **Red Zone (85-95%):** Stop work, save context, restart session
- **Danger Zone (95%+):** Should never reach - auto-compact will degrade quality

## Memory & Persistence Strategy

### Three-Layer Architecture
1. **CLAUDE.md files** (Auto-loaded, free, instant)
   - Global: `~/.claude/CLAUDE.md` (this file)
   - Project: `./CLAUDE.md` (project-specific)
   - Local: `./CLAUDE.local.md` (gitignored notes)

2. **Vector Database** (Persistent cross-session memory)
   - Chroma MCP for semantic search
   - Store architecture decisions and context
   - Retrieve with: "What do you remember about {topic}?"

3. **Prompt Caching** (90% cost savings)
   - Automatically enabled in Claude Desktop
   - Cache hit rate target: >70%

### Memory Operations
```
Store important info: "Store in memory: {decision/context}"
Retrieve context: "What do you remember about {topic}?"
Session handoff: "Summarize this session and store key decisions"
```

## Code Quality Standards

### Testing
- Minimum 70% test coverage for new code
- All tests must pass before task completion
- Write tests that cover failure cases, not just happy paths
- Use appropriate testing frameworks for the language

### Error Handling
- Always use @agent-research-analyst to research error solutions
- Document resolution in vector DB for future reference
- Create resolution proposal specs before implementing fixes

### Code Style
- Follow language-specific best practices
- Use type hints/annotations where supported
- Prefer explicit over implicit
- Write self-documenting code with clear naming

## Repository Management

- All new repositories must be created as **private** by default
- Use conventional commits for version control
- Include comprehensive README.md for all projects
- Keep CLAUDE.md updated with project-specific context

## Cost Optimization

### Token Efficiency
- Store repeated context in CLAUDE.md, not conversation
- Use vector DB retrieval instead of re-explaining
- Keep CLAUDE.md files concise (<200 lines recommended)
- Archive old conversations to vector DB

### Performance Targets
- Monthly cost target: <$10 for 100 sessions
- Cache hit rate: >70%
- Zero auto-compacts per month
- Context usage: Keep under 70% most of the time

## Tools & Integrations

### Available MCP Servers
- **Chroma:** Vector database for persistent memory
- **rapid7:** Documentation lookup
- **Filesystem:** Local file operations
- **OpenMemory:** Private local-first memory (optional)

### Recommended Tools
- uvx: Python package runner for MCP servers
- Chroma: Vector database (SQLite-backed, zero-config)
- Litestream: Automated SQLite backups (optional)

## Session Workflow

### Starting a Session
1. Navigate to project directory
2. Claude auto-loads global + project CLAUDE.md
3. Optional: "Check memory for recent context and summarize"

### During Session
- Check `/context` at milestones or every hour
- At 70%: Compact or store in vector DB
- Update CLAUDE.md with new conventions
- Store important decisions for next session

### Ending a Session
1. "Summarize session and store key decisions"
2. Update project CLAUDE.md if needed
3. Run backup (if configured)
4. `/quit` to end cleanly

## File Locations

```
Vector DB:          ~/.claude/chroma-data/
Backups:            ~/.claude/backups/
Global Config:      ~/.claude/CLAUDE.md (this file)
Project Config:     ./CLAUDE.md
Local Notes:        ./CLAUDE.local.md (gitignored)

Linux MCP Config:   ~/.config/Claude/claude_desktop_config.json
Linux Logs:         ~/.config/Claude/logs/
```

## Troubleshooting

### MCP Server Issues
```bash
# Check server status in Claude
/mcp

# View logs
tail -f ~/.config/Claude/logs/mcp*.log

# Test server manually
uvx chroma-mcp --client-type persistent --data-dir ~/.claude/chroma-data
```

### Context Issues
- If quality degrades: `/quit` and start fresh
- If context fills: Store in vector DB, then compact
- If information lost: Check vector DB for retrieval

### Memory Not Persisting
- Verify MCP server running: `/mcp`
- Check database exists: `ls ~/.claude/chroma-data`
- Test storage: "Store in memory: test at $(date)"

## Key Principles

1. **Proactive over Reactive:** Manage context before it becomes a problem
2. **Persistent over Ephemeral:** Store important information for reuse
3. **Efficient over Verbose:** Use tokens wisely, cache aggressively
4. **Quality over Speed:** Never compromise on test coverage or error handling
5. **Private by Default:** Security and privacy first

---

**Last Updated:** 2025-10-23
**Status:** Production-ready with optimization best practices
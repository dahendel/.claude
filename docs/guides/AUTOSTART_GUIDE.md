# Auto-start Guide

**Automatic Docker Vector Database Startup**

This guide explains how to automatically start the Claude vector database (Chroma) when your system boots, without using shell hooks that can cause terminal startup issues.

---

## Why Not Shell Hooks?

Previously, we used Fish shell hooks to auto-start Docker. This caused issues:
- WSL/Warp terminal crashes and hangs
- Slow terminal startup
- Race conditions with Docker daemon
- Hard to debug when things go wrong

**Solution:** Use system services instead (systemd on Linux, LaunchAgent on macOS)

---

## Installation

### Quick Install

```bash
claude-env autostart install
```

That's it! The service will:
- Start automatically when you log in
- Run in the background (no terminal blocking)
- Restart on failure
- Log to system journals

---

## Platform-Specific Details

### Linux (systemd)

**Service Location:**
```
~/.config/systemd/user/claude-docker.service
```

**Useful Commands:**
```bash
# Check status
systemctl --user status claude-docker

# View logs
journalctl --user -u claude-docker

# Manual control
systemctl --user start claude-docker
systemctl --user stop claude-docker
systemctl --user restart claude-docker

# Disable auto-start
systemctl --user disable claude-docker
```

**How It Works:**
- Runs as a user systemd service (no root required)
- Starts after Docker daemon is ready
- Logs to systemd journal
- Respects Docker availability

### macOS (LaunchAgent)

**Service Location:**
```
~/Library/LaunchAgents/com.claude.docker.plist
```

**Useful Commands:**
```bash
# Check status
launchctl list | grep claude

# View logs
cat /tmp/claude-docker.log
cat /tmp/claude-docker.err

# Manual control
launchctl start com.claude.docker
launchctl stop com.claude.docker

# Disable auto-start
launchctl unload ~/Library/LaunchAgents/com.claude.docker.plist
```

**How It Works:**
- Runs as a LaunchAgent (starts at login)
- Runs once (not kept alive)
- Logs to /tmp/claude-docker.log
- Requires Docker Desktop to be running

---

## Managing Auto-start

### Install Auto-start
```bash
claude-env autostart install
```

**Output:**
- Linux: "✓ Systemd service installed and started"
- macOS: "✓ LaunchAgent installed and loaded"

### Check Status
```bash
claude-env autostart status
```

**Shows:**
- Service running state
- Recent logs (macOS)
- Systemd status (Linux)

### Remove Auto-start
```bash
claude-env autostart remove
```

**Removes:**
- Service configuration
- Stops running service
- Keeps Docker container running

---

## Troubleshooting

### Service Won't Start (Linux)

```bash
# Check Docker daemon
docker info

# Check service logs
journalctl --user -u claude-docker -n 50

# Manual test
~/.claude/bin/claude-services.sh start
```

**Common Issues:**
- Docker not running: Start Docker first
- Permission errors: Check file permissions
- Path issues: Verify ~/.claude paths exist

### Service Won't Start (macOS)

```bash
# Check Docker Desktop
docker info

# Check logs
cat /tmp/claude-docker.err

# Manual test
~/.claude/bin/claude-services.sh start
```

**Common Issues:**
- Docker Desktop not running
- PATH not set in plist file
- Permissions on script files

### Container Already Running

```bash
# Check if already running
docker ps | grep claude-chroma

# If needed, stop and restart
docker stop claude-chroma
claude-env start
```

---

## Migration from Shell Hooks

If you previously had auto-start in Fish config:

**Old Method (Remove This):**
```fish
# DON'T USE - causes terminal crashes
if status is-interactive; and not set -q CLAUDE_DOCKER_CHECKED
    # ... Docker auto-start code ...
end
```

**New Method (Use This):**
```bash
# One-time setup
claude-env autostart install

# That's it! Service runs independently of shell
```

**Benefits:**
- No terminal startup delays
- No WSL/Warp crashes
- Proper logging
- Easy to debug
- Works across all shells (Fish, Bash, Zsh)

---

## Advanced Configuration

### Custom Service Location

**Linux:**
Edit `~/.config/systemd/user/claude-docker.service` then:
```bash
systemctl --user daemon-reload
systemctl --user restart claude-docker
```

**macOS:**
Edit `~/Library/LaunchAgents/com.claude.docker.plist` then:
```bash
launchctl unload ~/Library/LaunchAgents/com.claude.docker.plist
launchctl load ~/Library/LaunchAgents/com.claude.docker.plist
```

### Delay Start on Boot

**Linux (wait 30 seconds):**
Add to service file:
```ini
[Service]
ExecStartPre=/bin/sleep 30
```

**macOS (wait 30 seconds):**
Add to plist:
```xml
<key>StartInterval</key>
<integer>30</integer>
```

### Run on Network Connection

**macOS only:**
Add to plist:
```xml
<key>LaunchOnlyOnce</key>
<true/>
<key>RunAtLoad</key>
<false/>
<key>StartOnMount</key>
<true/>
```

---

## Verification

After installation, verify it works:

1. **Reboot your system** (or log out/in)

2. **Check Docker container:**
   ```bash
   docker ps | grep claude-chroma
   ```

3. **Should see:**
   ```
   claude-chroma   Up X minutes   0.0.0.0:8000->8000/tcp
   ```

4. **Test connectivity:**
   ```bash
   claude-env test
   ```

---

## Uninstall

To completely remove auto-start:

```bash
# Remove service
claude-env autostart remove

# Stop container manually if needed
claude-env stop
```

---

## FAQ

**Q: Will this work with Docker Desktop?**
A: Yes! Works with Docker Desktop on both macOS and Windows (WSL).

**Q: Does this require root/admin?**
A: No. User-level services only.

**Q: What if Docker isn't running?**
A: Service will fail gracefully. No terminal impact. Check logs.

**Q: Can I use both shell hooks and system service?**
A: No. Pick one. System service is recommended.

**Q: Will this work in Warp terminal?**
A: Yes! System services don't affect terminal startup.

**Q: How do I check if it's installed?**
A: Run `claude-env autostart status`

---

**Created:** 2025-10-24
**Platforms:** Linux (systemd), macOS (LaunchAgent)
**Shell Independent:** Works with Fish, Bash, Zsh, any shell

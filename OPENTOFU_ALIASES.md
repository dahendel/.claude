# OpenTofu Aliases Quick Reference

**All aliases configured in `~/.config/fish/config.fish`**

---

## Basic Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `tf` | `tofu` | Base OpenTofu command |
| `tfi` | `tofu init` | Initialize working directory |
| `tfp` | `tofu plan` | Generate execution plan |
| `tfa` | `tofu apply` | Apply changes |
| `tfd` | `tofu destroy` | Destroy infrastructure |
| `tfv` | `tofu validate` | Validate configuration |
| `tff` | `tofu fmt` | Format configuration files |
| `tfs` | `tofu show` | Show current state |
| `tfo` | `tofu output` | Show output values |

---

## Auto-Approve Variants

| Alias | Command | Description |
|-------|---------|-------------|
| `tfaa` | `tofu apply -auto-approve` | Apply without confirmation |
| `tfda` | `tofu destroy -auto-approve` | Destroy without confirmation |

---

## Common Workflows

| Alias | Command | Description |
|-------|---------|-------------|
| `tfir` | `tofu init -reconfigure` | Reconfigure backend |
| `tfiu` | `tofu init -upgrade` | Upgrade providers |
| `tfpd` | `tofu plan -destroy` | Plan destruction |
| `tfpo` | `tofu plan -out=tfplan` | Save plan to file |
| `tfao` | `tofu apply tfplan` | Apply saved plan |

---

## State Management

| Alias | Command | Description |
|-------|---------|-------------|
| `tfsl` | `tofu state list` | List resources in state |
| `tfss` | `tofu state show` | Show resource details |
| `tfsm` | `tofu state mv` | Move resource in state |
| `tfsrm` | `tofu state rm` | Remove resource from state |
| `tfsp` | `tofu state pull` | Pull remote state |
| `tfspu` | `tofu state push` | Push local state |

---

## Workspace Management

| Alias | Command | Description |
|-------|---------|-------------|
| `tfwl` | `tofu workspace list` | List workspaces |
| `tfwn` | `tofu workspace new` | Create new workspace |
| `tfws` | `tofu workspace select` | Switch workspace |
| `tfwd` | `tofu workspace delete` | Delete workspace |

---

## Import and Taint

| Alias | Command | Description |
|-------|---------|-------------|
| `tfim` | `tofu import` | Import existing resource |
| `tftaint` | `tofu taint` | Mark resource for recreation |
| `tfuntaint` | `tofu untaint` | Unmark tainted resource |

---

## Console and Graph

| Alias | Command | Description |
|-------|---------|-------------|
| `tfc` | `tofu console` | Interactive console |
| `tfg` | `tofu graph` | Generate dependency graph |

---

## Provider Management

| Alias | Command | Description |
|-------|---------|-------------|
| `tfpi` | `tofu providers` | Show providers |
| `tfpl` | `tofu providers lock` | Lock provider versions |
| `tfps` | `tofu providers schema` | Show provider schemas |

---

## Common Usage Examples

```fish
# Standard workflow
tfi           # Initialize
tfp           # Plan changes
tfa           # Apply (with confirmation)

# Quick apply
tfaa          # Apply without confirmation

# Save and apply plan
tfpo          # Save plan to tfplan file
tfao          # Apply the saved plan

# State inspection
tfsl          # List all resources
tfss aws_instance.example  # Show specific resource

# Workspace management
tfwl          # List workspaces
tfwn dev      # Create dev workspace
tfws dev      # Switch to dev workspace

# Cleanup
tfd           # Destroy (with confirmation)
tfda          # Destroy without confirmation
```

---

## Tips

- Use `tfaa` carefully - it bypasses confirmation prompts
- Always review `tfp` output before running `tfa`
- Use `tfpo` + `tfao` for safer applies in automation
- Check `tfsl` to see what's in your state
- Use workspaces (`tfwn`, `tfws`) for environment isolation

---

**Created:** 2025-10-24
**Location:** `~/.claude/OPENTOFU_ALIASES.md`

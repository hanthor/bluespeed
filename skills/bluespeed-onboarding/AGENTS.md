# bluespeed-onboarding - Agent Execution Notes

## Overview

This skill configures OpenCode and Goose with MCP servers for Project Bluefin maintenance work.

## Key Architecture Principle

**SKILL.md is the source of truth.** Agents read SKILL.md from GitHub and execute instructions inline using the Bash tool. Bash scripts in `scripts/` are optional reference implementations for manual users only.

## User Invocation Pattern

User says one of:
- **"Onboard me to projectbluefin/bluespeed"**
- **"Onboard me to castrojo/bluespeed"**
- **"Setup my Bluefin environment"**
- **"Configure MCP servers for Bluefin"**

## Agent Execution Flow

1. **Search GitHub** - Find `castrojo/bluespeed` repository
2. **Read SKILL.md** - Fetch `skills/bluespeed-onboarding/SKILL.md` from remote
3. **Execute inline** - Follow SKILL.md steps using Bash tool (NO cloning, NO script execution)
4. **Auto-install prerequisites** - Install jq, yq, linux-mcp-server via brew if missing
5. **Detect username** - Use `whoami` command (never hardcode)
6. **Backup configs** - Create timestamped backups before any changes
7. **Merge configurations** - Add MCP servers, skip if already exist
8. **Validate** - Check JSON/YAML syntax, auto-rollback on error
9. **Report results** - Tell user to restart OpenCode with clear instructions

## Expected Behavior

### Prerequisites Check
- Verify Homebrew installed (fail fast if missing)
- Auto-install jq if missing: `brew install jq`
- Auto-install yq if missing: `brew install yq`
- Auto-install linux-mcp-server if missing: `brew install ublue-os/tap/linux-mcp-server`

### Configuration Merging
- **OpenCode**: Add dosu and linux-mcp-server to `.mcp` object
- **Goose**: Add linux-mcp-server to `.extensions` array (dosu pending Phase 4)
- **Skip duplicates**: If MCP server/extension already exists, log warning and continue
- **Preserve user settings**: Never overwrite existing configuration

### Backup Strategy
- Create timestamped backup before any changes: `<file>.<ISO-timestamp>.backup`
- Example: `opencode.json.2026-02-11T16:30:45.backup`
- Auto-restore from backup if validation fails

### Validation
- JSON: `jq empty <file>` must succeed
- YAML: `yq eval '.' <file>` must succeed
- On failure: Restore backup and exit with clear error message

## Success Output Example

```
[INFO] Installing jq...
[SUCCESS] jq is installed
[INFO] Installing yq...
[SUCCESS] yq is installed
[INFO] Installing linux-mcp-server...
[SUCCESS] linux-mcp-server is installed
[INFO] Detected username: jorge
[INFO] Backup created: /home/jorge/.config/opencode/opencode.json.2026-02-11T16:30:45.backup
[SUCCESS] Added dosu MCP configuration
[SUCCESS] Added linux-mcp-server configuration (user: jorge)
[SUCCESS] JSON validation passed

✓ OpenCode configuration complete!

Next steps:
  1. Close all OpenCode windows
  2. Restart OpenCode from application menu or 'opencode' command
  3. Verify MCP servers loaded: Check "MCP Servers" panel in sidebar
  4. Test: Ask "Can you check my system information?" (tests linux-mcp-server)

Troubleshooting:
  - Logs: ~/.config/opencode/logs/
  - Config: ~/.config/opencode/opencode.json
  - Backup: /home/jorge/.config/opencode/opencode.json.2026-02-11T16:30:45.backup
```

## Error Handling Example

If validation fails:

```
[ERROR] JSON validation failed: /home/jorge/.config/opencode/opencode.json
[ERROR] Restoring backup...
[SUCCESS] Restored from backup: /home/jorge/.config/opencode/opencode.json.2026-02-11T16:30:45.backup

ERROR: Configuration validation failed

Your original config has been restored. No changes were made.

To troubleshoot:
  1. Check JSON syntax: jq empty ~/.config/opencode/opencode.json
  2. View backup: cat ~/.config/opencode/opencode.json.2026-02-11T16:30:45.backup
  3. Check logs: ~/.config/opencode/logs/
```

## Configuration Paths

- **OpenCode config**: `~/.config/opencode/opencode.json`
- **Goose config**: `~/.config/goose/config.yaml`
- **linux-mcp-server binary**: `/home/linuxbrew/.linuxbrew/bin/linux-mcp-server`

## dosu MCP Details

- **Deployment ID**: `83775020-c22e-485a-a222-987b2f5a3823`
- **API Endpoint**: `https://api.dosu.dev/v1/mcp`
- **Type**: Remote MCP server (no installation required)
- **Authentication**: `X-Deployment-ID` header (public identifier, safe to commit)

## Bash Scripts (Optional Reference)

Scripts in `scripts/` directory are **reference implementations only**:
- `scripts/bluespeed-onboarding.sh` - Main entry point (interactive mode)
- `scripts/setup-opencode.sh` - OpenCode-specific setup
- `scripts/setup-goose.sh` - Goose-specific setup
- `scripts/lib/common.sh` - Logging and backup utilities
- `scripts/lib/config.sh` - JSON/YAML manipulation functions
- `scripts/lib/validation.sh` - Prerequisite checking functions

**Agents should NOT execute these scripts.** They exist for manual users who prefer standalone bash scripts over AI-driven automation.

## Testing the Skill

After configuration, test that MCP servers are working:

### OpenCode Testing
1. Restart OpenCode
2. Check sidebar for "MCP Servers" panel
3. Verify "dosu" and "linux-mcp-server" listed
4. Ask: "Can you check my system information?"
5. Agent should use linux-mcp-server tools to respond

### Goose Testing
1. Restart Goose
2. Check startup messages for "linux-mcp-server" extension loading
3. Ask: "Can you check my disk usage?"
4. Agent should use linux-mcp-server tools to respond

## Common Issues

### Issue: "Homebrew not found"
**Solution**: User must install Homebrew first from https://brew.sh

### Issue: "dosu already configured"
**Expected**: Skill skips with warning message, continues to next step

### Issue: "JSON validation failed"
**Solution**: Restore backup automatically, report error with remediation steps

### Issue: "linux-mcp-server not found after installation"
**Solution**: Verify Homebrew tap added: `brew tap ublue-os/tap`

## Phase 4 Enhancements

Planned future improvements:
- Add dosu remote MCP support for Goose (pending research)
- Auto-install with user confirmation prompts
- Better error messages with troubleshooting steps
- Support for additional MCP servers

## Related Documentation

- **SKILL.md**: Primary executable specification (agents follow this)
- **Repository AGENTS.md**: Overall repository structure and guidelines
- **configs/README.md**: Prerequisite documentation and configuration examples
- **Epic #1**: https://github.com/castrojo/bluespeed/issues/1

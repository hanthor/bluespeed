---
name: bluespeed-onboarding
description: Setup dosu MCP and linux-mcp-server for Bluefin maintainers
---

# bluespeed-onboarding

Automated setup of MCP servers for Project Bluefin maintainers using AI coding tools (OpenCode/Goose).

## When to Use

This skill should be invoked when:
- User says: **"Onboard me to projectbluefin/bluespeed"** or **"Onboard me to castrojo/bluespeed"**
- New Bluefin contributor needs MCP servers configured
- Existing contributor wants to update/fix their MCP configuration

## What This Skill Does

Configures AI tools with the following MCP servers:

### OpenCode (Full Support)
- **dosu MCP** - Remote server providing Bluefin knowledge base access
- **linux-mcp-server** - Local server for Linux system diagnostics

### Goose (Partial Support - MVP)
- **linux-mcp-server** - Local server for Linux system diagnostics
- **dosu MCP** - Planned for Phase 4 (pending Goose remote MCP research)

## Prerequisites

The following packages are **required** and will be auto-installed if missing:

```bash
# JSON/YAML manipulation (Required)
brew install jq
brew install yq

# MCP Servers (Required)
brew install ublue-os/tap/linux-mcp-server
```

**Homebrew must be installed** - skill will fail fast if missing. Install from: https://brew.sh

## Skill Execution Process

When an agent executes this skill, follow these steps **inline** using the Bash tool. Do NOT clone this repository or run bash scripts - execute commands directly.

### Step 1: Verify Homebrew

```bash
if ! command -v brew &>/dev/null; then
    echo "ERROR: Homebrew is not installed. Install from: https://brew.sh"
    exit 1
fi
```

### Step 2: Auto-Install jq if Missing

```bash
if ! command -v jq &>/dev/null; then
    echo "Installing jq..."
    brew install jq
    # Verify installation
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq installation failed"
        exit 1
    fi
fi
```

### Step 3: Auto-Install yq if Missing

```bash
if ! command -v yq &>/dev/null; then
    echo "Installing yq..."
    brew install yq
    # Verify installation
    if ! command -v yq &>/dev/null; then
        echo "ERROR: yq installation failed"
        exit 1
    fi
fi
```

### Step 4: Auto-Install linux-mcp-server if Missing

```bash
if [[ ! -f /home/linuxbrew/.linuxbrew/bin/linux-mcp-server ]]; then
    echo "Installing linux-mcp-server..."
    brew install ublue-os/tap/linux-mcp-server
    # Verify installation
    if [[ ! -f /home/linuxbrew/.linuxbrew/bin/linux-mcp-server ]]; then
        echo "ERROR: linux-mcp-server installation failed"
        exit 1
    fi
fi
```

### Step 5: Detect Username

```bash
USERNAME=$(whoami)
echo "Detected username: $USERNAME"
```

### Step 6: Backup Existing OpenCode Config

```bash
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")

# Create config directory if needed
mkdir -p "$HOME/.config/opencode"

# Create default config if missing
if [[ ! -f "$OPENCODE_CONFIG" ]]; then
    echo '{"mcp":{}}' | jq '.' > "$OPENCODE_CONFIG"
    echo "Created default OpenCode config"
fi

# Backup existing config
BACKUP_PATH="${OPENCODE_CONFIG}.${TIMESTAMP}.backup"
cp "$OPENCODE_CONFIG" "$BACKUP_PATH"
echo "Backup created: $BACKUP_PATH"
```

### Step 7: Merge dosu MCP Configuration

```bash
# Check if dosu already exists
if jq -e '.mcp.dosu' "$OPENCODE_CONFIG" >/dev/null 2>&1; then
    echo "WARNING: dosu MCP already configured, skipping..."
else
    # Merge dosu configuration
    jq '.mcp.dosu = {
        "type": "remote",
        "url": "https://api.dosu.dev/v1/mcp",
        "headers": {
            "X-Deployment-ID": "83775020-c22e-485a-a222-987b2f5a3823"
        }
    }' "$OPENCODE_CONFIG" > "${OPENCODE_CONFIG}.tmp"
    mv "${OPENCODE_CONFIG}.tmp" "$OPENCODE_CONFIG"
    echo "SUCCESS: Added dosu MCP configuration"
fi
```

### Step 8: Merge linux-mcp-server Configuration

```bash
# Check if linux-mcp-server already exists
if jq -e '.mcp."linux-mcp-server"' "$OPENCODE_CONFIG" >/dev/null 2>&1; then
    echo "WARNING: linux-mcp-server already configured, skipping..."
else
    # Merge linux-mcp-server configuration
    jq --arg user "$USERNAME" '.mcp."linux-mcp-server" = {
        "type": "stdio",
        "command": "/home/linuxbrew/.linuxbrew/bin/linux-mcp-server",
        "env": {
            "LINUX_MCP_USER": $user
        }
    }' "$OPENCODE_CONFIG" > "${OPENCODE_CONFIG}.tmp"
    mv "${OPENCODE_CONFIG}.tmp" "$OPENCODE_CONFIG"
    echo "SUCCESS: Added linux-mcp-server configuration (user: $USERNAME)"
fi
```

### Step 9: Validate JSON Configuration

```bash
# Validate final configuration
if jq empty "$OPENCODE_CONFIG" 2>/dev/null; then
    echo "SUCCESS: JSON validation passed"
else
    echo "ERROR: JSON validation failed, restoring backup..."
    cp "$BACKUP_PATH" "$OPENCODE_CONFIG"
    exit 1
fi
```

### Step 10: Instruct User to Restart OpenCode

After successful configuration, tell the user:

```
✓ OpenCode configuration complete!

Next steps:
  1. Close all OpenCode windows
  2. Restart OpenCode from application menu or 'opencode' command
  3. Verify MCP servers loaded: Check "MCP Servers" panel in sidebar
  4. Test: Ask "Can you check my system information?" (tests linux-mcp-server)

Troubleshooting:
  - Logs: ~/.config/opencode/logs/
  - Config: ~/.config/opencode/opencode.json
  - Backup: [backup path from step 6]
```

## Goose Configuration (Optional)

If the user also wants to configure Goose, follow similar steps:

### Goose Step 1: Create/Backup Config

```bash
GOOSE_CONFIG="$HOME/.config/goose/config.yaml"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")

# Create config directory if needed
mkdir -p "$HOME/.config/goose"

# Create default config if missing
if [[ ! -f "$GOOSE_CONFIG" ]]; then
    echo 'extensions: []' > "$GOOSE_CONFIG"
    echo "Created default Goose config"
fi

# Backup existing config
BACKUP_PATH="${GOOSE_CONFIG}.${TIMESTAMP}.backup"
cp "$GOOSE_CONFIG" "$BACKUP_PATH"
echo "Backup created: $BACKUP_PATH"
```

### Goose Step 2: Merge linux-mcp-server Extension

```bash
# Check if linux-mcp-server extension already exists
if yq eval '.extensions[] | select(.name == "linux-mcp-server")' "$GOOSE_CONFIG" 2>/dev/null | grep -q linux-mcp-server; then
    echo "WARNING: linux-mcp-server extension already configured, skipping..."
else
    # Merge linux-mcp-server extension
    yq eval ".extensions += [{
        \"name\": \"linux-mcp-server\",
        \"type\": \"stdio\",
        \"command\": \"/home/linuxbrew/.linuxbrew/bin/linux-mcp-server\",
        \"env\": {
            \"LINUX_MCP_USER\": \"$USERNAME\"
        }
    }]" "$GOOSE_CONFIG" > "${GOOSE_CONFIG}.tmp"
    mv "${GOOSE_CONFIG}.tmp" "$GOOSE_CONFIG"
    echo "SUCCESS: Added linux-mcp-server extension (user: $USERNAME)"
fi

echo "NOTE: Phase 4 TODO - dosu MCP support for Goose pending research"
```

### Goose Step 3: Validate YAML Configuration

```bash
# Validate final configuration
if yq eval '.' "$GOOSE_CONFIG" >/dev/null 2>&1; then
    echo "SUCCESS: YAML validation passed"
else
    echo "ERROR: YAML validation failed, restoring backup..."
    cp "$BACKUP_PATH" "$GOOSE_CONFIG"
    exit 1
fi
```

### Goose Step 4: Instruct User to Restart Goose

```
✓ Goose configuration complete!

Next steps:
  1. Exit Goose session: 'exit' command or Ctrl+D
  2. Restart Goose from terminal: 'goose'
  3. Verify extensions: Check startup messages for 'linux-mcp-server' loading
  4. Test: Ask "Can you check my disk usage?" (tests linux-mcp-server)

Note: dosu MCP support for Goose is planned for Phase 4

Troubleshooting:
  - Logs: ~/.config/goose/logs/
  - Config: ~/.config/goose/config.yaml
  - Backup: [backup path from Goose step 1]
```

## Error Handling

If any step fails:

1. **Restore from backup** - Use the timestamped backup created in Step 6
2. **Report clear error** - Tell user exactly what failed and why
3. **Provide remediation** - Include exact commands to fix the issue

Example error message:
```
ERROR: linux-mcp-server installation failed

To fix:
  1. Check Homebrew tap: brew tap ublue-os/tap
  2. Try manual install: brew install ublue-os/tap/linux-mcp-server
  3. Verify installation: ls /home/linuxbrew/.linuxbrew/bin/linux-mcp-server
  4. Re-run this skill after fixing

Your config has been restored from backup: [backup path]
```

## Success Criteria

After executing this skill successfully:

- ✅ jq, yq, and linux-mcp-server are installed
- ✅ OpenCode config contains dosu and linux-mcp-server MCP servers
- ✅ Username is automatically detected and configured
- ✅ Existing user configuration is preserved (no overwriting)
- ✅ Timestamped backup created before any changes
- ✅ JSON/YAML validation passed
- ✅ User instructed to restart OpenCode with clear next steps
- ✅ (Optional) Goose config contains linux-mcp-server extension

## Important Notes

### For AI Agents

- **DO NOT clone this repository** - Read SKILL.md from GitHub and execute inline
- **DO NOT run bash scripts** - Follow these instructions directly using Bash tool
- **DO auto-install prerequisites** - Use brew to install missing packages
- **DO preserve existing configs** - Skip duplicates, don't overwrite user settings
- **DO create backups** - Always backup before modifying configs
- **DO validate changes** - Check JSON/YAML syntax, auto-rollback on error

### For Manual Users

Bash reference scripts are available in `scripts/` directory:
- `scripts/bluespeed-onboarding.sh` - Main entry point (interactive mode)
- `scripts/setup-opencode.sh` - OpenCode-specific setup
- `scripts/setup-goose.sh` - Goose-specific setup

These scripts implement the same logic as this SKILL.md for manual execution.

## Configuration Details

### dosu MCP Server

- **Type**: Remote MCP server
- **Deployment ID**: `83775020-c22e-485a-a222-987b2f5a3823`
- **API Endpoint**: `https://api.dosu.dev/v1/mcp`
- **Authentication**: Via `X-Deployment-ID` header (public identifier)
- **Purpose**: Bluefin-specific knowledge base and documentation access
- **No installation required** - Remote service only

### linux-mcp-server

- **Type**: Local MCP server (stdio)
- **Binary location**: `/home/linuxbrew/.linuxbrew/bin/linux-mcp-server`
- **Environment variable**: `LINUX_MCP_USER` (set to current username)
- **Purpose**: Linux system diagnostics (disk usage, memory, processes, services, logs)
- **Installation**: `brew install ublue-os/tap/linux-mcp-server`

## Phase 4 Enhancements (Future)

Planned improvements:
- Add dosu remote MCP support for Goose (pending research)
- Enhanced auto-install with user confirmation prompts
- Better error recovery and rollback mechanisms
- Support for additional MCP servers as they become available

## Related Documentation

- **Repository README**: https://github.com/castrojo/bluespeed/blob/main/README.md
- **Configuration Examples**: https://github.com/castrojo/bluespeed/tree/main/configs
- **Agent Guidelines**: https://github.com/castrojo/bluespeed/blob/main/AGENTS.md
- **Project Bluefin**: https://github.com/ublue-os/bluefin

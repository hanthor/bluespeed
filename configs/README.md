# Configuration Examples

This directory contains template configurations showing the target structure for OpenCode and Goose MCP server integration. These are **reference templates** for documentation purposes - agents execute inline commands from SKILL.md rather than using these files directly.

## Prerequisites

All required packages must be installed via Homebrew before running the bluespeed-onboarding skill.

### Core AI Tools

```bash
# OpenCode (Primary - Required for MVP)
brew install --cask ublue-os/experimental-tap/opencode-desktop-linux

# Goose (Optional - MVP has partial support)
brew install --cask ublue-os/tap/goose-linux
```

### MCP Servers

```bash
# linux-mcp-server (Local MCP - Required)
brew install ublue-os/tap/linux-mcp-server

# dosu MCP (Remote - No installation needed)
# Configured via deployment ID: 83775020-c22e-485a-a222-987b2f5a3823
# API endpoint: https://api.dosu.dev/v1/mcp
```

### Configuration Utilities

```bash
# JSON manipulation (Required)
brew install jq

# YAML manipulation (Required)
brew install yq
```

### Package Summary

| Package | Type | Purpose | Status |
|---------|------|---------|--------|
| `ublue-os/experimental-tap/opencode-desktop-linux` | Cask | AI coding assistant (primary) | Required for OpenCode setup |
| `ublue-os/tap/goose-linux` | Cask | AI coding assistant (alternative) | Optional (MVP partial support) |
| `ublue-os/tap/linux-mcp-server` | Formula | Local MCP for Linux diagnostics | Required |
| `jq` | Formula | JSON config manipulation | Required |
| `yq` | Formula | YAML config manipulation | Required |
| dosu MCP | Remote | Bluefin knowledge base MCP | No install needed (remote) |

## Configuration Files

### opencode-example.json

Template showing OpenCode MCP server configuration with:
- **dosu MCP** - Remote server for Bluefin knowledge base access
- **linux-mcp-server** - Local server for Linux system diagnostics

**Target location:** `~/.config/opencode/opencode.json`

**Important notes:**
- Replace `REPLACE_WITH_YOUR_USERNAME` with your actual username (detected via `whoami`)
- The bluespeed-onboarding skill merges these settings automatically
- Existing MCP servers are preserved (no overwriting)

### goose-example.yaml

Template showing Goose extension configuration with:
- **linux-mcp-server** - Local MCP for Linux system diagnostics
- **dosu support** - Marked as TODO (Phase 4 enhancement)

**Target location:** `~/.config/goose/config.yaml`

**Important notes:**
- Replace `REPLACE_WITH_YOUR_USERNAME` with your actual username (detected via `whoami`)
- The bluespeed-onboarding skill merges these settings automatically
- Existing extensions are preserved (no overwriting)
- Phase 4: Research and add dosu remote MCP support for Goose

## Dosu Deployment Details

- **Deployment ID**: `83775020-c22e-485a-a222-987b2f5a3823`
- **API Endpoint**: `https://api.dosu.dev/v1/mcp`
- **Type**: Remote MCP server
- **Authentication**: Via `X-Deployment-ID` header (public identifier, not secret)
- **Purpose**: Provides Bluefin-specific knowledge base and documentation access

## Configuration Paths

- **OpenCode config**: `~/.config/opencode/opencode.json`
- **Goose config**: `~/.config/goose/config.yaml`
- **linux-mcp-server binary**: `/home/linuxbrew/.linuxbrew/bin/linux-mcp-server`

## Restart Instructions

### OpenCode

1. Close all OpenCode windows
2. Restart OpenCode from application menu or `opencode` command
3. Verify MCP servers loaded: Check "MCP Servers" panel in sidebar
4. Test: Ask "Can you check my system information?" (tests linux-mcp-server)
5. Troubleshooting: Logs at `~/.config/opencode/logs/`, config at `~/.config/opencode/opencode.json`

### Goose

1. Exit Goose session: `exit` command or `Ctrl+D`
2. Restart Goose from terminal: `goose`
3. Verify extensions: Check startup messages for "linux-mcp-server" loading
4. Test: Ask "Can you check my disk usage?" (tests linux-mcp-server)
5. Troubleshooting: Logs at `~/.config/goose/logs/`, config at `~/.config/goose/config.yaml`

## Usage

These templates are for reference only. To configure your AI tools:

1. Install prerequisites (see above)
2. Run the bluespeed-onboarding skill: "Onboard me to projectbluefin/bluespeed"
3. Agent will read SKILL.md from GitHub and execute instructions inline
4. Configuration will be merged automatically (preserving existing settings)
5. Restart OpenCode/Goose to activate changes

## Manual Configuration

If you prefer manual setup, you can:

1. Read the example JSON/YAML files in this directory
2. Copy relevant sections to your config files
3. Replace `REPLACE_WITH_YOUR_USERNAME` with your username
4. Validate syntax: `jq empty ~/.config/opencode/opencode.json`
5. Restart your AI tool

**Note:** The automated skill is recommended - it handles merging, validation, and error recovery automatically.

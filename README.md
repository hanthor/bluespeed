# bluespeed

**Agents and skills for maintaining Project Bluefin**

This repository contains AI agent skills and automation tools designed to help Project Bluefin maintainers work more efficiently with AI tooling.

## Purpose

bluespeed provides:
- **Onboarding automation** - Quick setup of AI tools (dosu MCP, linux-mcp-server)
- **Maintenance skills** - Reusable agent workflows for common tasks
- **Configuration management** - Template configs and merge utilities

## Current Skills

### bluespeed-onboarding
Automates setup of dosu MCP server and linux-mcp-server for OpenCode and Goose.

**Status:** In Development ([Epic #1](https://github.com/castrojo/bluespeed/issues/1))

**What it does:**
- Configures OpenCode with dosu MCP + linux-mcp-server
- Configures Goose with linux-mcp-server (Phase 4)
- Merges configurations without overwriting user settings
- Validates prerequisites (Homebrew packages)

## Prerequisites

### Required Homebrew Packages
```bash
brew install ublue-os/tap/linux-mcp-server
brew install ublue-os/experimental-tap/opencode-desktop-linux
```

### Optional (for Goose support)
```bash
brew install ublue-os/tap/goose-linux
```

## For Developers

See [AGENTS.md](AGENTS.md) for:
- Repository structure and organization
- Skill development guidelines
- Script naming conventions
- Library function patterns
- Best practices for AI agents

## Technology Stack

- **Bash scripts** - System automation and configuration
- **jq/yq** - JSON/YAML manipulation
- **OpenCode Skills** - Primary skill format
- **Goose Extensions** - Future enhancement
- **MCP Servers** - dosu (remote), linux-mcp-server (local)

## Related Projects

- **Project Bluefin** - Universal Blue desktop distribution ([projectbluefin/main](https://github.com/ublue-os/bluefin))
- **Bluefin Documentation** - User and developer docs ([projectbluefin/documentation](https://github.com/ublue-os/bluefin-documentation))
- **Powerlevel** - AI agent workflow framework ([castrojo/powerlevel](https://github.com/castrojo/powerlevel))

## Contributing

This repository follows the [Powerlevel workflow](https://github.com/castrojo/powerlevel):
1. **writing-plans** - Create implementation plan in `docs/plans/`
2. **epic-creation** - Generate GitHub epic + sub-tasks
3. **executing-plans** - Work through tasks systematically

See AGENTS.md for detailed development guidelines.

## License

MIT License - see LICENSE file for details.

## Maintainers

- [@castrojo](https://github.com/castrojo) - Primary maintainer

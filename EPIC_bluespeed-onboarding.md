# EPIC: bluespeed-onboarding Skill & Agent

## Overview
Create the first skill and agent in the `castrojo/bluespeed` repository to onboard Bluefin maintainers to AI tooling (dosu MCP + linux-mcp-server).

**Repository**: castrojo/bluespeed (public)  
**Purpose**: Agents and skills for maintaining Project Bluefin  
**Target Users**: Bluefin maintainers and contributors

## Goals
1. Provide automated setup of dosu MCP server and linux-mcp-server for OpenCode (MVP)
2. Provide example configurations and documentation for manual setup
3. Create extensible pattern for future Bluefin maintenance skills
4. Document Goose support as future enhancement

## Prerequisites
Users must have the following brew packages installed:
- `brew install ublue-os/tap/linux-mcp-server` (provides linux-mcp-server + goose-mcp-setup script)
- `brew install --cask ublue-os/experimental-tap/opencode-desktop-linux` (OpenCode desktop + CLI)
- `brew install --cask ublue-os/tap/goose-linux` (optional, for Goose users)

## Technical Decisions

### 1. Username Detection
**Decision**: Use `whoami` command to detect current username for `LINUX_MCP_USER` environment variable  
**Rationale**: Dynamic detection ensures portability across different user accounts

### 2. Repository Visibility  
**Decision**: Public repository  
**Rationale**: Aligns with Bluefin's open source philosophy and "bring your own LLM" approach

### 3. OpenCode as MVP, Goose as Future Enhancement
**Decision**: Implement full support for OpenCode first, document Goose as planned future work  
**Rationale**:
- OpenCode supports remote MCP servers (dosu) via JSON config with `type: "remote"`
- Goose uses YAML config with `type: stdio` for local MCP servers
- Goose's remote MCP server support is unclear from documentation
- OpenCode provides complete solution today; Goose can be added incrementally

**Goose Future Work**:
- Research Goose remote MCP server configuration options
- If remote MCP not supported, document as OpenCode-only feature
- Implement Goose linux-mcp-server setup (stdio type) as phase 2
- Consider alternatives: run dosu via proxy, use different knowledge base solution for Goose

### 4. Deployment ID is Public
**Decision**: Include Bluefin dosu deployment ID (`83775020-c22e-485a-a222-987b2f5a3823`) in example configs  
**Rationale**: Not a secret, publicly shareable, safe to commit to public repository

## Repository Structure

```
/var/home/jorge/src/bluespeed/
├── .gitignore                           # Exclude *.local only
├── README.md                            # Repository purpose and overview
├── skills/
│   └── bluespeed-onboarding/
│       └── SKILL.md                     # Setup instructions for agents
├── agents/
│   └── bluespeed-onboarding/
│       └── AGENTS.md                    # Agent execution instructions
└── configs/
    ├── README.md                        # Explanation of example configs
    ├── opencode-example.json            # OpenCode MCP config (dosu + linux-mcp-server)
    └── goose-example.yaml               # Goose MCP config (linux-mcp-server only, for future)
```

## Configuration Formats

### OpenCode Config (`configs/opencode-example.json`)
```json
{
  "mcp": {
    "dosu": {
      "type": "remote",
      "url": "https://api.dosu.dev/v1/mcp",
      "enabled": true,
      "headers": {
        "X-Deployment-ID": "83775020-c22e-485a-a222-987b2f5a3823"
      }
    },
    "linux-mcp-server": {
      "type": "local",
      "command": ["/home/linuxbrew/.linuxbrew/bin/linux-mcp-server"],
      "enabled": true,
      "environment": {
        "LINUX_MCP_USER": "REPLACE_WITH_YOUR_USERNAME"
      }
    }
  }
}
```

### Goose Config (`configs/goose-example.yaml`) - Future Enhancement
```yaml
extensions:
  linux-tools:
    enabled: true
    type: stdio
    name: linux-tools
    description: Linux system administration and diagnostics
    cmd: /home/linuxbrew/.linuxbrew/bin/linux-mcp-server
    envs:
      LINUX_MCP_USER: REPLACE_WITH_YOUR_USERNAME
      LINUX_MCP_LOG_LEVEL: INFO
    timeout: 30
    bundled: null
    available_tools: []
    args: []

# NOTE: dosu remote MCP server configuration for Goose is pending research
# OpenCode users get full dosu + linux-mcp-server support today
# Goose users can set up linux-mcp-server now, dosu support TBD
```

## Skill: bluespeed-onboarding

**Location**: `skills/bluespeed-onboarding/SKILL.md`

**Purpose**: Provide clear instructions for agents to execute the onboarding setup autonomously

**Workflow**:
1. Detect which AI tool the user wants to configure (OpenCode, Goose, or both)
2. Verify prerequisites (brew packages installed)
3. Detect username via `whoami`
4. Backup existing configuration files
5. For OpenCode:
   - Read existing `~/.config/opencode/opencode.json`
   - Merge in dosu and linux-mcp-server MCP configs
   - Prompt before overwriting if existing MCP servers found
   - Write updated config with proper JSON formatting
6. For Goose (future):
   - Read existing `~/.config/goose/config.yaml`
   - Merge in linux-mcp-server extension config
   - Note: dosu support pending research
   - Write updated config with proper YAML formatting
7. Validate configuration syntax (JSON/YAML)
8. Instruct user to restart OpenCode/Goose to apply changes
9. Provide troubleshooting guidance

**Key Behaviors**:
- Ask user for confirmation before modifying configs
- Preserve existing MCP servers/extensions
- Clear error messages if prerequisites missing
- Rollback on failure using backup files

## Agent: bluespeed-onboarding

**Location**: `agents/bluespeed-onboarding/AGENTS.md`

**Purpose**: Instructions for agents executing this skill in context

**Content**:
- How to invoke the skill
- Expected inputs/outputs
- Error handling patterns
- Example invocation
- Success criteria

## Implementation Tasks

### Phase 1: Repository Setup (MVP - OpenCode Focus)
- [ ] Create `/var/home/jorge/src/bluespeed/` directory structure
- [ ] Initialize git repository
- [ ] Create `.gitignore` with `*.local` exclusion
- [ ] Write `README.md` explaining repository purpose
- [ ] Create `configs/README.md` explaining example configs
- [ ] Create `configs/opencode-example.json` with dosu + linux-mcp-server
- [ ] Create `configs/goose-example.yaml` with linux-mcp-server (document dosu as TBD)
- [ ] Create `skills/bluespeed-onboarding/SKILL.md` with OpenCode-focused instructions
- [ ] Create `agents/bluespeed-onboarding/AGENTS.md` with agent execution guide
- [ ] Update `~/.config/opencode/powerlevel/AGENTS.md` with org/repo convention
- [ ] Create powerlevel project config for bluespeed
- [ ] Create GitHub repository: `gh repo create castrojo/bluespeed --public`
- [ ] Initial commit and push to GitHub

### Phase 2: Skill Testing & Validation
- [ ] Test skill with OpenCode agent
- [ ] Validate JSON configuration merging
- [ ] Test backup/rollback functionality
- [ ] Verify username detection with `whoami`
- [ ] Test error handling (missing prerequisites)
- [ ] Validate linux-mcp-server connectivity
- [ ] Validate dosu MCP connectivity

### Phase 3: Documentation & Examples
- [ ] Add screenshots/examples to SKILL.md
- [ ] Document common error scenarios
- [ ] Create troubleshooting guide
- [ ] Document manual setup as alternative
- [ ] Add usage examples to README

### Phase 4: Goose Support (Future Enhancement)
- [ ] Research Goose remote MCP server configuration
- [ ] Update `configs/goose-example.yaml` with dosu config (if supported)
- [ ] Update `skills/bluespeed-onboarding/SKILL.md` with Goose instructions
- [ ] Test Goose skill execution
- [ ] Document Goose-specific setup steps

## Success Criteria

### MVP (Phase 1-3)
- ✅ Repository `castrojo/bluespeed` is public on GitHub
- ✅ OpenCode users can run bluespeed-onboarding skill successfully
- ✅ dosu MCP and linux-mcp-server are configured correctly in OpenCode
- ✅ Username is detected dynamically using `whoami`
- ✅ Existing OpenCode configs are preserved/merged properly
- ✅ Clear documentation exists for manual setup
- ✅ Goose future work is documented with current state (linux-mcp-server only)

### Phase 4 (Future)
- ✅ Goose users can configure linux-mcp-server (already possible via goose-mcp-setup)
- ✅ Research complete on Goose remote MCP server support
- ✅ If supported: Goose users can configure dosu MCP
- ✅ If not supported: Clear documentation of OpenCode vs Goose capabilities

## Key Files to Create

1. **`.gitignore`** - Exclude `*.local` files only
2. **`README.md`** - Repository purpose: "Agents and skills for maintaining Bluefin"
3. **`configs/README.md`** - Explanation of example configurations
4. **`configs/opencode-example.json`** - OpenCode MCP configuration template
5. **`configs/goose-example.yaml`** - Goose extension configuration template (partial, dosu TBD)
6. **`skills/bluespeed-onboarding/SKILL.md`** - Skill instructions for agents
7. **`agents/bluespeed-onboarding/AGENTS.md`** - Agent execution instructions
8. **`~/.config/opencode/powerlevel/AGENTS.md`** - Update with org/repo convention
9. **`~/.config/opencode/powerlevel/projects/bluespeed/config.json`** - Powerlevel project config

## References

### Documentation
- Bluefin AI documentation: `projectbluefin/documentation/docs/ai.md`
- Bluefin agent guidelines: `projectbluefin/documentation/AGENTS.md`
- OpenCode config: `~/.config/opencode/opencode.json`
- Goose config: `~/.config/goose/config.yaml`
- linux-mcp-server: `/home/linuxbrew/.linuxbrew/bin/linux-mcp-server`
- goose-mcp-setup script: Provided by linux-mcp-server brew formula

### Configuration Details
- **Dosu deployment ID**: `83775020-c22e-485a-a222-987b2f5a3823` (public, safe to commit)
- **OpenCode config path**: `~/.config/opencode/opencode.json`
- **Goose config path**: `~/.config/goose/config.yaml`
- **linux-mcp-server path**: `/home/linuxbrew/.linuxbrew/bin/linux-mcp-server`

### Homebrew Packages
- `ublue-os/tap/linux-mcp-server` (v1.3.0) - Provides linux-mcp-server + goose-mcp-setup
- `ublue-os/experimental-tap/opencode-desktop-linux` (v1.1.53) - OpenCode desktop + CLI
- `ublue-os/tap/goose-linux` (v1.23.2) - Goose AI agent desktop app

## Design Principles (from User Feedback)

1. **Keep it simple** - Don't over-engineer the solution
2. **Do as you are told** - Follow exact user instructions, use exact terminology
3. **Follow existing patterns** - Model after powerlevel skills structure
4. **Incremental approach** - OpenCode MVP first, Goose later
5. **Clear scope** - First skill in bluespeed, more will come later
6. **User-controlled** - Always ask before modifying configs
7. **Preserve existing work** - Backup and merge, never replace blindly

## Timeline

**Phase 1 (MVP)**: Current sprint - Repository setup with OpenCode support  
**Phase 2**: Testing and validation  
**Phase 3**: Documentation polish  
**Phase 4**: Future sprint - Goose remote MCP research and implementation

## Notes

- This is the **first skill** in the castrojo/bluespeed repository
- More skills will be added as Bluefin maintenance tasks are identified
- The repository follows the pattern: `org/repo` = `castrojo/bluespeed`
- Powerlevel documentation will be updated to explain this convention
- AI agent attribution required in commits: `Assisted-by: [Model] via [Tool]`

## Open Questions

1. ✅ **Goose + dosu integration**: Remote MCP server support unclear - documented as future work
2. ✅ **Username detection**: Use `whoami` command
3. ✅ **Repository visibility**: Public
4. ✅ **MVP approach**: OpenCode first, Goose later

## Related Work

- **Powerlevel skills**: `~/.config/opencode/skills/powerlevel/` - Pattern to follow
- **Bluefin AGENTS.md**: Commit attribution and AI agent guidelines
- **ublue-os brew taps**: Source of MCP server packages for Bluefin users

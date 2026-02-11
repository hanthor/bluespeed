# bluespeed-onboarding Implementation Plan

> **Epic Issue:** https://github.com/castrojo/bluespeed/issues/1
> **Sub-Tasks:** TBD (creating next)

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create the bluespeed-onboarding skill and agent to automate setup of dosu MCP and linux-mcp-server for Bluefin maintainers using OpenCode.

**Architecture:** Skill-based automation system that detects user's AI tool (OpenCode/Goose), verifies prerequisites, and merges MCP server configurations into existing config files. MVP focuses on OpenCode with full dosu + linux-mcp-server support. Goose support planned as Phase 4 enhancement.

**Tech Stack:** Bash scripts, JSON/YAML configuration manipulation, OpenCode skills system, MCP server integration

## Task 1: Repository Initialization

**Files:**
- `/var/home/jorge/src/bluespeed/.gitignore`
- `/var/home/jorge/src/bluespeed/README.md`
- `/var/home/jorge/src/bluespeed/AGENTS.md`

**Steps:**
1. Initialize git repository in `/var/home/jorge/src/bluespeed` ✅ DONE
2. Create `.gitignore` excluding `*.local` files only
3. Write `README.md` with repository purpose: "Agents and skills for maintaining Project Bluefin"
4. Write `AGENTS.md` documenting repository structure and Bash script organization
5. Create initial directory structure following AGENTS.md pattern:
   - `skills/bluespeed-onboarding/scripts/lib/` (for organized Bash scripts)
   - `configs/` (for configuration examples)
6. Commit repository structure with clear documentation

## Task 2: Configuration Examples

**Files:**
- `/var/home/jorge/src/bluespeed/configs/README.md`
- `/var/home/jorge/src/bluespeed/configs/opencode-example.json`
- `/var/home/jorge/src/bluespeed/configs/goose-example.yaml`

**Steps:**
1. Create `configs/README.md` explaining example configurations
2. Create `opencode-example.json` with:
   - dosu remote MCP server (deployment ID: 83775020-c22e-485a-a222-987b2f5a3823)
   - linux-mcp-server local MCP (command: /home/linuxbrew/.linuxbrew/bin/linux-mcp-server)
   - LINUX_MCP_USER placeholder: REPLACE_WITH_YOUR_USERNAME
3. Create `goose-example.yaml` with:
   - linux-mcp-server extension (stdio type)
   - LINUX_MCP_USER placeholder: REPLACE_WITH_YOUR_USERNAME
   - Document dosu support as TBD (pending Goose remote MCP research)
4. Document prerequisite brew packages:
   - `ublue-os/tap/linux-mcp-server`
   - `ublue-os/experimental-tap/opencode-desktop-linux`
   - `ublue-os/tap/goose-linux`

## Task 3: Bash Library Functions

**Files:**
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/scripts/lib/common.sh`
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/scripts/lib/config.sh`
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/scripts/lib/validation.sh`

**Steps:**
1. Create `lib/common.sh` with utility functions:
   - `log_info()`, `log_error()`, `log_success()` - Formatted output
   - `get_username()` - Uses `whoami` to detect current user
   - `backup_file()` - Creates timestamped backups
   - `cleanup_on_error()` - Restore backups on failure
2. Create `lib/config.sh` with configuration functions:
   - `merge_json_config()` - Uses jq to merge MCP servers into OpenCode config
   - `merge_yaml_config()` - Uses yq to merge extensions into Goose config
   - `validate_json()` - Check JSON syntax
   - `validate_yaml()` - Check YAML syntax
   - `create_default_config()` - Generate config if none exists
3. Create `lib/validation.sh` with prerequisite checks:
   - `check_brew_package()` - Verify package is installed
   - `check_file_exists()` - Verify file/directory existence
   - `check_command_exists()` - Verify tool is available (jq, yq)
   - `validate_prerequisites()` - Run all prerequisite checks

## Task 4: Bash Setup Scripts

**Files:**
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/scripts/setup-opencode.sh`
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/scripts/setup-goose.sh`
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/scripts/bluespeed-onboarding.sh`

**Steps:**
1. Create `setup-opencode.sh`:
   - Source library functions from `lib/`
   - Validate OpenCode package installed
   - Detect username via `get_username()`
   - Backup existing `~/.config/opencode/opencode.json`
   - Merge dosu and linux-mcp-server MCP configs
   - Validate JSON syntax
   - Print success message with restart instructions
2. Create `setup-goose.sh` (future Phase 4):
   - Source library functions from `lib/`
   - Validate Goose package installed
   - Detect username via `get_username()`
   - Backup existing `~/.config/goose/config.yaml`
   - Merge linux-mcp-server extension config
   - Note: dosu remote MCP support pending research
   - Validate YAML syntax
   - Print success message with restart instructions
3. Create `bluespeed-onboarding.sh` main entry point:
   - Source library functions from `lib/`
   - Ask user which tool to configure (OpenCode/Goose/Both)
   - Validate all prerequisites before starting
   - Call appropriate setup scripts
   - Handle errors gracefully with rollback

## Task 5: Skill Documentation

**Files:**
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/SKILL.md`
- `/var/home/jorge/src/bluespeed/skills/bluespeed-onboarding/AGENTS.md`

**Steps:**
1. Create `SKILL.md` with frontmatter and user instructions:
   ```yaml
   ---
   name: bluespeed-onboarding
   description: Setup dosu MCP and linux-mcp-server for Bluefin maintainers
   ---
   ```
2. Document skill overview and "When to Use" section
3. Document workflow steps (reference Bash scripts)
4. Add prerequisites section (brew packages)
5. Add error handling and troubleshooting guidance
6. Create `AGENTS.MD` with agent-specific notes:
   - How agents should invoke scripts
   - Expected script outputs
   - Success criteria verification
   - Example agent invocation pattern

## Task 6: GitHub Repository Publishing

**Files:**
- Remote: `castrojo/bluespeed` on GitHub ✅ DONE

**Steps:**
1. Ensure all files are committed locally ✅ DONE
2. Create GitHub repository: `gh repo create castrojo/bluespeed --public` ✅ DONE
3. Push initial commit: `git push -u origin main` ✅ DONE
4. Create labels: `type/epic`, `type/task` ✅ DONE
5. Create Epic #1 for bluespeed-onboarding ✅ DONE
6. Create sub-task issues for Tasks 1-6
7. Update epic with sub-task issue numbers

## Task 7: Powerlevel Integration Documentation

**Files:**
- `/var/home/jorge/.config/opencode/powerlevel/AGENTS.md` ✅ UPDATED
- `/var/home/jorge/.config/opencode/powerlevel/projects/bluespeed/config.json` ✅ CREATED

**Steps:**
1. Verify powerlevel project config exists for bluespeed ✅ DONE
2. Update powerlevel AGENTS.md with mandatory workflow section ✅ DONE
3. Document where work happens for external projects ✅ DONE
4. Add clarification that agents MUST follow the workflow ✅ DONE
5. Commit powerlevel changes with clear documentation ✅ DONE

## Implementation Notes

### MVP Scope (Phases 1-3)
- **OpenCode full support**: dosu + linux-mcp-server configuration
- **Goose partial support**: linux-mcp-server only (dosu TBD)
- **Manual setup documentation**: As fallback option
- **Username detection**: Via `whoami` command
- **Config merging**: Preserve existing MCP servers/extensions
- **Validation**: JSON/YAML syntax checking

### Phase 4 (Future Enhancement)
- **Goose dosu integration**: Research remote MCP server configuration
- **Update goose-example.yaml**: Add dosu if supported
- **Update SKILL.md**: Add Goose dosu instructions
- **Test with Goose**: Validate skill execution in Goose

### Key Technical Decisions
1. **Username detection**: `whoami` command (dynamic, portable)
2. **Repository visibility**: Public (aligns with Bluefin open source philosophy)
3. **MVP approach**: OpenCode first, Goose incrementally
4. **Deployment ID**: Public and safe to commit (83775020-c22e-485a-a222-987b2f5a3823)
5. **Config strategy**: Merge, don't replace (preserve existing work)

### Prerequisites
Users must install these brew packages before running skill:
- `brew install ublue-os/tap/linux-mcp-server`
- `brew install --cask ublue-os/experimental-tap/opencode-desktop-linux`
- `brew install --cask ublue-os/tap/goose-linux` (optional)

### Configuration Paths
- **OpenCode**: `~/.config/opencode/opencode.json`
- **Goose**: `~/.config/goose/config.yaml`
- **linux-mcp-server**: `/home/linuxbrew/.linuxbrew/bin/linux-mcp-server`

### Dosu Deployment Details
- **Deployment ID**: `83775020-c22e-485a-a222-987b2f5a3823`
- **API Endpoint**: `https://api.dosu.dev/v1/mcp`
- **Type**: Remote MCP server
- **Authentication**: Via `X-Deployment-ID` header (public, not secret)

### Success Criteria
- ✅ Repository `castrojo/bluespeed` is public on GitHub
- ✅ OpenCode users can configure dosu + linux-mcp-server
- ✅ Goose users can configure linux-mcp-server (dosu documented as TBD)
- ✅ Username detected dynamically via `whoami`
- ✅ Existing configs preserved and merged
- ✅ Clear documentation for manual setup
- ✅ Powerlevel tracking configured
- ✅ org/repo convention documented in powerlevel

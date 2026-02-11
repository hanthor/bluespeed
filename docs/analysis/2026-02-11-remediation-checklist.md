# Epic #1 Remediation Checklist

**Status:** Ready for Implementation  
**Based on:** docs/analysis/2026-02-11-epic-1-review.md  
**Estimated Total Effort:** 12-16 hours

---

## Phase 1: CRITICAL (Must Fix Before Use) - 4-6 hours

### ☐ 1. Add LICENSE File (5 minutes)

**Decision needed:** Apache 2.0 or MIT?
- Scripts have Apache 2.0 headers
- README says MIT License
- Recommend: **Apache 2.0** (matches existing headers)

**Tasks:**
- [ ] Create `LICENSE` file in root with Apache 2.0 text
- [ ] Update README.md line 87 to say "Apache 2.0"
- [ ] Commit: `fix: add Apache 2.0 LICENSE file and correct README`

**Files to modify:**
- Create: `/LICENSE`
- Edit: `/README.md` (line 87)

---

### ☐ 2. End-to-End Testing (2-4 hours)

**Goal:** Prove the skill actually works

**Setup:**
- [ ] Fresh VM or clean test environment
- [ ] Remove existing OpenCode/Goose configs (backup first)
- [ ] Have Homebrew installed

**Test Procedure:**
- [ ] Start OpenCode or Goose session
- [ ] Say: "Onboard me to projectbluefin/bluespeed"
- [ ] Observe: Does agent read SKILL.md from GitHub?
- [ ] Observe: Does agent execute inline commands correctly?
- [ ] Verify: Prerequisites auto-installed (jq, yq, linux-mcp-server)
- [ ] Verify: OpenCode config has dosu + linux-mcp-server
- [ ] Verify: Goose config has linux-mcp-server
- [ ] Verify: Username detected correctly
- [ ] Test: Restart OpenCode/Goose
- [ ] Test: Check MCP servers load correctly
- [ ] Test: Ask "Can you check my system information?" (uses linux-mcp-server)

**Documentation:**
- [ ] Create `docs/testing/2026-02-11-e2e-test-results.md`
- [ ] Include: Full output log
- [ ] Include: Screenshots of MCP server panel
- [ ] Include: Any issues discovered
- [ ] Include: Environment details (OS, tool versions)

**If test fails:**
- [ ] Document failure mode
- [ ] Fix issues discovered
- [ ] Re-test until passing
- [ ] Update SKILL.md if needed

---

### ☐ 3. Resolve Auto-Installation Contradiction (1-2 hours)

**Current state:**
- SKILL.md: Auto-installs missing packages ✓
- Bash scripts: Only validate, don't install ✗

**Decision:** Update bash scripts to match SKILL.md (auto-install)

**Tasks:**
- [ ] Edit `skills/bluespeed-onboarding/scripts/lib/validation.sh`
- [ ] Change `validate_prerequisites()` to auto-install jq, yq
- [ ] Change `validate_opencode_prerequisites()` to auto-install linux-mcp-server
- [ ] Change `validate_goose_prerequisites()` to auto-install linux-mcp-server
- [ ] Test bash scripts manually:
  - [ ] Uninstall jq, run script, verify auto-install
  - [ ] Uninstall yq, run script, verify auto-install
  - [ ] Uninstall linux-mcp-server, run script, verify auto-install
- [ ] Commit: `fix: implement auto-installation in bash scripts to match SKILL.md`

**Alternative:** If auto-install is undesirable, update SKILL.md to only validate

---

## Phase 2: HIGH PRIORITY (Soon) - 6-8 hours

### ☐ 4. Create Sub-Task Issues Retroactively (1 hour)

**Goal:** Establish proper tracking history

**Tasks:**
- [ ] Create Issue #2: "Task 1: Repository Initialization"
  - Body: "Create .gitignore, README.md, AGENTS.md, directory structure"
  - Commits: a329346, c9d9b22, 7ef73cb, a329346
  - Labels: type/task, epic/1
  - Close immediately with "Completed retroactively"
- [ ] Create Issue #3: "Task 2: Configuration Examples"
  - Commits: 3113b8a (configs/)
  - Labels: type/task, epic/1
- [ ] Create Issue #4: "Task 3: Bash Library Functions"
  - Commits: 3113b8a (lib/)
  - Labels: type/task, epic/1
- [ ] Create Issue #5: "Task 4: Bash Setup Scripts"
  - Commits: 3113b8a, a54f0c2
  - Labels: type/task, epic/1
- [ ] Create Issue #6: "Task 5: Skill Documentation"
  - Commits: 3113b8a (SKILL.md, AGENTS.md)
  - Labels: type/task, epic/1
- [ ] Create Issue #7: "Task 6: GitHub Repository Publishing"
  - Note: Repo already public
  - Labels: type/task, epic/1
- [ ] Create Issue #8: "Task 7: Powerlevel Integration Documentation"
  - Note: Already done
  - Labels: type/task, epic/1
- [ ] Update Epic #1 body with sub-task checkboxes
- [ ] Commit documentation: `docs: retroactively create sub-task issues for Epic #1 tracking`

**Commands:**
```bash
gh issue create --title "Task 1: Repository Initialization" \
  --body "Create repository structure\n\nCompleted in commits: a329346, c9d9b22, 7ef73cb" \
  --label "type/task,epic/1"
gh issue close 2 --reason "completed" --comment "Completed retroactively as part of Epic #1"
# Repeat for issues 3-8
```

---

### ☐ 5. Add Smoke Tests (3-4 hours)

**Goal:** Prevent regressions, prove functionality

**Setup:**
- [ ] Create `tests/` directory
- [ ] Create `tests/README.md` explaining test structure

**Test Scripts:**

**File: `tests/test-configs.sh`**
- [ ] Validate JSON syntax: `jq empty configs/opencode-example.json`
- [ ] Validate YAML syntax: `yq eval '.' configs/goose-example.yaml`
- [ ] Check placeholder present: `REPLACE_WITH_YOUR_USERNAME`
- [ ] Test jq commands from SKILL.md (dry-run mode)
- [ ] Exit 0 if all pass, 1 if any fail

**File: `tests/test-scripts.sh`**
- [ ] Check all scripts executable: `[[ -x path/to/script ]]`
- [ ] Test library sourcing (no errors)
- [ ] Validate function definitions exist
- [ ] Check --help flags work
- [ ] Test backup_file() function (create temp file, backup, verify)
- [ ] Test get_username() function

**File: `tests/test-skill.sh`**
- [ ] Parse all bash commands in SKILL.md
- [ ] Verify commands are syntactically valid
- [ ] Check all file paths are correct
- [ ] Verify jq/yq commands are valid

**CI Integration:**
- [ ] Create `.github/workflows/test.yml`
- [ ] Run all tests on push to main
- [ ] Run all tests on pull requests
- [ ] Fail workflow if any test fails

**Tasks:**
- [ ] Write test scripts
- [ ] Make scripts executable: `chmod +x tests/*.sh`
- [ ] Run locally and verify all pass
- [ ] Create GitHub Actions workflow
- [ ] Push and verify CI runs
- [ ] Commit: `test: add smoke tests for configs, scripts, and skill`

---

### ☐ 6. Improve Error Handling (2-3 hours)

**Goal:** Production-grade reliability

**Changes Needed:**

**A. Transaction-like Config Merging (SKILL.md)**
- [ ] Create temp config file
- [ ] Apply both dosu and linux-mcp-server changes to temp
- [ ] Validate temp file
- [ ] If valid: Move temp to real config
- [ ] If invalid: Remove temp, restore backup
- [ ] Update SKILL.md steps 7-9 with new approach

**B. Username Validation (SKILL.md and bash scripts)**
- [ ] After `USERNAME=$(whoami)`, add:
  ```bash
  if [[ -z "$USERNAME" ]]; then
      echo "ERROR: Could not detect username"
      exit 1
  fi
  ```
- [ ] Update both SKILL.md and bash scripts

**C. Better Error Messages**
- [ ] Each error should include:
  - What went wrong
  - Why it matters
  - How to fix it
  - Command to check status
- [ ] Update validation.sh error messages

**D. Handle Malformed Existing Configs**
- [ ] Before merging, validate existing config
- [ ] If invalid JSON/YAML, offer to backup and recreate
- [ ] Don't assume existing config is well-formed

**Testing:**
- [ ] Test with missing config (create default)
- [ ] Test with malformed JSON (detect and handle)
- [ ] Test with partial config (merge correctly)
- [ ] Test with duplicate MCP server (skip correctly)
- [ ] Test with failed merge (rollback correctly)

**Tasks:**
- [ ] Update SKILL.md with improved error handling
- [ ] Update bash scripts with improved error handling
- [ ] Test all error paths
- [ ] Commit: `fix: improve error handling with transaction-like merging and validation`

---

### ☐ 7. Document Actual Usage (2-3 hours)

**Goal:** Users see it working

**Tasks:**

**A. Record Real Session**
- [ ] Screen recording or detailed log
- [ ] Start to finish: invocation → restart → verification
- [ ] Include timestamps

**B. Update README.md**
- [ ] Add "Example Usage" section
- [ ] Show user invocation: "Onboard me to projectbluefin/bluespeed"
- [ ] Show expected agent responses
- [ ] Show sample output at key steps
- [ ] Include success indicators

**C. Create Troubleshooting Guide**
- [ ] Create `docs/troubleshooting.md`
- [ ] Common errors:
  - "Homebrew not found" → Install from brew.sh
  - "MCP server not loading" → Check config, check logs
  - "Permission denied" → File permissions issue
  - "Command not found" → Path issue
- [ ] Each error includes:
  - Symptom
  - Cause
  - Solution
  - Verification command

**D. Add FAQ Section**
- [ ] "How do I know if it worked?"
- [ ] "What if I already have MCP servers configured?"
- [ ] "Can I run this multiple times?"
- [ ] "How do I uninstall?"
- [ ] "What if I'm using a different username?"

**Tasks:**
- [ ] Record usage session
- [ ] Write documentation
- [ ] Add to README and docs/
- [ ] Commit: `docs: add example usage, troubleshooting guide, and FAQ`

---

## Phase 3: NICE TO HAVE (Future) - Optional

### ☐ 8. Establish PR Workflow (1 hour)

**Goal:** Prevent future issues

**Tasks:**
- [ ] Protect main branch in GitHub settings
- [ ] Require PRs for all changes
- [ ] Require 1 approval (can be self-review for solo project)
- [ ] Create `.github/PULL_REQUEST_TEMPLATE.md`
  - [ ] Checklist: Tests pass, docs updated, reviewed
  - [ ] Link to related issue
  - [ ] Description of changes
- [ ] Document PR workflow in CONTRIBUTING.md
- [ ] Commit: `chore: establish PR workflow and protection`

---

### ☐ 9. Improve Duplicate Detection (2-3 hours)

**Goal:** Fix broken configs, not just skip them

**Changes:**
- [ ] Check if config **value** is correct, not just if key exists
- [ ] Compare existing dosu deployment ID with expected
- [ ] Compare existing linux-mcp-server path with expected
- [ ] If incorrect: Prompt "Existing config is incorrect. Update? [y/n]"
- [ ] Update both SKILL.md and bash scripts
- [ ] Test: Create incorrect config, verify detection and fix

**Tasks:**
- [ ] Implement smart duplicate detection
- [ ] Test various scenarios
- [ ] Commit: `feat: improve duplicate detection to validate and fix incorrect configs`

---

### ☐ 10. Phase 4: Goose dosu Support (4-8 hours)

**Goal:** Bring Goose to parity with OpenCode

**Research Phase:**
- [ ] Check Goose documentation for remote MCP server support
- [ ] Test dosu MCP with Goose (if supported)
- [ ] Document findings in `docs/research/goose-remote-mcp.md`

**Implementation Phase (if supported):**
- [ ] Update `configs/goose-example.yaml` with dosu config
- [ ] Update `skills/bluespeed-onboarding/SKILL.md` with Goose dosu steps
- [ ] Update `scripts/setup-goose.sh` to merge dosu config
- [ ] Test end-to-end with Goose
- [ ] Update documentation

**Alternative (if not supported):**
- [ ] Document why it's not supported
- [ ] Create feature request with Goose project
- [ ] Document workarounds if any

**Tasks:**
- [ ] Complete research
- [ ] Implement or document blockers
- [ ] Commit: `feat: add Goose dosu MCP support` or `docs: document Goose dosu MCP limitations`

---

## Final Steps: Close Epic #1 Properly

### ☐ Verification Complete

**Before closing Epic #1:**
- [ ] All Phase 1 (CRITICAL) items complete
- [ ] All Phase 2 (HIGH) items complete or documented as future work
- [ ] LICENSE file exists
- [ ] Tests exist and pass
- [ ] End-to-end test documented with evidence
- [ ] Sub-tasks created and linked
- [ ] No contradictions remain

### ☐ Update Epic #1

**Tasks:**
- [ ] Update Epic #1 body with:
  - Links to all sub-task issues (#2-#8)
  - Link to test results
  - Link to this review document
  - Known limitations
  - Phase 4 TODO items
- [ ] Add closing comment with:
  - Verification evidence (link to test results)
  - Summary of changes since original close
  - Confirmation of license
  - List of tests passing

### ☐ Close Epic #1 (Again, Properly)

**Command:**
```bash
gh issue comment 1 --body "$(cat docs/analysis/verification-complete.md)"
gh issue close 1 --reason "completed"
```

**Closing comment should include:**
- ✅ LICENSE file added (Apache 2.0)
- ✅ End-to-end testing completed with evidence
- ✅ Auto-installation contradiction resolved
- ✅ Sub-task issues created (#2-#8)
- ✅ Smoke tests added and passing
- ✅ Error handling improved
- ✅ Documentation complete with examples
- 📋 Phase 4 TODO: Goose dosu support research

---

## Quick Reference

**Current Status:** Epic #1 closed prematurely  
**Next Action:** Start with Phase 1, Item 1 (LICENSE file)  
**Success Metric:** Can confidently say "bluespeed-onboarding skill works"  

**Priority Order:**
1. LICENSE (5 min) - Legal compliance
2. E2E Testing (2-4h) - Prove it works
3. Auto-install (1-2h) - Architecture compliance
4. Sub-tasks (1h) - Tracking
5. Smoke tests (3-4h) - Prevent regressions
6. Error handling (2-3h) - Reliability
7. Documentation (2-3h) - Usability

**Total Estimated Time:** 12-16 hours for Phases 1-2

---

**Document:** `docs/analysis/2026-02-11-remediation-checklist.md`  
**Companion:** `docs/analysis/2026-02-11-epic-1-review.md`  
**Created:** February 11, 2026

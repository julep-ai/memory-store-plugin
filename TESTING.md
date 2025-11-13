# Memory Store Plugin - Testing Guide

## Current Status
- Plugin: `memory-store@claude-plugin`
- MCP Server: ✓ Connected to beta.memory.store
- Commands: Using `/memory-*` prefix (keeping this naming)
- Structure: Single-channel (before beta/local split)

## Test 1: Installation & Connection

### 1.1 Fresh Install
```bash
# Uninstall current
/plugin uninstall memory-store

# Reinstall
/plugin marketplace add julep-ai/memory-store-plugin
/plugin install memory-store@claude-plugin
```

**Expected:** Plugin installs successfully

### 1.2 MCP Connection
```bash
claude mcp list
```

**Expected:**
```
plugin:memory-store:memory: npx -y mcp-remote https://beta.memory.store/mcp - ✓ Connected
memory-store: https://beta.memory.store/mcp (HTTP) - ✓ Connected
```

### 1.3 Verify Commands Available
```bash
ls ~/.claude/plugins/marketplaces/claude-plugin/commands/
```

**Expected:** Should see all `/memory-*` commands

---

## Test 2: Commands Functionality

### 2.1 Memory Status
```
Create a test file
```

Then check:
```
# This won't work as slash command yet, but hooks should track
# Check files: ls -la .claude-*
```

**Expected:** `.claude-session-changes-count` increments

### 2.2 Memory Context Retrieval
Test if memory recall works:
```
Ask Claude: "What have we discussed about plugin architecture today?"
```

**Expected:** Should recall our beta/local channel discussion

### 2.3 Checkpoint
```
Make 5-10 file changes, then ask:
"Have we made progress on the plugin restructuring?"
```

**Expected:** Should trigger checkpoint validation (every 10 changes)

### 2.4 Correct Command
```
Tell Claude something wrong, then:
"Actually, we're keeping /memory-* commands, not changing to /mem-*"
```

**Expected:** High-priority correction stored

---

## Test 3: Hooks Firing

### 3.1 Session Start Hook
```bash
# Exit Claude Code
exit

# Restart in this directory
cd /Users/a3fckx/Desktop/autotelic/mem-plugin
claude
```

**Expected:**
- Session ID created in `.claude-memory-session`
- `session-start.sh` captures project state
- Git info, file count captured

**Verify:**
```bash
cat .claude-memory-session
# Should show: mem-2025-11-13-XXXXXX
```

### 3.2 File Change Tracking Hook
```
Create a new test file:
echo "test" > test-file.ts

Check tracking:
cat .claude-memory-changes.jsonl | tail -1
```

**Expected:** JSON entry with file path and language detection

### 3.3 Git Commit Hook
```bash
git add test-file.ts
git commit -m "test: verify commit tracking"
```

**Expected:**
- `analyze-commits.sh` fires
- Commit message analyzed (type: test)
- Pattern stored in memory

**Verify:**
```bash
# Check if commit was recorded
# (Look for background process logs)
```

### 3.4 Session End Hook
```bash
# Exit Claude Code gracefully
<Ctrl+D>
```

**Expected:**
- `session-end.sh` fires
- Session summary created
- Stats stored: files changed, commits made
- `.claude-memory-session-end.json` created

**Verify:**
```bash
cat .claude-memory-session-end.json
# Should show session summary
```

---

## Test 4: Skills Proactive Activation

### 4.1 Memory Auto-Track Skill
Start a conversation and ask:
```
"I need to add authentication to the API"
```

**Expected:** Skill should AUTOMATICALLY:
- Recall past discussions about OAuth2
- Mention established patterns (if any)
- Suggest following conventions
- All WITHOUT being explicitly asked

### 4.2 Context Retrieval During Work
While working, ask:
```
"What's our approach to error handling?"
```

**Expected:**
- Skill activates automatically
- Retrieves relevant context from memory
- Surfaces past decisions and patterns

---

## Test 5: Automatic Feedback Capture

### 5.1 Error Detection
Tell Claude something incorrect:
```
"Use MongoDB for the database"

Then correct:
"No, that's wrong. We use PostgreSQL for ACID compliance."
```

**Expected:**
- Notification hook fires (matches "wrong")
- `auto-feedback.sh` captures the correction
- High-priority memory stored
- Async, non-blocking

**Verify:**
```bash
# Check if feedback was captured
# (Memory Store should have the correction)
```

### 5.2 Quality Monitoring
Make 10+ file changes with some intentional errors:
```
Create files with mistakes, then correct them
```

**Expected:**
- Quality score calculated
- Session feedback tracked
- Pattern of corrections detected

---

## Test 6: Memory Persistence Across Sessions

### 6.1 End Current Session
```bash
exit
```

### 6.2 Start New Session (Next Day Simulation)
```bash
claude
```

### 6.3 Test Recall
Ask Claude:
```
"What did we discuss yesterday about plugin architecture?"
```

**Expected:**
- Should recall beta/local channel decisions
- Remember keeping /memory-* naming
- Retrieve architectural discussions
- Demonstrate persistent learning

---

## Test 7: CLAUDE.md Synchronization

### 7.1 Create CLAUDE.md with Anchor
```markdown
Create file: CLAUDE.md

<!-- AUTH-FLOW -->
## Authentication Flow
We use OAuth2 password flow for all authentication.
```

### 7.2 Reference Anchor in Code
```typescript
Create file: src/auth.ts

// See <!-- AUTH-FLOW --> in CLAUDE.md
export function authenticate() {
  // OAuth2 implementation
}
```

**Expected:**
- Anchor relationship tracked
- Cross-references stored in memory
- Available for context retrieval

---

## Test 8: Pre-commit Validation

### 8.1 Add Sensitive Data
```bash
# Create file with potential secret
echo "API_KEY=sk-test-123456" > .env.test

git add .env.test
```

**Expected:**
- `validate-commit.sh` fires on `git add`
- Security check detects potential secret
- Warning displayed (if configured)

---

## Success Criteria

✅ **Installation**
- Plugin installs without errors
- MCP connection established
- Commands available

✅ **Hooks**
- SessionStart captures project state
- File changes tracked automatically
- Git commits analyzed
- SessionEnd creates summary

✅ **Commands**
- All /memory-* commands accessible
- Context retrieval works
- Feedback capture functions

✅ **Skills**
- Proactively provide context
- No explicit invocation needed
- Enhance conversation naturally

✅ **Persistence**
- Memory survives session restarts
- Context available across days
- Learning accumulates over time

✅ **Reliability**
- All operations non-blocking (async)
- No workflow interruptions
- Background processing works

---

## Debug Commands

If tests fail, use these to debug:

```bash
# Check plugin installation
ls -la ~/.claude/plugins/marketplaces/claude-plugin/

# Verify hooks configuration
cat hooks/hooks.json | jq .

# Check scripts are executable
ls -l scripts/*.sh

# Test MCP connection
claude mcp list

# View session tracking files
ls -la .claude-*

# Check logs (if available)
claude --debug

# Test script manually
bash scripts/session-start.sh

# Verify marketplace config
cat .claude-plugin/marketplace.json | jq .
```

---

## Next Steps After Testing

Once all tests pass:

1. **Document Issues** - Note any failures or unexpected behavior
2. **Fix Bugs** - Address issues found during testing
3. **Consider Restructuring** - If tests pass, evaluate beta/local split
4. **Add New Features** - Anchor tracking, ownership mapping, etc.
5. **Version Bump** - Update to v1.2.0 after testing complete

---

## Notes

- Current version: 1.1.0
- Testing as single-channel before restructuring
- Keeping /memory-* command naming
- OAuth authentication (no manual tokens)
- Beta environment: beta.memory.store

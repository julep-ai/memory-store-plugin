# Testing Guide: Memory Store Plugin v1.2.0

## Test 1: Marketplace Installation

### Step 1: Uninstall Old Version
```bash
/plugin uninstall memory-store
```

Expected: Plugin removed successfully

### Step 2: Update Marketplace
```bash
/plugin marketplace update claude-plugin
```

Expected: Latest commits pulled from GitHub

### Step 3: Install New Version
```bash
/plugin install memory-store@claude-plugin
```

Expected: v1.2.0 installed with OAuth configuration

### Step 4: Verify Installation
```bash
/plugin list
```

Expected: Shows `memory-store@claude-plugin` as enabled

## Test 2: OAuth Connection

### Check MCP Server Status
```bash
claude mcp list
```

Expected: `memory-store: https://beta.memory.store/mcp (HTTP) - ✓ Connected`

If not connected, authenticate:
```bash
claude mcp add --transport http memory-store "https://beta.memory.store/mcp"
```

Browser will open for OAuth authentication.

## Test 3: Hook Execution (Storage)

### Create a Test File
In Claude session:
```
You: "Create a file test-oauth-flow.ts with a simple function"
```

**What should happen:**
1. PostToolUse hook fires
2. track-changes.sh outputs JSON with `additionalContext`
3. Memory Auto-Track Skill activates
4. Invokes `mcp__memory__record`
5. File creation stored in memory

### Create 10 Files (Checkpoint Test)
```
You: "Create 10 test files named test-1.ts through test-10.ts"
```

**Expected output after 10th file:**
```
✓ Checkpoint: 10 files tracked
```

### Make a Commit
```
You: "Commit these test files with message 'test: verify OAuth flow'"
```

**What should happen:**
1. PostToolUse hook fires for git commit
2. analyze-commits.sh outputs commit details
3. Memory Auto-Track Skill stores commit
4. Commit info available for future recall

## Test 4: Memory Retrieval (Context)

### Test Proactive Recall
```
You: "How should I create a TypeScript file in this project?"
```

**Expected behavior:**
- Skill should invoke `mcp__memory__recall`
- Searches for ["TypeScript", "file", "create", "patterns"]
- Retrieves past TypeScript file patterns
- Claude responds based on established patterns
- Mentions: "Based on our previous TypeScript files..."

### Test Explicit Recall
```
You: "What files have we created in this session?"
```

**Expected:**
- Skill retrieves memories from current session
- Lists test files created
- Shows patterns detected

## Test 5: Session Lifecycle

### Session End
Exit Claude Code normally.

**What should happen:**
1. SessionEnd hook fires
2. session-end.sh calculates duration, counts
3. Outputs: "✓ Session complete! Tracked X files and Y commits in Zm"
4. Session summary stored in memory

### Session Start (Next Session)
Start Claude Code again in same project.

**What should happen:**
1. SessionStart hook fires
2. Session context prepared
3. (Optional) Skill retrieves recent project context
4. Claude has awareness of past session

## Test 6: Bidirectional Flow (Critical!)

This test verifies the complete cycle:

### Part A: Store Pattern
```
You: "Create an API endpoint file called users-api.ts"
```

Expected: File created, pattern stored as "API endpoint"

### Part B: Retrieve Pattern (Same Session)
```
You: "Now create another API endpoint for products"
```

**Expected behavior:**
- Before implementing, skill invokes `mcp__memory__recall`
- Searches for ["API endpoint", "patterns", "users-api"]
- Retrieves the users-api.ts pattern
- Claude says: "Following the API pattern from users-api.ts..."
- Implements products-api.ts with same structure

### Part C: Retrieve Pattern (Different Session)
Exit and restart Claude Code, then:
```
You: "Create an API endpoint for orders"
```

**Expected:**
- Skill retrieves past API endpoint patterns
- Claude maintains consistency across sessions!
- References previous work: "Like users-api.ts and products-api.ts..."

## Test 7: Preventing Off-Track Behavior

### Scenario: Testing Consistency Enforcement

```
You: "I want to use MongoDB for storing user data"
```

**Expected behavior (if PostgreSQL was used before):**
- Skill invokes memory__recall for database decisions
- Retrieves: "Decision: Use PostgreSQL (2024-11-13)"
- Claude responds: "I notice we've been using PostgreSQL. To maintain consistency, I recommend continuing with PostgreSQL unless there's a specific reason to change..."

## Verification Checklist

After all tests:

- [ ] Plugin installs via `/plugin install memory-store@claude-plugin`
- [ ] OAuth authentication works
- [ ] MCP connection shows ✓ Connected
- [ ] Hooks fire and output correct JSON
- [ ] Memory Auto-Track Skill stores memories
- [ ] Memory Auto-Track Skill retrieves context
- [ ] Checkpoint messages appear every 10 files
- [ ] Session summaries show on exit
- [ ] Context persists across sessions
- [ ] Claude references past patterns
- [ ] Consistency maintained (no going off track)

## Success Criteria

✅ **Storage working**: Memories stored in memory.store database
✅ **Retrieval working**: Claude uses past context proactively
✅ **Bidirectional flow**: Complete cycle from store → retrieve → use
✅ **User visibility**: Checkpoint messages and session summaries visible
✅ **OAuth secure**: No manual token management needed

## Troubleshooting

### Plugin Not Installing
```bash
# Check marketplace
/plugin marketplace list

# Update marketplace
/plugin marketplace update claude-plugin

# Try again
/plugin install memory-store@claude-plugin
```

### MCP Not Connected
```bash
claude mcp list
claude mcp remove memory-store
claude mcp add --transport http memory-store "https://beta.memory.store/mcp"
```

### Hooks Not Firing
```bash
# Check plugin enabled
/plugin list

# Check hooks registered
# Hooks are auto-discovered from hooks/hooks.json

# Test manually
cd /path/to/mem-plugin
bash scripts/track-changes.sh "test.ts"
```

### Memory Not Storing
1. Verify MCP connection: `claude mcp list`
2. Check skill is present: `ls skills/memory-auto-track/`
3. Ensure hooks output additionalContext
4. Test manual storage (describe test in chat)

### Memory Not Retrieving
1. Ask explicit question about past work
2. Check if memories exist (ask Claude to search)
3. Verify skill has retrieval examples
4. Test with simple query first

## Expected Output Examples

### Successful Storage
```
[Hook runs silently in background]
[After 10 files:] ✓ Checkpoint: 10 files tracked
```

### Successful Retrieval
```
You: "How did we implement the API?"

Claude: "Based on our previous work, we implemented RESTful APIs
following the pattern in users-api.ts:23. The structure includes..."
```

### Session Summary
```
[On exit]
✓ Session complete! Tracked 15 files and 3 commits in 42m
```

---

## Next Steps After Testing

Once all tests pass:

1. **Push to GitHub** (if not already done)
2. **Create Release Tag** v1.2.0
3. **Update Marketplace Listing**
4. **Announce to Users**
5. **Monitor Feedback**

## Questions During Testing?

Common issues and solutions in IMPROVEMENTS_IMPLEMENTED.md
Technical deep-dive in PLUGIN_DEVELOPMENT_GUIDE.md

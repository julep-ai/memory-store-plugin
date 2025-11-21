# Known Issues

This document tracks known limitations and issues in the Memory Store Plugin.

## ✅ RESOLVED: Broken MCP CLI Command (v1.2.2)

**Status**: Fixed in v1.2.2
**Severity**: Critical → Resolved
**Resolution**: Hooks now signal Claude to invoke MCP tools automatically

### What Was Broken

Scripts were using `claude mcp call` command which doesn't exist in Claude Code CLI:
- `session-start.sh` couldn't record sessions
- `session-end.sh` couldn't store summaries
- `track-changes.sh` couldn't store file changes
- Context retrieval (overview/recall) never worked

### The Fix

Changed architecture from "hooks call CLI" to "hooks signal Claude":

**Before (v1.2.1 and earlier):**
```bash
# This command doesn't exist ❌
echo "$JSON" | claude mcp call memory-store record
```

**After (v1.2.2):**
```bash
# Hooks output structured signals that Claude automatically processes ✅
cat <<EOF
{
  "additionalContext": "🤖 MEMORY_STORE_AUTO_RECORD: {...}"
}
EOF
```

**New Component**: `memory-auto-store` skill automatically invokes MCP tools when it sees these signals.

### Impact

- ✅ Automatic session recording now works
- ✅ File changes automatically stored
- ✅ Context retrieval works on session start
- ✅ Session summaries captured on exit
- ✅ Fully autonomous operation achieved

---

## PostToolUse Hooks Not Supported

**Status**: Known Limitation
**Severity**: Medium
**Workaround**: Available via skills

### Description

PostToolUse hooks (which would run after Bash tool commands like `git commit`) do not trigger in the current Claude Code version. This affects automatic commit tracking.

### Impact

- **What doesn't work**: Automatic commit tracking via hooks
- **What still works**:
  - ✅ File tracking (PreToolUse hooks)
  - ✅ Session tracking (SessionStart/SessionEnd)
  - ✅ Context preservation (PreCompact)
  - ✅ Manual commit tracking via `git-memory-tracker` skill

### Root Cause

The PostToolUse hook event type is either:
1. Not implemented in Claude Code yet, or
2. Requires specific plugin installation method (marketplace vs local)

**Evidence:**
- PostToolUse hooks with `matcher: "Bash"` added to hooks.json
- Script (`analyze-commits.sh`) never executes when Bash tool is used
- Debug logging confirms no hook invocation
- PreToolUse hooks (like `track-changes.sh`) work perfectly

### Workaround

**Use the git-memory-tracker skill** for manual commit tracking:

```bash
User: "Track this commit"
User: "Analyze my last 5 commits"
User: "What did I work on today?"
```

Claude will invoke `scripts/analyze-commits.sh` to track commits in Memory Store.

**Benefits of manual approach:**
- Explicit user control over what gets tracked
- Can batch-track multiple commits
- Can retroactively analyze history
- Can track merges, rebases, cherry-picks
- Provides immediate feedback

### Technical Details

**Attempted Solutions:**
1. ✅ Added PostToolUse hook configuration in hooks.json
2. ✅ Created analyze-commits.sh script with proper JSON parsing
3. ✅ Added command filtering (`git.*commit`)
4. ✅ Tested with debug logging
5. ❌ Hook never fires for any Bash command

**Working Hooks:**
- `SessionStart` - ✅ Fires on session initialization
- `SessionEnd` - ✅ Fires on session end
- `PreToolUse` (Write|Edit) - ✅ Fires before file operations
- `PreToolUse` (Bash) - ✅ Fires before Bash (validate-commit.sh works)
- `PreCompact` - ✅ Fires before conversation compaction
- `Notification` - ✅ Fires on error messages

**Not Working:**
- `PostToolUse` (Bash) - ❌ Never fires after Bash commands

### Future Resolution

This issue may be resolved when:
1. Claude Code adds PostToolUse hook support
2. Plugin marketplace installation enables different hook capabilities
3. Alternative hook mechanisms are implemented (git hooks, filesystem watchers)

### Related Files

- `scripts/analyze-commits.sh` - Manual commit analysis script
- `skills/git-memory-tracker/SKILL.md` - Skill documentation
- `hooks/hooks.json` - Hook configuration (no PostToolUse hooks)

### References

- Discovered during v1.2.0 testing (2025-11-21)
- Issue tracking: [Create GitHub issue for this]
- Workaround implemented: git-memory-tracker skill

---

**Last Updated**: 2025-11-21
**Affects Versions**: v1.0.0 - v1.2.0+
**Workaround Available**: Yes (git-memory-tracker skill)

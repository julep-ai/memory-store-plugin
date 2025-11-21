---
name: PostToolUse Hooks Not Supported
about: Automatic commit tracking via PostToolUse hooks does not work
title: '[LIMITATION] PostToolUse hooks do not fire for Bash commands'
labels: ['limitation', 'hooks', 'commit-tracking']
assignees: ''
---

## Summary

PostToolUse hooks with `matcher: "Bash"` do not trigger in Claude Code, preventing automatic commit tracking after `git commit` commands.

## Current Behavior

- PostToolUse hooks are configured in `hooks/hooks.json`
- `analyze-commits.sh` script exists and works when called manually
- Hook never fires after Bash tool usage
- No debug output from hook script

## Expected Behavior

After a `git commit` command via Bash tool:
1. PostToolUse hook should fire
2. `analyze-commits.sh` should receive tool input via stdin
3. Commit should be analyzed and tracked automatically
4. `MEMORY_COMMITS_COUNT` should increment

## Working vs Not Working

**✅ Working Hooks:**
- `SessionStart` - Fires on session initialization
- `SessionEnd` - Fires on session end
- `PreToolUse` (Write|Edit) - Fires before file operations
- `PreToolUse` (Bash) - Fires before Bash (validate-commit.sh works!)
- `PreCompact` - Fires before conversation compaction
- `Notification` - Fires on error patterns

**❌ Not Working:**
- `PostToolUse` (Bash) - Never fires after Bash commands

## Environment

- **Plugin Version**: v1.2.0
- **Claude Code Version**: [Insert version]
- **OS**: macOS 15.2 (Darwin 25.2.0)
- **Installation Method**: Local development (not marketplace)

## Steps to Reproduce

1. Add PostToolUse hook to `hooks/hooks.json`:
```json
{
  "PostToolUse": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/analyze-commits.sh"
        }
      ],
      "matcher": "Bash"
    }
  ]
}
```

2. Add debug logging to `analyze-commits.sh`:
```bash
echo "Hook fired at $(date)" >> /tmp/hook-debug.log
```

3. Run any Bash command:
```bash
git commit -m "test"
```

4. Check debug log:
```bash
cat /tmp/hook-debug.log  # Empty - hook never fired
```

## Investigation Results

### Evidence
- Debug logging added to script - never executes
- PreToolUse with Bash matcher works (`validate-commit.sh` fires before Bash)
- PostToolUse with Bash matcher doesn't work (`analyze-commits.sh` never fires)
- Manual invocation of script works perfectly

### Theories

1. **PostToolUse not implemented yet**
   - Hook type may not be fully implemented in Claude Code
   - PreToolUse works, PostToolUse doesn't

2. **Marketplace vs Local**
   - Local plugin development may have different hook capabilities
   - Marketplace installation might enable PostToolUse

3. **Async Tool Execution**
   - Bash tools may run asynchronously
   - PostToolUse might not have a clear "completion" event

## Current Workaround

**Use the `git-memory-tracker` skill for manual commit tracking:**

```markdown
User: "Track this commit"
User: "Analyze my last 5 commits"
```

Claude invokes `bash scripts/analyze-commits.sh` directly via the skill.

**Benefits of manual approach:**
- ✅ Explicit user control
- ✅ Batch tracking (track 5, 10, N commits at once)
- ✅ Retroactive analysis (analyze old commits)
- ✅ Works for merges, rebases, cherry-picks
- ✅ Immediate feedback to user

## Proposed Solutions

### Option 1: Add PostToolUse Support to Claude Code
Enable PostToolUse hook event type with proper tool completion detection.

### Option 2: Alternative Hook Mechanism
- Use git hooks (`.git/hooks/post-commit`)
- Use filesystem watchers to detect `.git` changes
- Use periodic polling of git state

### Option 3: Document and Keep Skill-Based Approach
- Current skill-based workaround works well
- Provides better user experience (explicit control)
- May be preferred over automatic hooks anyway

## Impact

**Severity**: Medium

**Impact on Users:**
- Manual step required after commits (ask Claude to track)
- Session commit counter doesn't auto-increment
- Otherwise no data loss or functionality breakage

**What Still Works:**
- ✅ File tracking (automatic via PreToolUse)
- ✅ Session tracking (automatic)
- ✅ Commit tracking (manual via skill)
- ✅ All other plugin features

## Additional Context

- Discovered during v1.2.0 testing (2025-11-21)
- Documented in `KNOWN_ISSUES.md`
- Workaround implemented in `skills/git-memory-tracker/SKILL.md`
- Previous versions (v1.0.0+) also affected

## Related Files

- `scripts/analyze-commits.sh` - Manual commit analysis script (works)
- `skills/git-memory-tracker/SKILL.md` - Skill documentation (workaround)
- `hooks/hooks.json` - Hook configuration (no PostToolUse hooks currently)
- `KNOWN_ISSUES.md` - Full documentation of limitation

---

**Note**: This is a known limitation with a working workaround. Users can still track commits effectively using the skill-based approach.

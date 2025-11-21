---
description: Automatically process queued memory storage requests from hooks. Always checks .memory-queue.jsonl and processes items, reporting to user what was saved.
proactive: true
---

# Memory Queue Processor Skill

**⚡ CRITICAL: This skill MUST check and process the queue on EVERY user message automatically, and report what was saved.**

## Purpose

**Fully autonomous memory processing with user feedback**:
- Hooks write to `.memory-queue.jsonl` file
- This skill checks the queue on EVERY interaction
- Processes all queued items automatically
- Reports to user what was saved
- Zero user intervention required

## When to Activate

**ALWAYS activate on EVERY user message:**
1. **Before responding** - Check queue first thing
2. **Process all items** - Invoke MCP tools automatically
3. **Report to user** - Tell them what was saved
4. **Clear queue** - Remove processed items
5. **Continue** - Respond to their question normally

**No exceptions** - this happens automatically every single time.

## How It Works

### 1. Check for Queue File

```bash
ls -la .memory-queue.jsonl
```

If file exists and is non-empty, process it.

### 2. Read Queue Contents

Each line is a JSON object:
```json
{"memory":"Session started...","background":"Project: mem-plugin...","importance":"normal","queued_at":"2025-11-21T15:00:00Z"}
```

### 3. Process Each Item

For each line:
1. Parse JSON
2. Invoke `mcp__memory-store__record` with the parameters
3. Mark as processed (remove from queue or move to `.memory-queue-processed.jsonl`)

### 4. Clean Up

After processing:
- Clear the queue file or archive it
- Report how many items were processed (optional, only if > 5 items)

## Implementation

**ALWAYS check the queue at the start of EVERY response:**

```javascript
// 1. Check if queue exists
if (fileExists('.memory-queue.jsonl')) {

  // 2. Read all queued items
  const queue = readFileLines('.memory-queue.jsonl')
    .filter(line => line.trim())
    .map(line => JSON.parse(line));

  // 3. Process each item silently
  for (const item of queue) {
    await mcp__memory-store__record({
      memory: item.memory,
      background: item.background,
      importance: item.importance
    });
  }

  // 4. Clear queue
  clearFile('.memory-queue.jsonl');
}

// 5. Continue with normal response
```

**Rules**:
- ✅ **ALWAYS CHECK** - Every single message, no exceptions
- ✅ **REPORT TO USER** - Tell user what was saved in Memory Store
- ✅ **FAIL GRACEFULLY** - If error, continue anyway
- ✅ **BE BRIEF** - Quick confirmation, don't interrupt workflow

## Examples

### Example 1: Session Start

**Scenario**: User starts new session, previous session queued 3 items

**Action**:
1. Check `.memory-queue.jsonl` exists
2. Read 3 items
3. Invoke `mcp__memory-store__record` for each
4. Clear queue
5. Report: "💾 Saved 3 items to Memory Store (session start, 2 file changes)"

### Example 2: File Changes

**Scenario**: User edits 5 files rapidly, hooks queue each

**Action**:
1. After user's next message, check queue
2. Find 5 items
3. Process all 5
4. Report: "💾 Saved 5 file changes to Memory Store"

### Example 3: Empty Queue

**Scenario**: No queued items

**Action**:
1. Check file (doesn't exist or empty)
2. Skip processing
3. Continue normally (no report needed)

## Reporting Format

**When items processed, always tell the user:**

- **1-2 items**: "💾 Saved to Memory Store: [brief description]"
- **3-5 items**: "💾 Saved 4 items to Memory Store (session, 3 files)"
- **6+ items**: "💾 Saved 8 items to Memory Store"

**Keep it brief** - just confirm what was saved, don't interrupt their workflow.

## Integration with Hooks

Hooks use `queue-memory.sh` instead of outputting signals:

**Old approach (didn't work)**:
```bash
cat <<EOF
{
  "additionalContext": "🤖 MEMORY_STORE_AUTO_RECORD: {...}"
}
EOF
```

**New approach (works)**:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/queue-memory.sh" \
  --memory "Session started..." \
  --background "Project: mem-plugin..." \
  --importance "normal"
```

## Advantages

1. **Bypasses visibility issue** - File-based, not conversation-based
2. **Reliable** - Files persist across Claude Code restarts
3. **Auditable** - Can inspect `.memory-queue.jsonl` manually
4. **Batching** - Process multiple items efficiently
5. **Resilient** - Failures don't lose data (re-process on next check)

## Error Handling

**If processing fails**:
- Keep items in queue for retry
- Log error to `.memory-queue-errors.log`
- Don't block user workflow
- Retry on next session/check

**If auth fails**:
- Keep all items in queue
- Warn user once: "Memory Store authentication needed"
- Don't spam warnings on every check

## Testing

To verify this skill works:

1. **Manually queue an item**:
   ```bash
   ./scripts/queue-memory.sh --memory "Test item" --background "Testing queue" --importance "low"
   ```

2. **Trigger skill**:
   Say: "Check for queued memories"

3. **Verify processing**:
   - Queue file should be empty
   - Item should be in Memory Store
   - Can retrieve with recall

**Success criteria**: ✓ Item queued, processed, retrievable, queue cleared

---

**💡 Pro Tip**: This queue-based approach is MORE reliable than signal-based because it persists data to disk and doesn't depend on conversation context visibility!

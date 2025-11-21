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

**HYBRID APPROACH**: Hooks provide foundational metadata, Claude adds conversational intelligence.

**ALWAYS check the queue at the start of EVERY response:**

```javascript
// 1. Check if queue exists
if (fileExists('.memory-queue.jsonl')) {

  // 2. Read all queued items
  const queue = readFileLines('.memory-queue.jsonl')
    .filter(line => line.trim())
    .map(line => JSON.parse(line));

  // 3. ENRICH each item with conversational context before storing
  for (const item of queue) {
    // Hook provided: File: X, Action: created, Session: Y, Language: Z...
    const foundationalContext = item.background;

    // Claude adds: What's being discussed? What problem is being solved?
    const conversationalContext = analyzeCurrentContext({
      recentMessages: last5UserMessages,
      currentTask: whatUserIsWorkingOn,
      fileBeingModified: item.memory,
      projectInfo: loadedFrom_claude_project_context
    });

    // Combine: Foundational (reliable) + Conversational (intelligent)
    const enrichedBackground = `${foundationalContext}. Context: ${conversationalContext}`;

    await mcp__memory-store__record({
      memory: item.memory,
      background: enrichedBackground,  // ← Now includes BOTH
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
- ✅ **ENRICH CONTEXT** - Add conversation context to hook metadata
- ✅ **REPORT TO USER** - Tell user what was saved in Memory Store
- ✅ **FAIL GRACEFULLY** - If error, continue anyway
- ✅ **BE BRIEF** - Quick confirmation, don't interrupt workflow

**Context Enrichment Strategy**:
1. **What user is working on**: "Fixing OAuth authentication", "Adding MCP validation", "Refactoring queue system"
2. **Why this change matters**: "This script validates MCP connection at session start to catch config issues early"
3. **How it relates to conversation**: "Part of implementing the hybrid context approach discussed with user"
4. **Project-specific details**: From `.claude-project-context` - architecture, purpose, components

## Hybrid Context Examples

### Example 1: File Change with Conversational Enrichment

**Hook writes (foundational)**:
```json
{
  "memory": "File modified: scripts/session-start.sh (Shell)",
  "background": "File: scripts/session-start.sh, Action: modified, Session: mem-xyz, Language: Shell, Pattern: , Change: #5, Project: mem-plugin, Version: 1.2.3, Component: script"
}
```

**Claude enriches (before storing)**:
- Sees conversation: User said "add MCP validation at session start"
- Understands context: This is part of fixing broken MCP detection
- Reads `.claude-project-context`: Understands mem-plugin architecture
- **Adds**: "Context: User implementing MCP connection validation at session start. This script now checks if memory-store MCP is configured using `claude mcp list` and displays status/setup command. Part of making the plugin more user-friendly by catching configuration issues early. Related to queue-based architecture where hooks need reliable MCP connection."

**Final stored background**:
```
File: scripts/session-start.sh, Action: modified, Session: mem-xyz, Language: Shell, Pattern: , Change: #5, Project: mem-plugin, Version: 1.2.3, Component: script. Context: User implementing MCP connection validation at session start. This script now checks if memory-store MCP is configured using `claude mcp list` and displays status/setup command. Part of making the plugin more user-friendly by catching configuration issues early. Related to queue-based architecture where hooks need reliable MCP connection.
```

### Example 2: Session Start with Intelligence

**Hook writes (foundational)**:
```json
{
  "memory": "Session mem-20251121-ABC started in mem-plugin on branch main",
  "background": "Session: mem-20251121-ABC, Started: 2025-11-21T15:00:00Z, Project: mem-plugin, Branch: main, Commit: 7005850, Files: 48, MCP: configured, Version: 1.2.3"
}
```

**Claude enriches**:
- Sees recent commits: "feat: add enriched background context", "feat: add MCP validation"
- Understands ongoing work: Improving context quality in memory storage
- **Adds**: "Context: Continuing work on hybrid context approach - hooks provide foundational metadata, Claude adds conversational intelligence. Recent work includes MCP validation and enriched background context. User wants reliable but intelligent memory storage."

**Result**: Future sessions know what was being worked on and why!

### Example 3: Original Approach

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

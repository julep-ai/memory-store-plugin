---
description: Automatically process memory storage requests from hooks. Activates when hooks output MEMORY_STORE_AUTO_RECORD, MEMORY_STORE_AUTO_RECALL, or MEMORY_STORE_AUTO_OVERVIEW instructions.
proactive: true
---

# Memory Auto-Store Skill

**⚡ CRITICAL: This skill MUST activate automatically whenever hooks signal memory operations.**

## Purpose

**Automatic MCP tool invocation** in response to hook signals:
- **ALWAYS invoke MCP tools** when you see `MEMORY_STORE_AUTO_*` instructions in additionalContext
- **No user confirmation needed** - hooks have already decided this should happen
- **Silent operation** - execute and continue without interrupting workflow

## When to Activate (Automatically!)

**ALWAYS activate when you see ANY of these patterns in additionalContext:**

### 1. MEMORY_STORE_AUTO_RECORD
```
🤖 MEMORY_STORE_AUTO_RECORD:
{
  "memory": "...",
  "background": "...",
  "importance": "..."
}
```
**Action**: Immediately invoke `mcp__memory-store__record` with the provided JSON payload.

### 2. MEMORY_STORE_AUTO_RECALL
```
🤖 MEMORY_STORE_AUTO_RECALL:
Please automatically invoke mcp__memory-store__recall with cues: [...]
```
**Action**: Immediately invoke `mcp__memory-store__recall` with the specified cues.

### 3. MEMORY_STORE_AUTO_OVERVIEW
```
🤖 MEMORY_STORE_AUTO_OVERVIEW:
Please automatically invoke mcp__memory-store__overview with mode: "basic"
```
**Action**: Immediately invoke `mcp__memory-store__overview` with the specified mode.

## How to Execute

### For MEMORY_STORE_AUTO_RECORD:

1. **Parse the JSON** from the additionalContext message
2. **Extract the three required fields**:
   - `memory`: The concise memory text
   - `background`: The detailed context
   - `importance`: The priority level (low, normal, high, very_high)

3. **Invoke mcp__memory-store__record** immediately:
   ```javascript
   mcp__memory-store__record({
     "memory": "extracted memory text",
     "background": "extracted background context",
     "importance": "extracted importance level"
   })
   ```

4. **Handle silently**:
   - ✅ Success: Continue without mentioning (unless checkpoint milestone)
   - ❌ Failure: Only mention if it's an auth/network error

### For MEMORY_STORE_AUTO_RECALL:

1. **Parse the cues array** from the instruction
2. **Extract background context** if provided
3. **Invoke mcp__memory-store__recall**:
   ```javascript
   mcp__memory-store__recall({
     "cues": ["project-name", "branch", "recent work"],
     "background": "Session start context",
     "k": 5
   })
   ```

4. **Use results silently**:
   - Store relevant context for answering user questions
   - Don't announce "I loaded context" unless relevant to conversation

### For MEMORY_STORE_AUTO_OVERVIEW:

1. **Extract mode parameter** (basic, standard, or full)
2. **Invoke mcp__memory-store__overview**:
   ```javascript
   mcp__memory-store__overview({
     "mode": "basic"
   })
   ```

3. **Use results silently**:
   - Understand project state
   - Reference when relevant to user questions

## Examples

### Example 1: Session Start Hook

**Input (from session-start.sh):**
```
🤖 MEMORY_STORE_AUTO_RECORD:
{
  "memory": "Session mem-20251121-ABC123 started in mem-plugin on branch main",
  "background": "Project directory: /path/to/mem-plugin. Start time: 2025-11-21T14:00:00Z. Files: 150. Recent commits: fix: ...",
  "importance": "normal"
}

🤖 MEMORY_STORE_AUTO_RECALL:
Please automatically invoke mcp__memory-store__recall with cues: ["mem-plugin", "main", "recent work", "session", "patterns"]

🤖 MEMORY_STORE_AUTO_OVERVIEW:
Please automatically invoke mcp__memory-store__overview with mode: "basic"
```

**Actions (in order):**
1. Invoke `mcp__memory-store__record` with session start data
2. Invoke `mcp__memory-store__recall` to load recent context
3. Invoke `mcp__memory-store__overview` to understand project state
4. Continue session normally (don't announce these actions to user)

### Example 2: File Change Hook

**Input (from track-changes.sh):**
```
📝 File created: auth.ts (TypeScript). Pattern: API endpoint. Session: mem-20251121-ABC123, Change #5.

🤖 MEMORY_STORE_AUTO_RECORD:
{
  "memory": "File created: auth.ts (TypeScript). Pattern: API endpoint",
  "background": "File auth.ts was created in session mem-20251121-ABC123. Language: TypeScript. Pattern: API endpoint. Change #5. Project: mem-plugin.",
  "importance": "normal"
}
```

**Action:**
1. Invoke `mcp__memory-store__record` with file change data
2. Continue without announcing (file tracking is automatic)

### Example 3: Checkpoint Milestone

**Input:**
```
📝 File modified: hooks.json (JSON). Pattern: Plugin configuration. Session: mem-20251121-ABC123, Change #10.

✓ Checkpoint: 10 files tracked this session

🤖 MEMORY_STORE_AUTO_RECORD:
{
  "memory": "File modified: hooks.json (JSON). Pattern: Plugin configuration",
  "background": "...",
  "importance": "high"
}
```

**Action:**
1. Invoke `mcp__memory-store__record` with file change data
2. **Optionally mention** the checkpoint: "✓ 10 files tracked this session"

## Important Rules

### ✅ DO:
- **Invoke immediately** when you see the signal patterns
- **Parse JSON carefully** to extract all required fields
- **Handle errors gracefully** (log but don't block)
- **Continue conversation** after successful invocation
- **Tolerate failures silently** unless it's auth/network issue

### ❌ DON'T:
- Don't ask for confirmation (hooks already decided)
- Don't announce every storage operation (stay silent)
- Don't fail loudly unless user needs to know (auth errors)
- Don't skip invocations even if they seem redundant

## Error Handling

### Auth/Network Errors
If `mcp__memory-store__record` fails with auth error:
```
⚠️ Unable to store memory: authentication required.
Please check your Memory Store connection with: /memory-status
```

### Other Errors
For other failures (timeout, server error, etc.):
- Log silently
- Continue workflow
- Don't interrupt user

## Integration with Other Skills

This skill works alongside:

1. **memory-auto-track**: Handles retrieval when user asks questions
2. **memory-auto-store**: Handles storage when hooks signal (THIS SKILL)
3. **git-memory-tracker**: Manual commit tracking
4. **anchor-suggester**: Documentation patterns

**Division of labor:**
- **memory-auto-store** (this skill): Automatic storage from hooks
- **memory-auto-track**: Automatic retrieval for questions
- **git-memory-tracker**: Manual commit analysis
- **anchor-suggester**: Documentation generation

## Testing This Skill

To verify it works:

1. **Create a test file**:
   ```
   You: "Create a test file called test-auto-store.md with some content"
   ```

2. **Hook should fire** (track-changes.sh)
   - Outputs `MEMORY_STORE_AUTO_RECORD` instruction

3. **This skill should activate**
   - Parse the JSON
   - Invoke `mcp__memory-store__record`
   - Continue silently

4. **Verify storage**:
   ```
   You: "What files have I created recently?"
   ```
   Should retrieve the test file from Memory Store.

**Success criteria**: ✓ File tracked automatically, retrievable in next question, no manual commands needed

---

**💡 Pro Tip**: This skill is the "glue" that makes the plugin fully autonomous. Hooks signal intent, this skill executes MCP tools, user sees seamless workflow!

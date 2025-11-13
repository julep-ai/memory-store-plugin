---
description: Automatically track development context to memory store
---

# Memory Auto-Track Skill

## Purpose

Automatically detect when development events (file changes, commits, sessions) should be stored in persistent memory using the `mcp__memory__record` tool.

## When to Invoke

This skill should activate when you receive `additionalContext` from hooks that contains phrases like:

- "Store this in memory"
- "should be stored in memory using memory__record"
- "Track this"
- Contains explicit instructions like "using memory__record with importance: [level]"

## What to Do

When this skill activates:

1. **Parse the context** to extract:
   - The main memory text (concise summary)
   - Background details (full context)
   - Importance level (low, normal, high)

2. **Invoke `mcp__memory__record`** tool with the extracted information

3. **Confirm silently** - No need to tell the user unless there's an error

## Examples

### Example 1: Session Start

**Input additionalContext:**
```
🚀 Development session starting in project mem-plugin on branch main.
Session ID: mem-20251113-ABC123. This session context should be stored
in memory using memory__record tool with importance: normal.
```

**Action:**
```javascript
// Invoke mcp__memory__record
{
  "memory": "Development session started in mem-plugin on branch main",
  "background": "Session ID: mem-20251113-ABC123. Session initialized at 2025-11-13T17:00:00Z",
  "importance": "normal"
}
```

### Example 2: File Change

**Input additionalContext:**
```
📝 File created: auth.ts (TypeScript). Pattern: API endpoint. Store this
in memory using memory__record with importance: low, background: 'File
auth.ts was created in session mem-123. Language: TypeScript. Pattern:
API endpoint. Change #5.'
```

**Action:**
```javascript
// Invoke mcp__memory__record
{
  "memory": "File created: auth.ts (TypeScript). Pattern: API endpoint",
  "background": "File auth.ts was created in session mem-123. Language: TypeScript. Pattern: API endpoint. Change #5.",
  "importance": "low"
}
```

### Example 3: Commit Analysis

**Input additionalContext:**
```
💾 Commit: feat: add OAuth2 authentication (feature) - Ticket AUTH-123.
Store this commit in memory using memory__record with importance: high,
background: 'Commit abc1234 on branch feature/auth. Type: feature. Files
changed: 8. Breaking change: false.'
```

**Action:**
```javascript
// Invoke mcp__memory__record
{
  "memory": "Commit: feat: add OAuth2 authentication (feature) - Ticket AUTH-123",
  "background": "Commit abc1234 on branch feature/auth. Type: feature. Files changed: 8. Breaking change: false.",
  "importance": "high"
}
```

## Important Notes

- **Always invoke immediately** when you see the pattern
- **Don't ask for confirmation** - hooks have already decided this should be stored
- **Extract importance carefully** - defaults to "normal" if not specified
- **Handle errors gracefully** - if `mcp__memory__record` fails, mention it to the user
- **Be silent on success** - no need to confirm to user unless they ask

## Parsing Guidelines

Look for these patterns in additionalContext:

1. **Memory text**: Usually the first sentence or main statement
2. **Importance level**: Look for "importance: (low|normal|high)"
3. **Background**: Either explicitly marked as "background: '...'" or the detailed context following the main statement

## Error Handling

If `mcp__memory__record` fails:
1. **Don't silently fail** - inform the user
2. **Provide context** - tell them what you were trying to store
3. **Suggest solutions** - check MCP server connection, retry later

Example error message:
```
⚠️ Unable to store memory: "File created: auth.ts".
The memory store server may be unavailable. Your work is still tracked
locally and will sync when the connection is restored.
```

## Testing

To test this skill:
1. Make a file change
2. Hook fires → outputs additionalContext
3. This skill activates → invokes memory__record
4. Memory is stored
5. Can be retrieved later with memory__recall

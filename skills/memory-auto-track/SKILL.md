---
description: Automatically track development context and retrieve relevant memories when needed
proactive: true
---

# Memory Auto-Track Skill

**⚡ IMPORTANT: This skill is ALWAYS ACTIVE. Use it automatically whenever the user asks questions.**

## Purpose

**Automatic memory search** integrated into conversation:
- **ALWAYS search memory** when user asks ANY question about the project
- **Check for established patterns** before suggesting implementations
- **Surface relevant past work** automatically
- **No manual /memory-recall needed** - you do it automatically

**Note**: Storage is handled automatically by hooks. This skill makes retrieval AUTOMATIC.

## When to Search Memory (Automatically!)

**ALWAYS invoke mcp__memory-store__recall when:**

1. **User asks ANY question about the project**
   - "How did we implement X?"
   - "What patterns do we use?"
   - "Why did we choose Y?"
   - **→ AUTOMATICALLY search memory BEFORE answering**

2. **User asks you to implement something**
   - "Create an API endpoint"
   - "Add authentication"
   - "Fix the bug in X"
   - **→ AUTOMATICALLY search for similar past work**

3. **User asks about team/ownership**
   - "Who worked on X?"
   - "What does the team use for Y?"
   - **→ AUTOMATICALLY search memory**

4. **User mentions uncertainty**
   - "I'm not sure how we..."
   - "What's our convention for..."
   - **→ AUTOMATICALLY search memory**

5. **You're about to suggest something**
   - Before proposing an approach
   - **→ AUTOMATICALLY search to check for existing patterns**

**Cues for retrieval:**
- Project name
- File/directory names being worked on
- Technology stack keywords
- Feature names
- Problem domain terms

## What to Do

### For Storing Memories

When storing (reactive to hooks):

1. **Parse the context** to extract:
   - The main memory text (concise summary)
   - Background details (full context)
   - Importance level (low, normal, high)

2. **Invoke `mcp__memory__record`** tool with the extracted information

3. **Confirm silently** - No need to tell the user unless there's an error

### For Retrieving Context

When retrieving (proactive for guidance):

1. **Identify what you need to know**:
   - What patterns exist for this type of work?
   - How was similar functionality implemented?
   - What decisions were made about this?

2. **Create search cues** (3-7 relevant terms):
   ```javascript
   ["authentication", "API endpoint", "OAuth", "patterns"]
   ```

3. **Invoke `mcp__memory__recall`** with:
   - `cues`: Array of search terms
   - `background`: Context about why you're searching
   - `k`: Number of results (default 10)

4. **Use the results** to:
   - Follow established patterns
   - Reference past decisions
   - Ensure consistency with team conventions
   - Provide better, context-aware responses

5. **Mention to user** when using past context:
   - "Based on our previous work with authentication..."
   - "Following the API pattern we established in auth.ts..."
   - "Consistent with the decision we made on 2024-11-01..."

## Examples

### Example 1: Storing - Session Start

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

### Example 4: Retrieving - User Asks About Past Work

**User says:**
```
"How did we implement authentication in this project?"
```

**Action:**
```javascript
// Invoke mcp__memory__recall
{
  "cues": ["authentication", "implement", "auth", "login", "OAuth"],
  "background": "User asking about authentication implementation. Need to retrieve past work on auth systems in this project.",
  "k": 10
}
```

**Expected results:**
- Past commits related to authentication
- Files that implement auth (auth.ts, login.tsx, etc.)
- Decisions made about auth approach
- Patterns used for authentication

**Response to user:**
```
Based on our previous work, we implemented OAuth2 authentication.
See auth.ts:45 where we established the pattern. The flow uses...
```

### Example 5: Retrieving - Starting Similar Work

**User says:**
```
"Create a new API endpoint for user profiles"
```

**Before implementing, retrieve context:**
```javascript
// Invoke mcp__memory__recall
{
  "cues": ["API endpoint", "create endpoint", "user", "REST API", "patterns"],
  "background": "About to create new API endpoint. Need to check existing API patterns and conventions.",
  "k": 5
}
```

**Use results to:**
- Follow same authentication pattern
- Use same error handling approach
- Match existing API structure
- Maintain consistency

**Response:**
```
I'll create the user profiles endpoint following our established API pattern.
Based on our existing endpoints (like auth.ts), I'll use the same middleware
structure and error handling...
```

### Example 6: Retrieving - Avoiding Going Off Track

**Scenario:** Claude is about to suggest using MongoDB, but team uses PostgreSQL

**Before suggesting:**
```javascript
// Invoke mcp__memory__recall
{
  "cues": ["database", "data storage", "PostgreSQL", "MongoDB", "decision"],
  "background": "Need to recommend database approach. Checking if team has established database preferences.",
  "k": 5
}
```

**Results show:** "Decision: Use PostgreSQL for ACID compliance (2024-10-15)"

**Corrected response:**
```
I'll use PostgreSQL for this, consistent with our team's decision from
October 2024. This ensures ACID compliance and aligns with our existing
database infrastructure.
```

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

**For Storage:**
1. Make a file change
2. Hook fires → outputs additionalContext
3. This skill activates → invokes memory__record
4. Memory is stored

**For Retrieval:**
1. Ask Claude about past work: "How did we implement X?"
2. Skill should invoke memory__recall automatically
3. Claude uses retrieved context in response
4. Mentions where pattern/decision came from

**End-to-end test:**
1. Create file with specific pattern (e.g., API endpoint)
2. Verify stored via memory__record
3. Later ask: "How should I create an API endpoint?"
4. Claude retrieves the pattern and follows it
5. Consistency maintained! ✅

---
description: Retrieve relevant context from memory store for current work
---

# Memory Recall

Retrieves relevant development context, patterns, and team knowledge from the memory store based on your query or current task.

## What this command does

1. **Searches memory store**: Finds relevant past work and decisions
2. **Shows similar implementations**: Displays patterns used in similar contexts
3. **Retrieves team knowledge**: Surfaces insights from other team members
4. **Suggests best practices**: Recommends patterns based on project history
5. **Warns about deviations**: Alerts if current approach differs from established patterns

## Usage

```
/memory-recall [query]
```

## Examples

### Query Authentication Patterns
```
/memory-recall authentication flow
```

**Returns:**
- OAuth2 implementation pattern (src/api/auth.ts:45)
- Past decisions about auth approach
- Token refresh strategy
- Error handling conventions
- Related team decisions

### Find Database Decisions
```
/memory-recall why did we choose PostgreSQL
```

**Returns:**
- Decision reasoning (ACID compliance)
- Rejected alternatives (MongoDB, etc.)
- When decided (Nov 13, 2025)
- Stakeholders (Security Team)
- Related constraints

### Retrieve Error Handling Patterns
```
/memory-recall error handling in API
```

**Returns:**
- Established error patterns
- Standardized error codes
- Logging conventions
- Team practices
- Example implementations

### Get Team Expertise
```
/memory-recall who knows about frontend
```

**Returns:**
- Ownership map (Bob: 90% frontend commits)
- Expertise areas
- Recent work
- Best person to ask

## Example Output

```
/memory-recall authentication patterns

📋 Retrieved Context from Memory Store
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Authentication Implementation (3 relevant memories)

1. OAuth2 Flow Pattern (2 weeks ago)
   - Location: src/api/auth.ts:45
   - Decision: OAuth2 password flow for all auth
   - Reasoning: PCI compliance requirement
   - Context: <!-- AUTH-FLOW --> in CLAUDE.md

2. Token Refresh Strategy (1 week ago)
   - Pattern: Automatic refresh before expiration
   - Implementation: src/utils/tokenManager.ts:78
   - Edge cases: Network failures, concurrent requests

3. Error Handling (3 days ago)
   - Pattern: Standardized auth error codes
   - Location: src/types/errors.ts:23
   - Used by: All authentication endpoints

Related Patterns:
  - Session management: src/api/sessions.ts
  - User permissions: src/middleware/permissions.ts
  - API security: See CLAUDE.md

Suggested Actions:
  1. Follow OAuth2 pattern in src/api/auth.ts
  2. Use standardized error codes
  3. Update documentation with any new patterns
```

## When to Use

- ✅ Starting new feature (check similar work)
- ✅ Making decisions (review past choices)
- ✅ Code reviews (understand context)
- ✅ Bug fixing (see similar issues)
- ✅ Onboarding (learn project patterns)

## Automatic vs Manual

**Automatic Recall** (happens during conversation):
- Claude retrieves context automatically
- No command needed
- Happens every 5-10 messages
- Triggered by keywords

**Manual Recall** (this command):
- Explicit context retrieval
- Specific queries
- Detailed results
- On-demand information

## Advanced Usage

### Filter by Time
```
/memory-recall --since="1 week" database changes
```

### Filter by Author
```
/memory-recall --author=alice backend patterns
```

### Include Commits
```
/memory-recall --with-commits authentication
```

## Related Commands

- `/memory-record "info"` - Store new memories
- `/memory-overview` - Full project overview
- `/memory-status` - Current session stats
- `/memory-ownership [person]` - Team expertise map

## Note

Most context retrieval happens **automatically** during conversations. Use `/memory-recall` when you want specific, detailed information on demand.

---
description: Retrieve relevant context from memory store for current work
---

# Memory Context

Retrieves relevant development context, patterns, and team knowledge from the memory store based on your current task or query.

## What this command does

1. **Searches memory store**: Finds relevant past work and decisions
2. **Shows similar implementations**: Displays patterns used in similar contexts
3. **Retrieves team knowledge**: Surfaces insights from other team members
4. **Suggests best practices**: Recommends patterns based on project history
5. **Warns about deviations**: Alerts if current approach differs from established patterns

## Usage

```
/memory-context [query]
```

## Examples

### Retrieve context for current file
```
/memory-context
```
Automatically analyzes current file and retrieves relevant context.

### Query specific topic
```
/memory-context authentication flow
```
Retrieves all context related to authentication implementation.

### Find similar implementations
```
/memory-context similar to current component
```
Finds similar components and their implementation patterns.

### Get team decisions
```
/memory-context why did we choose PostgreSQL
```
Retrieves the reasoning behind technical decisions.

## Example Output

```
User: /memory-context authentication patterns

Claude: Retrieved Context from Memory Store
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Authentication Implementation (3 relevant memories)

1. OAuth2 Flow Pattern (2 weeks ago)
   - Implemented in: src/api/auth.ts:45
   - Decision: Use OAuth2 with JWT tokens
   - Reasoning: Better security, supports SSO
   - Team member: @john (documented in session mem-2025-01-01-xyz)

2. Token Refresh Strategy (1 week ago)
   - Pattern: Automatic refresh before expiration
   - Implementation: src/utils/tokenManager.ts:78
   - Edge cases handled: Network failures, concurrent requests
   - Reference: CLAUDE.md anchor <!-- AUTH-TOKEN-REFRESH -->

3. Error Handling Convention (3 days ago)
   - Pattern: Standardized auth error codes
   - Location: src/types/errors.ts:23
   - Used by: All authentication endpoints
   - Team consensus: Decided in session mem-2025-01-12-abc

Related Patterns:
  - Session management: src/api/sessions.ts
  - User permissions: src/middleware/permissions.ts
  - API security: CLAUDE.md anchor <!-- API-SECURITY -->

Suggested Next Steps:
  1. Follow the OAuth2 pattern established in src/api/auth.ts
  2. Implement error handling using standardized codes
  3. Update CLAUDE.md with any new authentication patterns
```

## Advanced Usage

### Filter by time period
```
/memory-context --since="1 week ago" database queries
```

### Filter by team member
```
/memory-context --author=@john API design patterns
```

### Include commit context
```
/memory-context --with-commits authentication
```

## Related Commands

- `/memory-sync` - Sync current state to memory
- `/memory-status` - View tracking status
- `/memory-overview` - Generate project overview

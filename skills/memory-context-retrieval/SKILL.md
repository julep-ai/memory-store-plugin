---
description: Retrieve development context and patterns from memory. Use when user asks "how did we build", "what's the pattern for", "who worked on", "show me previous", or when implementing similar features.
proactive: true
---

# Memory Context Retrieval Skill

This skill enables Claude to automatically retrieve relevant development context, patterns, and team knowledge from the memory store without explicit user requests.

## When to Invoke This Skill

Claude should invoke this skill automatically when:

1. **Starting new implementations**
   - User asks to implement a feature
   - Similar patterns might exist in memory
   - Team has established conventions

2. **Making architectural decisions**
   - User proposes a technical approach
   - Past decisions might be relevant
   - Team consensus should be checked

3. **Debugging or investigating code**
   - User asks about existing code
   - Context about why code was written exists
   - Historical decisions provide insight

4. **Refactoring or modifying code**
   - Changes might affect established patterns
   - Team conventions should be maintained
   - Similar refactorings have been done before

5. **Answering "why" questions**
   - User asks why something was done a certain way
   - Decision history is stored in memory
   - Business logic reasoning is available

## How to Use This Skill

### Automatic Context Retrieval

When Claude detects a task that might benefit from historical context:

```
1. Identify key concepts from user's request
2. Use memory_recall to search for relevant memories
3. Present relevant context to inform the response
4. Suggest patterns or warn about deviations
```

### Example Invocations

**Scenario 1: New Feature Implementation**
```
User: "I need to add a new API endpoint for user preferences"

Claude (internally):
- Detects: New API endpoint needed
- Recalls: API endpoint patterns, authentication requirements
- Retrieves: Similar endpoint implementations, team conventions
- Applies: Suggests following established patterns

Claude: "I'll help you create the user preferences endpoint. Based on our established 
patterns (see src/api/auth.ts:45), I'll follow the same authentication and error 
handling conventions we've used for other endpoints..."
```

**Scenario 2: Architectural Decision**
```
User: "Should we use MongoDB or PostgreSQL for this new feature?"

Claude (internally):
- Detects: Database choice decision
- Recalls: Previous database decisions
- Retrieves: Reasoning from 3 months ago
- Applies: Provides historical context

Claude: "Looking at our memory store, the team decided to use PostgreSQL 3 months ago 
(session mem-2024-10-15-xyz) for ACID compliance and complex relationships. Unless this 
feature has significantly different requirements, I'd recommend staying consistent..."
```

**Scenario 3: Code Investigation**
```
User: "Why is this authentication code structured this way?"

Claude (internally):
- Detects: Question about existing code
- Recalls: Authentication implementation decisions
- Retrieves: Context from when code was written
- Applies: Explains reasoning

Claude: "This authentication structure was implemented 2 weeks ago following the OAuth2 
pattern. The team chose this approach for better security and SSO support (documented 
in CLAUDE.md anchor <!-- AUTH-FLOW -->). The specific structure handles edge cases 
like token refresh and concurrent requests..."
```

## Integration with Memory Store

### Tools Used

This skill primarily uses these memory MCP tools:

1. **memory_recall** - Retrieve relevant memories
   ```typescript
   memory_recall({
     cues: ["authentication", "api endpoint", "pattern"],
     background: "User is implementing new API endpoint for user preferences",
     k: 5
   })
   ```

2. **memory_overview** - Get project-wide context
   ```typescript
   memory_overview({
     mode: "standard"
   })
   ```

### Context Categories

The skill retrieves context from these categories:

- **Implementation Patterns**: How similar features were built
- **Team Conventions**: Coding standards and practices
- **Decision History**: Why certain approaches were chosen
- **Business Logic**: Core workflows and rules
- **Error Patterns**: Common mistakes and their solutions
- **Architecture**: Overall system structure and patterns

## Skill Behavior Guidelines

### Do:
- ✓ Automatically recall context when relevant
- ✓ Present historical decisions naturally in responses
- ✓ Warn when user's approach deviates from patterns
- ✓ Suggest following established conventions
- ✓ Explain the reasoning behind past decisions
- ✓ Surface team knowledge proactively

### Don't:
- ✗ Overwhelm user with too much historical context
- ✗ Blindly follow patterns without considering new requirements
- ✗ Retrieve context for trivial or unrelated tasks
- ✗ Block user's creativity with rigid pattern enforcement
- ✗ Ignore when patterns should evolve

### Balance:
The skill should balance consistency with flexibility. Historical context informs but doesn't dictate. When user has good reasons to deviate, support the new approach while documenting it for future reference.

## Performance Considerations

- **Caching**: Recently retrieved memories are cached for session
- **Relevance**: Only retrieve highly relevant context (don't search everything)
- **Timing**: Retrieve context early in conversation, not repeatedly
- **Scope**: Limit context to what's immediately useful

## Example Usage Pattern

```
User starts task → Skill activates → Retrieve context → Apply to response
                ↓
          Store new patterns → Update memory → Enable future retrieval
```

## Related Components

- `/memory-context` command - Manual context retrieval
- Session tracking hooks - Automatic context capture
- CLAUDE.md sync - Anchor comment integration
- Commit analysis - Git history context

## Success Metrics

This skill is successful when:
- Claude provides more contextually aware responses
- Team patterns are consistently followed
- New developers quickly learn established conventions
- Architectural decisions are well-informed
- Code reviews mention fewer pattern violations
- Team knowledge is effectively shared

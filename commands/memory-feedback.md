---
description: Provide feedback on Claude's responses to improve future interactions
---

# Memory Feedback

Capture feedback about Claude's responses, tool usage, or suggestions to improve future interactions. This feedback is stored in the memory store and helps Claude learn what works and what doesn't in your specific project context.

## What this command does

1. **Captures feedback**: Records your assessment of Claude's performance
2. **Stores context**: Preserves the situation that led to the feedback
3. **Enables learning**: Helps Claude avoid similar issues in the future
4. **Improves responses**: Contributes to better contextual awareness

## Usage

### Quick Feedback

```
/memory-feedback poor
```

Captures basic feedback that the response was poor quality.

### Detailed Feedback

```
/memory-feedback "The suggested pattern didn't match our architecture"
```

Provides specific context about what went wrong.

### With Rating

```
/memory-feedback --rating=3 "Authentication approach was outdated"
```

Includes a numeric rating (0-10) along with explanation.

## Feedback Types

### Negative Feedback (0-4/10)

Use when responses are:
- Factually incorrect
- Don't match project patterns
- Ignore established conventions
- Suggest deprecated approaches
- Miss important context

**Example:**
```
/memory-feedback --rating=2 "Suggested using Redux when we use Zustand"
```

### Neutral Feedback (5/10)

Use when responses are:
- Partially correct
- Need more context
- Work but aren't optimal
- Miss some nuances

**Example:**
```
/memory-feedback --rating=5 "Correct approach but didn't follow our naming convention"
```

### Positive Feedback (6-10/10)

Use when responses are:
- Excellent and contextual
- Follow all patterns
- Show deep understanding
- Exceed expectations

**Example:**
```
/memory-feedback --rating=9 "Perfectly matched our service layer pattern and included error handling"
```

## When to Use

### ❌ Response Was Wrong

```
User: "How should I implement caching?"
Claude: "Use Redis"
User (thinking): "But we use in-memory caching with Node-cache"

/memory-feedback "Suggested Redis but we use node-cache for in-memory caching"
```

### ❌ Ignored Project Patterns

```
User: "Create a new API endpoint"
Claude: [Creates endpoint without authentication middleware]
User (thinking): "All our endpoints require auth"

/memory-feedback "Created endpoint without auth middleware - all endpoints need authentication"
```

### ❌ Outdated Suggestion

```
User: "Update the user service"
Claude: "I'll use the old pattern from src/services/auth.ts"
User (thinking): "That pattern was refactored last week"

/memory-feedback "Referenced old auth pattern - we refactored to use dependency injection"
```

### ✅ Excellent Response

```
User: "Add error handling"
Claude: [Implements with our standardized error codes and logging]

/memory-feedback --rating=10 "Perfect! Used our error code system and logging format"
```

## How It Helps

### Short Term (This Session)
- Claude adjusts approach immediately
- Considers feedback in next responses
- Avoids repeating the same mistake

### Medium Term (This Week)
- Patterns learned and reinforced
- Better context matching
- Improved accuracy in similar tasks

### Long Term (Team Wide)
- All team members benefit
- Collective knowledge grows
- Patterns become well-established

## Feedback Categories

The plugin automatically categorizes feedback:

### Pattern Mismatches
When responses don't follow established code patterns.

### Architecture Violations
When suggestions conflict with project architecture.

### Convention Errors
When responses ignore coding conventions.

### Context Gaps
When responses miss important project-specific context.

### Outdated Information
When responses use old patterns or deprecated approaches.

## Example Workflow

### Scenario: New Feature Implementation

```
User: "Add user profile editing"
Claude: [Implements without validation]

/memory-feedback --rating=4 "Missing validation - all user inputs must be validated"

User: "Add validation"
Claude: [Adds validation using Joi]

/memory-feedback --rating=7 "Good validation but we use Zod, not Joi"

User: "Use Zod instead"
Claude: [Refactors to use Zod following our patterns]

/memory-feedback --rating=10 "Perfect! Followed our Zod validation patterns exactly"
```

**Result**: Next time validation is needed, Claude will:
- Use Zod instead of Joi
- Follow the established validation patterns
- Remember that validation is required for user inputs

## Advanced Usage

### Feedback with Context

```
/memory-feedback --rating=3 --context="Git branch: feature/auth, Commit: a1b2c3d" "Wrong OAuth2 flow used"
```

### Feedback for Specific Files

```
/memory-feedback --file="src/api/users.ts" "Endpoint structure doesn't match our REST conventions"
```

### Feedback Categories

```
/memory-feedback --category="security" "Authentication bypass vulnerability in suggested code"
```

## Integration with Memory Store

Feedback is stored using the `memory_feedback` MCP tool:

```typescript
memory_feedback({
  input: "Detailed feedback in markdown format",
  rating: 3  // 0-10 scale
})
```

This feedback is then:
1. **Analyzed**: Memory organizer processes the feedback
2. **Linked**: Connected to related patterns and context
3. **Applied**: Used to improve future responses
4. **Shared**: Available to all team members

## Automatic Feedback

The plugin can automatically capture feedback in certain scenarios:

### Tool Failures
When tools fail or return errors, automatic feedback is captured.

### Pattern Deviations
When code doesn't match established patterns, feedback is logged.

### Convention Violations
When coding conventions are violated, feedback is recorded.

## Privacy Note

Feedback is stored in your team's memory store and includes:
- ✅ Feedback text and rating
- ✅ Project context (files, patterns)
- ✅ Session information
- ✅ Git context (branch, commit)
- ❌ Not included: Source code or sensitive data

## Best Practices

### ✅ Do This
- Be specific about what was wrong
- Include what you expected instead
- Mention relevant patterns or files
- Rate honestly (helps calibration)
- Give positive feedback too!

### ❌ Avoid This
- Generic feedback like "bad"
- Feedback without context
- Personal frustration venting
- Inconsistent rating scales

## Example Feedback Messages

**Good Examples:**

```
"Used class components but we use functional components with hooks"

"Suggested SQL query is vulnerable to injection - we use parameterized queries"

"Perfect implementation of our service layer pattern with proper error handling"

"Missing TypeScript types - all functions need explicit return types"

"Excellent! Followed our conventional commit format and updated CHANGELOG"
```

**Less Helpful:**

```
"Wrong"
"Bad"
"Do better"
"Not what I wanted"
```

## Viewing Feedback Impact

Check how feedback has improved responses:

```
/memory-context feedback patterns
```

See what feedback has been captured:

```
/memory-status --show-feedback
```

## Related Commands

- `/memory-status` - See feedback captured in current session
- `/memory-context` - View how feedback improved context
- `/memory-sync` - Sync feedback to memory store

---

**Remember**: Feedback helps Claude learn your project's specific patterns, conventions, and requirements. The more specific and constructive your feedback, the better Claude becomes at helping your team!

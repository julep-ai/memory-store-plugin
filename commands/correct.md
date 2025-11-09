---
description: Correct Claude's mistakes and store high-priority learning
---

# Correct Command

Records a correction when Claude makes a mistake. This creates a high-importance memory that Claude will remember in future sessions.

## What It Does

1. Stores your correction as a high-priority memory (`importance: "high"`)
2. Marks it as a resolution (`is_resolution: true`)
3. Records it in the session for quality tracking
4. Reduces session quality score (for feedback learning)
5. Ensures Claude never makes the same mistake again

## Usage

```
/correct "explanation of what was wrong and what's correct"
```

## Examples

### Authentication Approach Correction
```
/correct "You suggested JWT tokens, but we use OAuth2 password flow for all authentication. Never suggest JWT-based auth in this project."
```

### Test Framework Correction
```
/correct "Wrong test framework. We use Jest, not Mocha. All test files should import from '@testing-library/react' and use Jest syntax."
```

### API Pattern Correction
```
/correct "API endpoints should follow RESTful conventions. Don't create /getData endpoints - use GET /api/resource instead."
```

### Architecture Correction
```
/correct "We follow a service layer pattern. Business logic belongs in src/services/, NOT in API routes. Routes should only handle HTTP concerns."
```

## What Gets Stored

When you use `/correct`, the plugin stores:

```json
{
  "memory": "Correction: [your explanation]",
  "background": "Full context of the mistake and session details",
  "importance": "high",
  "is_resolution": true
}
```

This is marked as `is_resolution: true` which tells the memory store: "This corrects a previous wrong belief."

## Impact on Session Quality

Corrections reduce the session quality score:
- 0 corrections = 10/10 (Excellent)
- 1-2 corrections = 7/10 (Good)
- 3+ corrections = 5/10 (Needs Improvement)

This feedback helps track how well Claude is performing and what needs to be learned.

## Best Practices

### ✅ Good Corrections (Specific)
```
/correct "We use Postgres, not MongoDB. Decision made in June 2024 because we need ACID compliance for transactions. See docs/architecture.md"
```

### ❌ Vague Corrections (Less Useful)
```
/correct "that's wrong"
```

The more context you provide, the better Claude can learn.

## Difference from Regular Feedback

| Feature | `/correct` | `/memory-feedback` |
|---------|-----------|-------------------|
| Priority | High | Normal |
| Type | Resolution | Feedback |
| When to use | Claude made a mistake | General session quality |
| Storage | Immediate | End of session |

## Related Commands

- `/memory-feedback` - General feedback about session quality
- `/checkpoint` - Validate work and catch mistakes early
- `/session-feedback` - View current session rating

---

Use this command to teach Claude what's wrong and ensure it learns for future sessions.

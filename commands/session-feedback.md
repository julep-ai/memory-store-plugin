---
description: View current session quality rating and metrics
---

# Session Feedback Command

Shows the current session's quality rating, metrics, and feedback status. Use this to see how well Claude is performing in the current session.

## What It Shows

1. **Session Quality Rating** (0-10)
   - 10/10 = Excellent (no corrections needed)
   - 7/10 = Good (1-2 minor corrections)
   - 5/10 = Needs Improvement (3+ corrections)

2. **Session Metrics**
   - Duration
   - Files tracked
   - Commits made
   - Corrections count

3. **Quality Analysis**
   - What's going well
   - What needed correction
   - Business context learned
   - Patterns reinforced

## Usage

```
/session-feedback
```

## Example Output

```
═══════════════════════════════════════════════════════
📊 SESSION FEEDBACK - mem-2025-11-09-abc123
═══════════════════════════════════════════════════════

Rating: 7/10 (Good)
Duration: 1h 45m
Files Tracked: 12
Commits: 2
Corrections: 1

✅ What Went Well:
- OAuth2 implementation was correct first try
- API structure matched existing patterns
- Tests were comprehensive

⚠️ What Needed Correction:
- Initially suggested JWT instead of OAuth2 tokens (corrected)

📚 Business Context Learned:
- This project uses OAuth2 password flow
- All auth goes through middleware layer

🎯 Patterns Reinforced:
- Service layer pattern (12/12 times)
- RESTful API naming (100%)

═══════════════════════════════════════════════════════
```

## Rating System

The rating is calculated based on:

```
corrections_count = 0  → rating = 10 (Excellent)
corrections_count ≤ 2  → rating = 7  (Good)
corrections_count > 2  → rating = 5  (Needs Improvement)
```

## When This Updates

The feedback is continuously updated throughout the session:
- Each correction via `/correct` reduces the rating
- Each successful pattern application improves context
- Session-end summarizes everything

## What Happens at Session End

At the end of your session, this feedback is automatically:
1. Stored in memory via `memory__feedback` tool
2. Saved to `.claude-memory-feedback.md`
3. Used to improve future session performance

## How It Helps

**For You:**
- See if Claude is understanding your requirements
- Catch patterns of mistakes early
- Validate that corrections are being tracked

**For Claude:**
- Learn what works and what doesn't
- Improve performance in future sessions
- Build better context awareness

## Best Practices

### Check feedback:
- **After checkpoints** - Did corrections lower the rating?
- **Before commits** - Is the work quality where you want it?
- **End of session** - Overall session performance review

### If rating is low (≤ 5):
1. Review what corrections were needed
2. Consider if more context is needed (update CLAUDE.md)
3. Use `/memory-sync` to ensure learnings are stored

## Related Commands

- `/checkpoint` - Trigger progress validation
- `/correct` - Record a correction (lowers rating)
- `/memory-feedback` - Manually submit feedback to memory store
- `/memory-overview` - See long-term memory store status

---

View current session quality and feedback metrics.

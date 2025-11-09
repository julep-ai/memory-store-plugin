---
description: Manually trigger a progress checkpoint to validate current work
---

# Checkpoint Command

Triggers an interactive progress validation checkpoint. Use this when you want to:
- Review what's been completed so far in the session
- Validate that Claude's work matches your expectations
- Check if any corrections are needed
- Decide whether to commit current progress

## What It Does

1. Shows session metrics (files changed, LOC, duration)
2. Displays goals: completed ✅ vs in-progress ⏳
3. Asks validation questions:
   - Are changes matching expectations?
   - Is the approach correct?
   - Any corrections needed?
   - Should we commit?

## Usage

```
/checkpoint
```

## When to Use

- After significant work (already auto-triggers every 10 file changes)
- Before committing to review everything
- When you want to course-correct mid-session
- To validate Claude understood your requirements

## Example Output

```
╔══════════════════════════════════════════════════════════╗
║           📊 PROGRESS CHECKPOINT                         ║
╠══════════════════════════════════════════════════════════╣
║  Session: mem-2025-11-09-abc123                          ║
║  Changes: 15 file operations completed                   ║
║  Files modified: 8                                       ║
║                                                          ║
║  ✅ Completed:                                           ║
║    ✓ OAuth2 authentication setup                        ║
║    ✓ Login/logout API endpoints                         ║
║                                                          ║
║  ⏳ In Progress:                                         ║
║    → Writing authentication tests                       ║
║                                                          ║
║  🤔 Is this matching your expectations?                  ║
╚══════════════════════════════════════════════════════════╝
```

## Related Commands

- `/memory-sync` - Sync all changes to memory store
- `/session-feedback` - View current session quality rating
- `/validate-changes` - Pre-commit validation

---

Run the progress checkpoint script to validate current work.

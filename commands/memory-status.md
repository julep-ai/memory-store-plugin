---
description: View current memory tracking status and statistics
---

# Memory Status

Displays the current session tracking status, showing what files have been modified, commits analyzed, and context stored during this session.

## What this command shows

1. **Session information**: Current session ID, duration, and start time
2. **Files tracked**: List of files modified in this session
3. **Commits analyzed**: Recent commits that have been processed
4. **Context stored**: Number of memories recorded
5. **Memory store statistics**: Total memories, last sync time

## Usage

```
/memory-status
```

## Options

```
/memory-status --detailed
/memory-status --json
```

## Example Output

```
User: /memory-status

Claude: Memory Tracking Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Session Information:
  Session ID: mem-2025-01-15-abc123
  Duration: 2h 45m
  Started: 2025-01-15 09:30:00

Files Tracked (8):
  ✓ src/api/auth.ts - Modified 15 minutes ago
  ✓ src/components/Login.tsx - Modified 20 minutes ago
  ✓ tests/auth.test.ts - Created 30 minutes ago
  ✓ CLAUDE.md - Updated anchor comments
  ... (4 more files)

Commits Analyzed (3):
  ✓ feat: add OAuth2 authentication flow
  ✓ test: add auth integration tests
  ✓ docs: update CLAUDE.md with auth patterns

Context Stored:
  - 12 development decisions recorded
  - 5 pattern implementations tracked
  - 3 business logic rules captured

Memory Store:
  Total memories: 247
  Last sync: 5 minutes ago
  Status: ✓ Connected

Next automatic sync: in 10 minutes
```

## Related Commands

- `/memory-sync` - Manually sync to memory
- `/memory-context` - Retrieve relevant context
- `/memory-overview` - Generate project overview

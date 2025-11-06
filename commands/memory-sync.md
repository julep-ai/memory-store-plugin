---
description: Manually synchronize current project state to memory store
---

# Memory Sync

Synchronizes the current project state, git history, CLAUDE.md files, and anchor comments to the memory store. Use this command to ensure all context is captured and stored.

## What this command does

1. **Captures project snapshot**: Records current file structure and key files
2. **Syncs git history**: Analyzes recent commits and branching strategy
3. **Updates CLAUDE.md**: Syncs all CLAUDE.md files and anchor comments
4. **Stores session context**: Saves current development context and decisions
5. **Updates project overview**: Refreshes the comprehensive project understanding

## Usage

```
/memory-sync
```

## Options

You can optionally specify what to sync:

```
/memory-sync --git-only
/memory-sync --claude-md-only
/memory-sync --full
```

## When to use

- At the end of a major feature development
- Before switching to a different task
- When you want to ensure team members have latest context
- After important architectural decisions
- When onboarding new team members

## Example

```
User: /memory-sync
Claude: Synchronizing project state to memory store...
✓ Captured current file structure
✓ Analyzed 15 recent commits
✓ Synced 3 CLAUDE.md files with anchor comments
✓ Stored session context and decisions
✓ Updated project overview

Memory store updated successfully! Team members will now have access to this context.
```

## Related Commands

- `/memory-status` - View current tracking status
- `/memory-context` - Retrieve relevant context
- `/memory-overview` - Generate project overview

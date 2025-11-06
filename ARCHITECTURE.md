# Architecture Overview

Detailed architecture documentation for the Memory Store Tracker plugin.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code Session                      │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │   User     │  │   Agent    │  │   Skills   │           │
│  │ Commands   │  │  Memory    │  │  Context   │           │
│  │            │  │  Tracker   │  │ Retrieval  │           │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘           │
│        │               │               │                   │
└────────┼───────────────┼───────────────┼───────────────────┘
         │               │               │
         ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Plugin Layer                            │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Hook Event System                        │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │  │
│  │  │ Session  │ │ Session  │ │PostTool  │ │ Pre     │ │  │
│  │  │  Start   │ │   End    │ │   Use    │ │Compact  │ │  │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬────┘ │  │
│  └───────┼────────────┼────────────┼────────────┼───────┘  │
│          │            │            │            │          │
│          ▼            ▼            ▼            ▼          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Background Hook Scripts                     │  │
│  │                                                       │  │
│  │  session-start.sh    track-changes.sh                │  │
│  │  session-end.sh      analyze-commits.sh              │  │
│  │  save-context.sh     sync-claude-md.sh               │  │
│  │  project-overview.sh                                 │  │
│  └──────────────────────┬───────────────────────────────┘  │
│                         │                                   │
└─────────────────────────┼───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   MCP Server Layer                           │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Memory MCP Server                          │  │
│  │                                                       │  │
│  │  memory_record     memory_recall     memory_overview │  │
│  └──────────────────────┬───────────────────────────────┘  │
│                         │                                   │
└─────────────────────────┼───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     Memory Store                             │
│                  (Cloud/Local Storage)                       │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Development  │  │     Team     │  │   Business   │     │
│  │  Patterns    │  │ Conventions  │  │    Logic     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Decision   │  │     Git      │  │  CLAUDE.md   │     │
│  │   History    │  │   Patterns   │  │    Docs      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Component Interaction Flow

### 1. Session Lifecycle

```
User starts Claude Code
        ↓
SessionStart Hook fires
        ↓
session-start.sh executes
        ↓
┌─────────────────────┐
│ Initialize tracking │
│ Load context        │
│ Capture state       │
└─────────────────────┘
        ↓
memory_record (session start)
        ↓
Development work begins
        ↓
        ... (file changes, commits, etc.)
        ↓
User exits Claude Code
        ↓
SessionEnd Hook fires
        ↓
session-end.sh executes
        ↓
┌─────────────────────┐
│ Summarize session   │
│ Store learnings     │
│ Update overview     │
└─────────────────────┘
        ↓
memory_record (session summary)
```

### 2. File Change Tracking

```
User: "Create a new file auth.ts"
        ↓
Claude uses Write tool
        ↓
PostToolUse Hook fires (matcher: "Write")
        ↓
track-changes.sh executes
        ↓
┌─────────────────────────────┐
│ Detect file type            │
│ Identify pattern (API, UI)  │
│ Check if CLAUDE.md          │
│ Update session tracking     │
└─────────────────────────────┘
        ↓
If CLAUDE.md → sync-claude-md.sh (async)
        ↓
memory_record (file change + pattern)
        ↓
Context available for future queries
```

### 3. Git Commit Analysis

```
User commits code
        ↓
Claude executes: git commit -m "feat: add auth"
        ↓
PostToolUse Hook fires (matcher: "bash.*git commit")
        ↓
analyze-commits.sh executes
        ↓
┌─────────────────────────────────┐
│ Parse commit message            │
│ Detect type (feat, fix, etc)    │
│ Identify files changed          │
│ Check for breaking changes      │
│ Extract ticket number           │
└─────────────────────────────────┘
        ↓
memory_record (commit context + metadata)
        ↓
Commit history enriched with context
```

### 4. Context Retrieval

```
User: "How should I implement authentication?"
        ↓
Memory Context Retrieval Skill activates (auto)
        ↓
memory_recall (cues: ["authentication", "implement"])
        ↓
Memory Store returns relevant context
        ↓
┌─────────────────────────────────┐
│ Past auth implementations       │
│ Team decisions on auth          │
│ Established patterns            │
│ Related CLAUDE.md sections      │
└─────────────────────────────────┘
        ↓
Claude: "Based on our established OAuth2 pattern
         (see src/api/auth.ts:45)..."
```

### 5. Manual Sync

```
User: /memory-sync
        ↓
Command handler executes
        ↓
┌─────────────────────────────────┐
│ Run project-overview.sh         │
│ Run sync-claude-md.sh           │
│ Capture git history             │
│ Store current state             │
└─────────────────────────────────┘
        ↓
Multiple memory_record calls
        ↓
User: "✓ Memory store updated successfully!"
```

## Data Flow Patterns

### Pattern 1: Automatic Context Capture

```
Developer Action → Hook Trigger → Script Execution → Memory Store
     ↓                                                    ↓
Development Flow                              Context Database
     ↓                                                    ↓
Next Action      ← Skill Retrieval ← memory_recall ← Stored Context
```

### Pattern 2: Team Knowledge Sharing

```
Developer A                    Developer B
     ↓                              ↓
Makes changes                  Starts session
     ↓                              ↓
Hook captures                  Hook loads context
     ↓                              ↓
memory_record              memory_recall
     ↓                              ↓
     └──→ Shared Memory Store ←────┘
              ↓
     Available to entire team
```

### Pattern 3: Pattern Evolution

```
First Implementation
     ↓
  Captured → memory_record
     ↓
Second Implementation
     ↓
  Skill retrieves past pattern
     ↓
  Suggests following pattern
     ↓
Third Implementation
     ↓
  Pattern becomes established
     ↓
  Auto-suggested for all new work
```

## Hook Event Details

### SessionStart Hook

**Trigger**: When Claude Code session begins  
**Script**: `session-start.sh`  
**Actions**:
1. Generate unique session ID
2. Capture project state
3. Get git info (branch, commit, history)
4. Find CLAUDE.md files
5. Load relevant context from memory
6. Create session marker file

**Memory Storage**:
```json
{
  "memory": "Session started in project X on branch main",
  "background": "Session ID, file count, git state",
  "importance": "normal"
}
```

### SessionEnd Hook

**Trigger**: When Claude Code session ends  
**Script**: `session-end.sh`  
**Actions**:
1. Calculate session duration
2. Count files tracked
3. Count commits analyzed
4. Get session commits
5. Sync CLAUDE.md one last time
6. Store session summary

**Memory Storage**:
```json
{
  "memory": "Session completed: duration, files, commits",
  "background": "Detailed session metrics",
  "importance": "normal"
}
```

### PostToolUse Hook (Write/Edit)

**Trigger**: After Write or Edit tool usage  
**Script**: `track-changes.sh`  
**Actions**:
1. Get file path from tool call
2. Determine change type (new/modified)
3. Identify file language
4. Detect patterns (API, UI, Service, Test)
5. Check if CLAUDE.md
6. Update session tracking

**Memory Storage**:
```json
{
  "memory": "File created: path (language). Pattern: X",
  "background": "Session ID, file details, pattern",
  "importance": "low"
}
```

### PostToolUse Hook (Git Commit)

**Trigger**: After git commit command  
**Script**: `analyze-commits.sh`  
**Actions**:
1. Get commit hash and message
2. Parse conventional commit type
3. Get files changed
4. Calculate diff stats
5. Check for breaking changes
6. Extract ticket numbers
7. Analyze branching strategy

**Memory Storage**:
```json
{
  "memory": "Commit: message (type)",
  "background": "Commit details, files, breaking changes",
  "importance": "high (if breaking) or normal"
}
```

### PreCompact Hook

**Trigger**: Before conversation history compaction  
**Script**: `save-context.sh`  
**Actions**:
1. Capture current git state
2. Get recent file modifications
3. Find TODO comments
4. Check CLAUDE.md updates
5. Create context snapshot

**Memory Storage**:
```json
{
  "memory": "Context saved before compaction",
  "background": "Branch, changes, recent activity",
  "importance": "normal"
}
```

## Memory Store Schema

### Development Pattern

```json
{
  "type": "pattern",
  "name": "service-layer-pattern",
  "location": "src/services/",
  "description": "All business logic in service layer",
  "example": "src/services/auth.ts",
  "usage_count": 15,
  "established_date": "2025-01-15"
}
```

### Team Convention

```json
{
  "type": "convention",
  "category": "commits",
  "rule": "Conventional commits required",
  "enforcement": "CI check",
  "examples": ["feat:", "fix:", "docs:"]
}
```

### Decision History

```json
{
  "type": "decision",
  "topic": "database-choice",
  "decision": "Use PostgreSQL",
  "reasoning": "ACID compliance, complex relationships",
  "date": "2024-10-15",
  "participants": ["@john", "@jane"]
}
```

### Git Pattern

```json
{
  "type": "git-pattern",
  "pattern": "feature-branch-workflow",
  "branches": ["main", "develop", "feature/*"],
  "merge_strategy": "squash",
  "pr_required": true
}
```

### CLAUDE.md Context

```json
{
  "type": "documentation",
  "file": "CLAUDE.md",
  "anchors": ["<!-- AUTH-FLOW -->", "<!-- API-SECURITY -->"],
  "sections": ["Authentication", "API Guidelines"],
  "last_updated": "2025-01-15"
}
```

## Performance Considerations

### Asynchronous Execution

All hooks run asynchronously to avoid blocking Claude Code:

```bash
hook-script.sh &  # Runs in background
```

### Efficient File Operations

- Use `find` with limits
- Cache recent results
- Avoid reading large files
- Smart pattern matching

### Memory Storage

- Store only relevant context
- Use appropriate importance levels
- Batch similar operations
- Deduplication where possible

## Security

### Token Management

- Tokens stored in plugin config
- Not committed to git (in .gitignore)
- Team members use individual tokens
- Tokens never logged

### Script Safety

- All scripts use `set -euo pipefail`
- Input validation where needed
- No eval or dangerous commands
- Proper quoting of variables

### Privacy

- No sensitive data in logs
- File content not stored (only metadata)
- Commit messages may contain sensitive info (user discretion)

## Extensibility Points

### 1. Add New Hooks

Edit `hooks/hooks.json`:

```json
{
  "hooks": {
    "YourEvent": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/your-script.sh"
          }
        ]
      }
    ]
  }
}
```

### 2. Add New Commands

Create `commands/your-command.md`:

```markdown
---
description: Your command description
---

# Your Command

Documentation here...
```

### 3. Add MCP Servers

Edit `.mcp-extensions.json`:

```json
{
  "mcpServers": {
    "your-service": {
      "command": "npx",
      "args": ["@your/mcp-server"],
      "env": {
        "API_KEY": "your-key"
      }
    }
  }
}
```

### 4. Custom Skills

Create `skills/your-skill/SKILL.md`:

```markdown
---
description: Your skill description
capabilities: ["capability1", "capability2"]
---

# Your Skill

When to invoke...
```

## Troubleshooting Architecture

### Hook Not Firing

1. Check hook configuration in `hooks/hooks.json`
2. Verify matcher pattern
3. Test script manually: `bash scripts/your-script.sh`
4. Check Claude Code debug output: `claude --debug`

### Script Errors

1. Check script permissions: `ls -l scripts/`
2. Run script manually to see errors
3. Verify `${CLAUDE_PLUGIN_ROOT}` is set
4. Check for syntax errors: `bash -n script.sh`

### Memory Store Issues

1. Verify MCP server connection
2. Check token validity
3. Test memory tools directly
4. Review network connectivity

## Best Practices

### Hook Scripts

- ✅ Use `set -euo pipefail`
- ✅ Log to stderr with timestamps
- ✅ Handle errors gracefully
- ✅ Run asynchronously when possible
- ✅ Keep execution time minimal

### Memory Storage

- ✅ Use descriptive memory text
- ✅ Include rich background context
- ✅ Set appropriate importance
- ✅ Link related memories
- ✅ Structure data consistently

### Team Collaboration

- ✅ Share plugin via git
- ✅ Document custom hooks
- ✅ Maintain CLAUDE.md files
- ✅ Use shared memory store
- ✅ Regular syncs

---

This architecture enables seamless context tracking, intelligent retrieval, and effective team collaboration through the Memory Store Tracker plugin.

# Memory Store Plugin - Complete User Guide

> **Give Claude persistent memory across sessions.** Claude remembers your corrections, patterns, decisions, and team knowledge—learning from every mistake instead of repeating them.

## What Is This Plugin?

The Memory Store Plugin transforms Claude Code from a session-based assistant into a **learning development partner** with persistent memory. It automatically tracks your development work, learns from corrections, and provides intelligent context without you asking.

### The Problem It Solves

**Before Memory Store:**
```
Day 1: "We use OAuth2 for auth"
Day 2: Claude suggests JWT (forgot!)
Day 3: "No, we use OAuth2" (explaining again!)
Day 4: Repeat... 😤
```

**With Memory Store:**
```
Day 1: "We use OAuth2 for auth" → Stored automatically
Day 2: Claude remembers: "Based on our memory, we use OAuth2"
Day 3+: Never asks again ✅
```

## How It Works

### 1. Automatic Tracking (Background)

The plugin **automatically captures** as you work:

```
You start Claude Code
    ↓
📊 Session tracking begins
    ↓
You edit files
    ↓
📝 File changes tracked (what, when, where)
    ↓
You make git commits
    ↓
🔍 Commit patterns analyzed
    ↓
You make a mistake / Claude gets corrected
    ↓
🎯 Correction captured automatically
    ↓
You close Claude Code
    ↓
💾 Session summary stored
```

**Everything happens in the background—no manual work needed!**

### 2. Context Retrieval (Automatic)

Claude **proactively retrieves context** when:

- ✅ You ask about a feature → Recalls past work
- ✅ You start a task → Surfaces similar implementations
- ✅ You make a decision → Checks past decisions
- ✅ You mention a person → Shows their expertise area

**Frequency:** Context is retrieved:
- **At session start** - Loads relevant project memory
- **During conversation** - When topics match stored memories
- **Before suggestions** - Checks for established patterns
- **Every ~5-10 messages** - Proactive context checks

### 3. Learning from Mistakes (Automatic)

When you say things like:
- "That's wrong"
- "No, that's incorrect"
- "We don't use that"
- "That failed"

**→ Automatic feedback capture fires**
**→ High-priority memory stored**
**→ Claude never makes that mistake again**

## What It Tracks

### 📊 Development Activity

| What | How | When |
|------|-----|------|
| **File Changes** | Every Write/Edit operation | Real-time |
| **Git Commits** | Commit messages, authors, files | After each commit |
| **Patterns** | Code patterns, naming conventions | Continuously |
| **Decisions** | Technical choices, architecture | When discussed |

### 👥 Team Knowledge

| What | How | When |
|------|-----|------|
| **Ownership** | Who commits where | Every commit |
| **Expertise** | Areas of specialization | Pattern analysis |
| **Collaboration** | Team workflows | Git activity |
| **Knowledge Gaps** | Untouched code areas | Regular analysis |

### 📝 Documentation Quality

| What | How | When |
|------|-----|------|
| **Anchor Comments** | `<!-- ANCHOR -->` usage | File changes |
| **Cross-references** | Code ↔ docs links | Write operations |
| **Orphaned Anchors** | Unused documentation | Analysis |
| **Documentation Gaps** | Missing anchor suggestions | Pattern detection |

### 🎯 Quality & Feedback

| What | How | When |
|------|-----|------|
| **Errors** | Mistake corrections | When you say "wrong" |
| **Session Quality** | Success vs error rate | Continuous |
| **Patterns** | Repeated mistakes | Analysis |
| **Learning** | What Claude improved | Over time |

## Available Commands

### Core Memory Commands

#### `/memory-record`
**What:** Manually store important information to memory
**When to use:** After major decisions, completed features, or important discussions
**Example:**
```
/memory-record "We decided to use PostgreSQL for ACID compliance. MongoDB was rejected due to consistency concerns. Decision made Nov 13, 2025."
```

#### `/memory-recall [query]`
**What:** Retrieve relevant context from past work
**When to use:** Starting new work, code reviews, decision-making
**Example:**
```
/memory-recall authentication patterns
→ Retrieves: "We use OAuth2 password flow. See src/api/auth.ts:45"

/memory-recall why did we choose PostgreSQL
→ Retrieves: Past decision with reasoning
```

#### `/memory-overview`
**What:** Generate comprehensive project overview
**When to use:** Onboarding, documentation, stakeholder updates
**Example:**
```
/memory-overview
→ Generates: Architecture, patterns, conventions, decisions, ownership
```

### Tracking & Status

#### `/memory-status`
**What:** View current session tracking statistics
**When to use:** Check what's being captured this session
**Example:**
```
/memory-status
→ Shows: Files changed (12), Commits (3), Errors (1), Quality (92%)
```

#### `/memory-anchors`
**What:** View anchor comment usage across project
**When to use:** Documentation review, quality checks
**Example:**
```
/memory-anchors
→ Shows: Total anchors (24), Most referenced, Orphaned, Cross-refs
```

#### `/memory-ownership`
**What:** View code ownership and expertise map
**When to use:** Planning, code reviews, finding experts
**Example:**
```
/memory-ownership
→ Shows: Who owns what, Expertise areas, Knowledge gaps
```

### Feedback & Quality

#### `/correct "explanation"`
**What:** Manually record a high-priority correction
**When to use:** Important mistakes that must be remembered
**Example:**
```
/correct "Never use JWT tokens. We use OAuth2 password flow for all authentication due to PCI compliance requirements."
```

**Note:** Usually automatic! Just saying "that's wrong" triggers auto-capture.

#### `/session-feedback`
**What:** View current session quality rating
**When to use:** Check how session is going
**Example:**
```
/session-feedback
→ Shows: Quality score, Corrections needed, Success rate
```

#### `/checkpoint`
**What:** Trigger validation checkpoint
**When to use:** After completing major work
**Example:**
```
/checkpoint
→ Asks: "Are things going well? Any issues to address?"
```

### Pre-Commit Validation

#### `/validate-changes`
**What:** Review changes before committing (security checks)
**When to use:** Before git commits
**Example:**
```
/validate-changes
→ Checks: Secrets, debug code, TODO comments, code quality
```

**Note:** Runs automatically on `git add`!

## Command Pattern: Record-Recall

The plugin follows the **record-recall pattern** matching the MCP tools:

```
RECORD (Store information):
  /memory-record        - Manually store memory
  Automatic recording   - Happens continuously in background

RECALL (Retrieve information):
  /memory-recall        - Query stored memories
  Automatic retrieval   - Happens during conversation

OVERVIEW (Synthesize):
  /memory-overview      - Generate comprehensive summary

STATUS (Monitor):
  /memory-status        - Check tracking statistics
  /memory-anchors       - Documentation quality
  /memory-ownership     - Team expertise map
```

This aligns perfectly with the underlying MCP server tools:
- `memory_record` → `/memory-record`
- `memory_recall` → `/memory-recall`
- `memory_overview` → `/memory-overview`

## Session Lifecycle

### 1. Session Start (Automatic)

```
You: claude
    ↓
Plugin: SessionStart hook fires
    ↓
Actions:
  ✓ Create session ID (e.g., mem-2025-11-13-abc123)
  ✓ Capture project state (git branch, files, etc.)
  ✓ Load relevant context from memory
  ✓ Initialize tracking counters
    ↓
Result: Claude has context from previous sessions!
```

**What you see:**
```
Claude Code starts normally, but Claude already knows:
- Past decisions
- Established patterns
- Your preferences
- Team conventions
```

### 2. During Session (Automatic)

**Every 5-10 messages:**
```
Background process:
  → Check conversation topics
  → Query memory for relevant context
  → Surface patterns/decisions if relevant
  → Continue conversation
```

**On file changes:**
```
You: Edit src/auth.ts
    ↓
Hook fires (async):
  ✓ Track file change
  ✓ Detect language/pattern
  ✓ Check for anchor comments
  ✓ Record to memory
    ↓
You: Continue working (not blocked!)
```

**On git commits:**
```
You: git commit -m "feat: add auth"
    ↓
Hooks fire (async):
  ✓ Analyze commit message
  ✓ Track ownership
  ✓ Detect patterns
  ✓ Record to memory
    ↓
You: Continue working (not blocked!)
```

**On errors/corrections:**
```
You: "That's wrong, we use OAuth2"
    ↓
Hook fires (async):
  ✓ Detect "wrong" keyword
  ✓ Capture context
  ✓ High-priority memory
  ✓ Record for learning
    ↓
Claude: Learns immediately!
```

### 3. Session End (Automatic)

```
You: exit (or Ctrl+D)
    ↓
Plugin: SessionEnd hook fires
    ↓
Actions:
  ✓ Summarize session activity
  ✓ Count: files changed, commits made, errors
  ✓ Calculate quality score
  ✓ Store session summary
  ✓ Record key learnings
    ↓
Result: All knowledge preserved for next session!
```

**What's stored at session end:**
```json
{
  "session_id": "mem-2025-11-13-abc123",
  "duration": "2h 45m",
  "files_changed": 12,
  "commits": 3,
  "errors_corrected": 1,
  "quality_score": 92,
  "key_learnings": [
    "Added OAuth2 authentication",
    "Team uses PostgreSQL",
    "Alice owns backend API"
  ]
}
```

### 4. Next Session (Automatic Loading)

```
You: claude (next day)
    ↓
Plugin: SessionStart hook fires
    ↓
Actions:
  ✓ Load memories from previous sessions
  ✓ Retrieve relevant project context
  ✓ Surface recent decisions
  ✓ Apply learned corrections
    ↓
Result: Claude remembers everything!
```

**Example:**
```
Next Day Session:

You: "I need to add user authentication"

Claude: "Based on our memory, we use OAuth2 password flow
for authentication (decided yesterday). I'll follow that
pattern. See src/api/auth.ts:45 for the established
implementation."

[Without plugin: Claude would suggest various options,
not knowing your preference]
```

## Context Retrieval Frequency

### Automatic Retrieval Triggers

| Trigger | Frequency | Example |
|---------|-----------|---------|
| **Session Start** | Once per session | Loads project context |
| **Conversation Topic** | When keywords match | "auth" → recalls auth patterns |
| **Before Suggestions** | Every major suggestion | Checks established patterns |
| **Proactive Checks** | Every 5-10 messages | Background context refresh |
| **Decision Points** | When you ask "should we..." | Recalls past decisions |
| **Code Changes** | Per file operation | Pattern matching |

### Smart Context Loading

The plugin uses **intelligent context retrieval**:

```
High Relevance (Immediate):
  - Exact keyword matches
  - Recent decisions (last 7 days)
  - High-priority corrections

Medium Relevance (Background):
  - Related patterns
  - Similar past work
  - Team conventions

Low Relevance (Cached):
  - General project knowledge
  - Historical decisions
  - Rarely used patterns
```

## What Makes It Useful?

### For Individual Developers

✅ **Stop Repeating Yourself**
- Explain decisions once, not every session
- Corrections stick forever
- Preferences remembered

✅ **Better Code Quality**
- Follows established patterns automatically
- Suggests proven solutions
- Avoids past mistakes

✅ **Faster Development**
- Context loaded automatically
- No manual documentation search
- Intelligent suggestions

### For Teams

✅ **Knowledge Sharing**
- Everyone sees what everyone knows
- New members onboard faster
- Expertise map visible

✅ **Consistency**
- Everyone follows same patterns
- Decisions are documented automatically
- Standards maintained

✅ **Reduced Bus Factor**
- Knowledge distributed
- Ownership clear
- Gaps identified

### For Projects

✅ **Living Documentation**
- Always up-to-date
- Generated from actual work
- Reflects reality, not wishes

✅ **Decision History**
- Why was this chosen?
- What was rejected?
- When was it decided?

✅ **Quality Tracking**
- Error patterns identified
- Improvements measured
- Learning visible

## Privacy & Data

### What's Stored

✅ **Stored in Memory:**
- File names and patterns (not full content)
- Commit messages and metadata
- Decisions and corrections
- Team activity patterns
- Documentation references

❌ **NOT Stored:**
- Sensitive credentials
- API keys or tokens
- Full file contents
- Private conversations (unless explicitly recorded)

### Where It's Stored

- **Cloud:** beta.memory.store (OAuth secured)
- **Local:** Session tracking files (.claude-*)
- **Access:** Only you and your authenticated team

### Control

You control what's stored:
- `/memory-record` - Explicit storage
- Automatic tracking can be paused
- Memories can be deleted
- Privacy is respected

## Troubleshooting

### Plugin Not Working?

```bash
# 1. Check installation
ls ~/.claude/plugins/marketplaces/claude-plugin/

# 2. Verify MCP connection
claude mcp list
# Should show: ✓ Connected

# 3. Check hooks
cat hooks/hooks.json | jq .

# 4. Test script manually
bash scripts/session-start.sh
```

### Memories Not Persisting?

```bash
# Check MCP server connection
claude mcp list

# Re-authenticate if needed
claude mcp remove memory-store
claude mcp add --transport http memory-store "https://beta.memory.store/mcp"
```

### Hooks Not Firing?

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Check hooks configuration
cat hooks/hooks.json
```

## Advanced Usage

### Custom Memory Recording

Store business context with decisions:
```
/memory-record "Database Choice: PostgreSQL selected over MongoDB. Reasons: ACID compliance required for financial transactions, complex relationships, team expertise. Stakeholder: Security Team. Date: 2025-11-13. Criticality: HIGH"
```

### Team Onboarding

Generate comprehensive overview:
```
/memory-overview

Save output to share with new team members.
Includes: Architecture, patterns, conventions, ownership, decisions.
```

### Code Review Prep

Check ownership before reviewing:
```
/memory-ownership frontend

See: Who owns frontend (90% commits by Bob)
Action: Request Bob as reviewer
```

### Documentation Audit

Check anchor usage:
```
/memory-anchors

Identify: Orphaned anchors, Missing documentation, Cross-ref gaps
Action: Clean up or add missing anchors
```

## Best Practices

### ✅ Do This

1. **Let it run** - Don't disable hooks, let automatic tracking work
2. **Correct naturally** - Just say "that's wrong" when needed
3. **Use conventional commits** - `feat:`, `fix:`, `docs:` help tracking
4. **Add anchor comments** - Use `<!-- ANCHOR -->` for important sections
5. **Trust the memory** - Let Claude recall context automatically

### ❌ Avoid This

1. Don't manually record everything (automatic is better)
2. Don't disable automatic feedback capture
3. Don't skip commit messages
4. Don't ignore pattern suggestions
5. Don't forget it learns continuously

## Summary

**The Memory Store Plugin is your development memory:**

- 🧠 **Learns automatically** - No manual work
- 🔄 **Persists across sessions** - Never forgets
- 👥 **Shares team knowledge** - Everyone benefits
- 📊 **Tracks patterns** - Gets smarter over time
- 🎯 **Prevents mistakes** - Learns from corrections
- 🚀 **Accelerates development** - Context always available

**Just work normally—the plugin handles the rest!**

---

## Quick Reference

```bash
# Installation
/plugin marketplace add julep-ai/memory-store-plugin
/plugin install memory-store@claude-plugin

# Core Commands
/memory-record "important decision"   # Store manually
/memory-recall [query]                # Retrieve context
/memory-overview                      # Project summary

# Status & Tracking
/memory-status                        # Session stats
/memory-anchors                       # Documentation quality
/memory-ownership                     # Team expertise

# Feedback
/correct "explanation"                # High-priority correction
/session-feedback                     # Quality score
```

**Remember:** Most features are automatic—just use Claude Code naturally!

## Development Journey Tracking

Beyond tracking WHAT you build, the plugin captures HOW Claude helped you build it—creating a valuable "lessons learned" database.

### 1. Tech Stack Recognition

**Automatic Detection:**
```
Session starts in your project
    ↓
Plugin analyzes:
  • package.json → React, TypeScript, Express
  • requirements.txt → Python, Django, PostgreSQL
  • go.mod → Go, specific packages
    ↓
Records: "Project uses React + TypeScript frontend, Express backend, PostgreSQL database"
    ↓
Future sessions: Claude knows your stack automatically
```

**Benefits:**
- ✅ Claude suggests stack-appropriate solutions
- ✅ Doesn't recommend incompatible tools
- ✅ Follows your tech choices consistently

**Example:**
```
Future Session:

You: "Add caching"

Claude: "Based on your stack (Node.js/Express), I'll use Redis.
This integrates well with your existing PostgreSQL setup."

[Without plugin: Might suggest incompatible solutions]
```

### 2. Task Completion Flow Tracking

**What Gets Captured:**
```
You: "Add user authentication"
    ↓
Claude's Approach:
  Step 1: Created auth.ts with OAuth2 setup
  Step 2: Added authentication middleware
  Step 3: Updated routes to use middleware
  Step 4: Added error handling
  Step 5: Created tests
    ↓
STORED: The complete flow, sequence, decisions made
    ↓
Future similar task: Follows proven successful approach
```

**Captured Details:**
- 📝 Order of implementation (what came first)
- 🤔 Decisions made along the way
- 🔧 Tools and patterns used
- ✅ What worked well
- ⚠️ What needed adjustments

**Example:**
```
Later:

You: "Add password reset functionality"

Claude: "Based on how we implemented authentication,
I'll follow the same pattern:
1. Auth endpoint (like we did in auth.ts)
2. Middleware for validation (same structure)
3. Error handling (consistent approach)
4. Tests (same testing pattern)

This ensures consistency with our established flow."
```

### 3. Bug & Error Tracking

**Automatic Capture:**
```
Error occurs:
  TypeError: Cannot read property 'user' of undefined
    ↓
Context: In auth middleware, req.session was null
    ↓
Solution: Added session check before accessing user
    ↓
STORED: Error → Context → Solution
    ↓
Future: Prevents same bug, suggests fix immediately
```

**What's Tracked:**
| Aspect | Example |
|--------|---------|
| **Error Type** | TypeError, ReferenceError, 404, etc. |
| **Context** | Where it occurred, what was being done |
| **Root Cause** | Session not initialized, null check missing |
| **Solution** | Added null check, initialized session first |
| **Prevention** | Always check session before access |

**Real-World Example:**
```
First Time:
You: "User login returns 500 error"
→ Debug process: Check logs, find session issue, fix
→ Solution: Initialize session middleware earlier
→ STORED: Session middleware must be before auth routes

Next Time:
You: "Add new authenticated endpoint"
Claude: "I'll place this route after session middleware
(learned from the session issue we debugged earlier)."

[Prevented the same bug!]
```

### 4. Pattern Evolution Learning

**How It Works:**
```
First Implementation:
  • Basic approach, some trial and error
  • Bugs encountered and fixed
  • Working solution achieved
    ↓
STORED: What worked, what didn't, final pattern
    ↓
Second Similar Task:
  • Claude recalls first implementation
  • Skips failed approaches
  • Uses proven pattern immediately
  • Fewer bugs, faster completion
    ↓
Third Task:
  • Pattern is now established
  • Automatic suggestion
  • Team consistency
```

**Example Evolution:**
```
Auth Implementation #1:
  • Tried JWT tokens → Security concerns
  • Switched to OAuth2 → Worked well
  • Added refresh tokens → Complete solution
  STORED: OAuth2 + refresh tokens is our pattern

Auth Implementation #2 (New feature):
  Claude: "I'll use OAuth2 with refresh tokens
  (established pattern from first auth implementation).
  This avoids the JWT issues we encountered."

Auth Implementation #3 (Team member):
  Claude: "Following team's OAuth2 pattern.
  Everyone uses this approach for consistency."
```

### 5. Stack-Specific Solutions

**Technology-Aware Suggestions:**

**For React + TypeScript Project:**
```
You: "Add form validation"

Claude: "I'll use React Hook Form with Zod schema validation
(TypeScript-first, matches your stack). This integrates well
with your existing TypeScript setup."
```

**For Python + Django Project:**
```
You: "Add form validation"

Claude: "I'll use Django Forms with validators
(matches your Django stack). This follows Django conventions
and integrates with your ORM."
```

**Stack Recognition Happens:**
- At session start (analyzes project files)
- When new dependencies added (tracks additions)
- From commit patterns (detects language usage)
- From file types created (identifies tech choices)

### 6. Relevance to Future Development

**Cross-Project Learning:**
```
Project A:
  • Built authentication with OAuth2
  • Debugged session issues
  • Established error patterns
    ↓
STORED in Memory Store
    ↓
Project B (months later):
  You: "Need authentication"
  Claude: "Based on your past work, OAuth2 worked well.
  Should we use the same approach? I remember the session
  pitfalls to avoid."
```

**Benefits:**
- ✅ Don't repeat mistakes across projects
- ✅ Reuse successful patterns
- ✅ Faster development (skip trial-and-error)
- ✅ Consistent quality across projects
- ✅ Team knowledge compounds over time

### 7. Bug Prevention Database

**Accumulated Wisdom:**
```
Over time, Memory Store builds:

Common Bugs Encountered:
  1. Session access before initialization → 12 times
     Fix: Always initialize session middleware first

  2. Null checks missing in auth → 8 times
     Fix: Add null checks before accessing user properties

  3. Race conditions in async operations → 5 times
     Fix: Use proper async/await patterns

Future Development:
  Claude proactively suggests fixes BEFORE bugs occur
  "I'll add a null check here (prevents the auth bug we've seen)"
```

### Summary: Learning Development Partner

The plugin transforms Claude from a **session-based assistant** into a **learning development partner** that:

- 📊 **Knows your stack** - Suggests appropriate solutions
- 🔄 **Learns your flow** - Follows proven approaches
- 🐛 **Remembers bugs** - Prevents repeated mistakes
- 📈 **Compounds knowledge** - Gets smarter over time
- 🎯 **Maintains consistency** - Same quality across projects

**The more you develop with it, the more valuable it becomes!**


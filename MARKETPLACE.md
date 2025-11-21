# Memory Store Plugin for Claude Code

> **Give Claude persistent memory. Stop re-explaining your codebase every session.**

Claude remembers corrections, patterns, and decisions—learning from mistakes instead of repeating them.

## What This Plugin Does

The Memory Store Plugin transforms Claude Code into a **learning system** that:

- ✅ **Automatically tracks** your development work in the background
- ✅ **Remembers patterns** you establish across sessions
- ✅ **Loads context** automatically when you start coding
- ✅ **Searches memory** when you ask questions (no manual commands needed)
- ✅ **Preserves debugging context** so you never lose progress
- ✅ **Works with zero configuration** - install and go!

## Installation (3 Commands)

```bash
# 1. Add the plugin marketplace
claude plugin marketplace add julep-ai/memory-store-plugin

# 2. Install the plugin
claude plugin install memory-store

# 3. Connect to Memory Store
claude mcp add memory-store https://beta.memory.store/mcp
```

**That's it!** OAuth authentication will open in your browser. Authenticate once and you're done.

## How It Works

### Automatic Tracking (Zero Configuration)

The plugin runs silently in the background:

**Every file you edit:**
- Pattern detected (API, UI, Service, etc.)
- Stored with intelligent importance level
- Auto-generated files skipped (node_modules, build files, etc.)

**Every commit you make:**
- Analyzed for patterns and breaking changes
- Ticket references extracted
- Team ownership tracked

**Every session:**
- Project overview loaded automatically
- Recent work context recalled
- Debugging state preserved before compaction

**Every question you ask:**
- Memory automatically searched for relevant context
- Past patterns and decisions surfaced
- Team knowledge retrieved

### Ultra-Simple Commands

The plugin keeps things simple with just **3 commands**:

```bash
/memory-status     # Check tracking status
/memory-overview   # Get project snapshot
/memory-recall     # Manual search (usually automatic)
```

**Note**: You rarely need `/memory-recall` - Claude automatically searches memory when you ask questions!

## Real-World Examples

### Example 1: Pattern Consistency

**Day 1:**
```
You: "Create an API endpoint for user registration"
Claude: [implements with specific error handling]
```
*Pattern stored automatically*

**Day 3:**
```
You: "Create an API endpoint for user login"
Claude: "Following the API pattern we established in registration endpoint..."
        [implements with perfect consistency]
```

### Example 2: Never Lose Debugging Context

**Session 1 (Morning):**
```
You: "There's a bug in checkout - payment fails sometimes"
Claude: [investigates, finds potential race condition]
```
*Context compaction happens → PreCompact hook saves debugging state with HIGH importance*

**Session 2 (Afternoon):**
```
You: "Let's continue debugging"
Claude: "I remember we were investigating the race condition
         in payment processing. We identified 3 suspect areas..."
```

### Example 3: Team Knowledge Sharing

**Developer A implements something:**
*Memory auto-stores the pattern*

**Developer B (next week):**
```
You: "How do we handle database transactions?"
Claude: "Based on our project patterns, we use transaction
         wrappers with automatic rollback. See db/transaction.ts:23
         for the implementation Alice added last week."
```

## Key Features

### 🎯 Autonomous Operation
- All hooks run in background with zero latency
- Async execution never blocks your workflow
- Graceful failure handling

### 🧠 Intelligent Filtering
- Skips auto-generated files (node_modules, dist, build, logs)
- AI-driven importance detection
- ~70% reduction in tracked files - only meaningful changes

### 🔍 Automatic Memory Search
- Claude searches memory when you ask ANY question
- No manual commands needed
- Seamless conversation integration

### 📊 Session Context Loading
- Auto-loads project overview at session start
- Recalls recent work (last 5 memories)
- Claude starts every session with full project awareness

### 🐛 Debugging Context Preservation
- PreCompact hook saves debugging state with HIGH importance
- Never lose context after conversation compression
- Critical for multi-session debugging

## Performance

- ⚡ **Zero latency** - all operations run in background
- ⚡ **Non-blocking** - never interrupts your workflow
- ⚡ **Smart filtering** - 70% noise reduction
- ⚡ **Importance-based** - Memory Store prioritizes correctly

## Team Collaboration

Install the plugin on each developer's machine:
- Personal context captured locally
- Stored to shared memory store
- Available to all team members
- Perfect for onboarding, code reviews, and knowledge sharing

## Privacy & Security

- OAuth 2.1 authentication via browser
- No tokens in code or config files
- Memory stored securely at beta.memory.store
- Team memory shared only within your organization

## Documentation

- **[QUICKSTART.md](https://github.com/julep-ai/memory-store-plugin/blob/main/QUICKSTART.md)** - Get started in 60 seconds
- **[README.md](https://github.com/julep-ai/memory-store-plugin/blob/main/README.md)** - Complete guide with examples
- **[CHANGELOG.md](https://github.com/julep-ai/memory-store-plugin/blob/main/CHANGELOG.md)** - Version history
- **[USER_GUIDE.md](https://github.com/julep-ai/memory-store-plugin/blob/main/USER_GUIDE.md)** - Detailed usage guide

## Support

- **Issues**: [GitHub Issues](https://github.com/julep-ai/memory-store-plugin/issues)
- **Discussions**: [GitHub Discussions](https://github.com/julep-ai/memory-store-plugin/discussions)
- **Email**: developers@autotelic.inc

## What's New in v1.2.0

🚀 **Fully Autonomous System**:
- All hooks invoke MCP tools directly in background
- Zero configuration required
- Complete async execution

🧠 **Automatic Memory Search**:
- Claude automatically searches memory when you ask questions
- No manual `/memory-recall` needed
- Proactive skill enabled by default

⚡ **Ultra-Simplified**:
- Reduced from 11 → 3 commands (73% reduction)
- Intelligent filtering skips auto-generated files
- Session context auto-loaded at startup

See [CHANGELOG.md](https://github.com/julep-ai/memory-store-plugin/blob/main/CHANGELOG.md) for full release notes.

---

**Built with ❤️ by the Autotelic team for the Claude Code community.**

**License**: MIT

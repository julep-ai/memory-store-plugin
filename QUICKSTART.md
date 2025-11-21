# Memory Store Plugin - Quick Start Guide
## Get Started in 60 Seconds

**Version**: 1.2.3
**Goal**: Start using memory-powered development immediately

---

## ⚡ Installation (3 Steps)

```bash
# Step 1: Add the marketplace
claude plugin marketplace add julep-ai/memory-store-plugin

# Step 2: Install the plugin
claude plugin install memory-store

# Step 3: Add Memory Store MCP server
claude mcp add memory-store -t http https://beta.memory.store/mcp
```

**That's it!** Open any project and start coding:

```bash
cd your-project
claude
```

Memory tracking works automatically. Claude will proactively retrieve relevant context as you work.

---

## 🎯 What You Get (Automatic)

**Zero configuration needed** - everything works immediately:

- ✅ **File changes tracked** - Smart filtering (skips node_modules, build files, etc.)
- ✅ **Git commits analyzed** - Patterns, breaking changes, ticket references
- ✅ **Context loaded at session start** - Recent work and project overview
- ✅ **Debugging context preserved** - Never lose context after compaction
- ✅ **Intelligent retrieval** - Claude proactively recalls relevant patterns
- ✅ **AI decides importance** - High-value changes prioritized automatically
- ✅ **Transparent operation** - Brief confirmations: "💾 Saved to Memory Store..."

**Just code normally. Memory works in the background via queue-based processing.**

---

## 📝 Simple Commands (Optional)

Most things happen automatically, but you can manually check:

```bash
# See what's being tracked
/memory-status

# Get project overview
/memory-overview

# Manually search memory (usually automatic)
/memory-recall "topic"
```

**That's it - just 3 commands!**

**Note**: You usually don't need `/memory-recall` - Claude automatically searches memory when you ask questions!

---

## 🧪 Verify It's Working (30 seconds)

### Test 1: Session Start Check

When you start Claude Code, you should see:

```
✅ Memory Store MCP: Connected
```

If you see:
```
⚠️  Memory Store MCP: Not configured
   📝 To enable memory storage, run:
      claude mcp add memory-store -t http https://beta.memory.store/mcp
```

**Run that command** and restart Claude Code.

### Test 2: Check Status
```bash
/memory-status
```

You should see:
- ✅ Session ID
- ✅ Files tracked count
- ✅ Memory Store connection status

### Test 3: Make a Change
```bash
# Edit any file
# Then check:
/memory-status
```

You should see the "Files tracked" counter increase.

### Test 4: Query Memory
```bash
/memory-recall "recent changes"
```

You should see your recent work.

**If all four tests pass → You're fully set up! 🎉**

---

## 🚀 Real-World Usage Examples

### Example 1: Starting Your Day

```bash
# Open your project
# Session starts automatically
# Memory Store loads your recent context in background

You: "What was I working on yesterday?"

Claude: "Based on your recent work, you were implementing
         the user authentication flow. You completed the login
         endpoint and were about to add password reset.
         The pattern we established uses JWT with 15-min expiry."

# Context loaded automatically ✅
```

### Example 2: Building Consistent Features

**Day 1**:
```bash
You: "Create an API endpoint for user registration"
Claude: [implements with specific error handling pattern]
# Memory stores the pattern automatically
```

**Day 3**:
```bash
You: "Create an API endpoint for user login"

# With Mode 1 (Automatic):
Claude: [implements]
You: "Use the same pattern as registration"
Claude: "Let me search..."
        /memory-recall "registration endpoint pattern"
        "Found it! Following that pattern..."

# With Mode 2 (Intelligent):
Claude: [automatically recalls registration pattern]
        "Following the API pattern we established in registration endpoint..."
        [implements with perfect consistency]

# Mode 2 = Zero manual pattern enforcement ✅
```

### Example 3: Debugging Across Sessions

```bash
Session 1 (Morning):
  You: "There's a bug in checkout - payment fails sometimes"
  Claude: [investigates, finds potential race condition]
  # Context compaction happens (conversation gets too long)
  # PreCompact hook saves debugging context automatically

Session 2 (Afternoon):
  You: "Let's continue debugging"
  Claude: "I remember we were investigating the race condition
           in payment processing. We identified 3 suspect areas:
           1. Async payment.process() timing
           2. Stock validation check
           3. Order state transitions

           Let's test the payment timing first..."

# Zero context loss ✅
```

### Example 4: Team Knowledge

```bash
# Developer A implements something
[Memory auto-stores the pattern]

# Developer B (next week):
You: "How do we handle database transactions?"
Claude: "Based on our project patterns, we use transaction
         wrappers with automatic rollback. See db/transaction.ts:23
         for the implementation Alice added last week."

# Team knowledge preserved automatically ✅
```

---

## 🎯 Best Practices

### 1. Let It Run Automatically
```bash
✅ DO: Just code normally, memory tracks everything
❌ DON'T: Manually record every little thing
```

### 2. Use Commands When Needed
```bash
✅ DO: /memory-recall when you need to find something
✅ DO: /correct when Claude makes a mistake you want it to remember
❌ DON'T: Over-use commands, automation handles most things
```

### 3. Activate Intelligence for Complex Projects
```bash
✅ DO: Use "Skill: memory-auto-track" for teams/complex projects
✅ DO: Let Claude proactively follow patterns
❌ DON'T: Constantly re-explain patterns Claude already knows
```

### 4. Trust the System
```bash
✅ DO: Trust that context is being saved
✅ DO: Ask Claude "do you remember..." before re-explaining
❌ DON'T: Assume Claude forgot - it probably remembers!
```

---

## 🐛 Troubleshooting

### Issue: Memory status shows 0 files tracked

**Solution**:
```bash
# 1. Check if hooks are registered:
ls -la .claude/hooks/

# 2. Check session file exists:
ls -la .claude-session

# 3. Make a test edit and verify:
/memory-status
```

### Issue: "Memory Store connection failed"

**Solution**:
```bash
# Check MCP connection:
claude mcp list

# Should show "memory-store" in list
# If not, check ~/.config/claude/mcp.json
```

### Issue: Claude doesn't follow patterns automatically

**Solution**:
```bash
# Activate intelligent mode:
Skill: memory-auto-track

# OR manually recall:
/memory-recall "pattern for [thing]"
```

---

## 📊 Quick Wins

After installing, you'll immediately get:

**Week 1**:
- ✅ Complete session history
- ✅ All file changes tracked
- ✅ Git commits analyzed
- ✅ Context preserved across sessions

**Week 2**:
- ✅ Pattern consistency (with Mode 2)
- ✅ Faster development (patterns remembered)
- ✅ Zero context loss during debugging

**Month 1**:
- ✅ Complete project knowledge graph
- ✅ Team knowledge preserved
- ✅ Claude understands your codebase deeply
- ✅ Development velocity noticeably higher

---

## 🎓 Learning Path

### Day 1: Install & Verify
```bash
claude plugin install memory-store
/memory-status
# Make some changes, verify tracking works
```

### Day 2-7: Use Automatic Mode
```bash
# Just code normally
# Use /memory-recall when you need something
# Get comfortable with automatic tracking
```

### Week 2: Try Intelligent Mode
```bash
Skill: memory-auto-track
# Experience proactive pattern following
# Notice Claude following conventions automatically
```

### Week 3+: Master the System
```bash
# Explore all commands
# Use /correct for important corrections
# Use /memory-ownership to see team patterns
# Full integration into workflow
```

---

## 🚀 You're Ready!

**That's it!** You now have:

✅ Automatic memory tracking
✅ Context preservation across sessions
✅ Complete development history
✅ Pattern recognition (Mode 2)
✅ Team knowledge sharing

**Start coding, and watch Claude learn your project.**

---

## 📚 Next Steps

- Read [MEMORY_VALUE_GUIDE.md](./MEMORY_VALUE_GUIDE.md) for deeper understanding
- See [USER_GUIDE.md](./USER_GUIDE.md) for complete command reference
- Check [README.md](./README.md) for technical details

**Questions?** Just ask Claude:
```
"How does memory tracking work?"
"What commands are available?"
"How do I recall past decisions?"
```

Claude will help you! 🎉

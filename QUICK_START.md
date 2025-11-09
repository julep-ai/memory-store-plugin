# Quick Start Guide

Get up and running with the Memory Store plugin in 5 minutes.

**What this does:** Gives Claude persistent memory. Correct Claude once with `/correct "explanation"` and it remembers forever. No more repeating the same explanations every session.

## Installation (2 minutes)

1. **Get your memory token** from [memory.store](https://beta.memory.store)

2. **Navigate to your project**
   ```bash
   cd your-project
   ```

3. **Configure the token**
   
   Edit `.claude-plugin/plugin.json` and add your token:
   ```json
   {
     "mcpServers": {
       "memory": {
         "command": "npx",
         "args": [
           "mcp-remote",
           "https://beta.memory.store/mcp/?token=YOUR_TOKEN_HERE"
         ]
       }
     }
   }
   ```

4. **Start Claude Code**
   ```bash
   claude
   ```

## First Steps (3 minutes)

### 1. Check Status

```
/memory-status
```

See what's being tracked in your current session.

### 2. Make Some Changes

```
Create a new file called test.ts
```

The plugin will automatically track your changes. After 10 file operations, you'll see a progress checkpoint asking if things are going well.

### 3. Try Interactive Commands

**Trigger a checkpoint manually:**
```
/checkpoint
```

**Correct Claude if it makes a mistake:**
```
/correct "We use OAuth2, not JWT. Decided Nov 6 for better token security."
```

**View session quality:**
```
/session-feedback
```

**Validate before committing:**
```
git add .
# Pre-commit validation runs automatically, showing security checks
```

The plugin will automatically track this!

### 3. View Context

```
/memory-context
```

See what the plugin has learned about your project.

### 4. Generate Overview

```
/memory-overview
```

Get a comprehensive project summary.

## How It Works

The plugin automatically:

- **Tracks your session** when you start Claude Code
- **Monitors file changes** as you work
- **Analyzes git commits** when you commit
- **Syncs CLAUDE.md files** to maintain team context
- **Provides intelligent suggestions** based on past work

No manual intervention needed!

## Essential Commands

| Command | What It Does |
|---------|--------------|
| `/memory-status` | Show tracking status |
| `/memory-sync` | Manually sync to memory |
| `/memory-context [query]` | Get relevant context |
| `/memory-overview` | Generate project overview |

## Example Workflow

1. **Start your day**
   ```bash
   claude
   ```
   Plugin initializes and loads yesterday's context

2. **Work on a feature**
   ```
   Add authentication to the API
   ```
   Plugin tracks all your changes

3. **Make commits**
   ```bash
   git commit -m "feat: add OAuth2 authentication"
   ```
   Plugin analyzes and stores commit context

4. **End your session**
   ```
   <Ctrl+D to exit>
   ```
   Plugin summarizes and stores session learnings

5. **Next day**
   
   When you or a teammate starts Claude Code, all that context is available!

## Tips for Success

### ✅ Do This
- Use conventional commit messages (`feat:`, `fix:`, etc.)
- Keep CLAUDE.md files updated
- Run `/memory-sync` after major features
- Use `/memory-context` when starting new work

### ❌ Avoid This
- Don't disable the hooks
- Don't skip commit messages
- Don't forget to sync before breaks
- Don't ignore pattern suggestions

## Common Use Cases

### New Feature Development

```
/memory-context authentication patterns
```
↓
```
Implement OAuth2 following established patterns
```
↓
```
git commit -m "feat: add OAuth2 support"
```
↓
Plugin stores new pattern for team

### Onboarding New Developer

```
/memory-overview --save-to=ONBOARDING.md
```
↓
New developer gets complete project context

### Code Review

```
/memory-context why did we choose PostgreSQL
```
↓
Get historical decision context for review

### Bug Investigation

```
/memory-context error handling in API layer
```
↓
See how errors are handled elsewhere

## Troubleshooting

**Plugin not loading or initializing?**

Check for duplicate hooks reference:
```bash
# This should return NOTHING:
grep '"hooks"' .claude-plugin/plugin.json.local
```

If you see `"hooks": "./hooks/hooks.json"`, remove that line. Claude Code automatically discovers hooks - explicit references cause duplication and break initialization.

**Plugin not working?**
```bash
claude --debug
```

**Hooks not firing?**
```bash
chmod +x scripts/*.sh
```

**Token issues?**
- Verify token in `.claude-plugin/plugin.json`
- Check network connectivity
- Regenerate token at memory.store

**Common Issues:**
- ⚠️ **Don't add `"hooks"` field to `plugin.json` or `plugin.json.local`** - hooks are auto-discovered
- ⚠️ **Keep `.claude-plugin/plugin.json.local` in `.gitignore`** - it contains your token
- ⚠️ **Scripts must be executable** - run `chmod +x scripts/*.sh`

## Next Steps

- Read the full [README.md](README.md)
- Check out [INSTALLATION.md](INSTALLATION.md) for team setup
- See [CHANGELOG.md](CHANGELOG.md) for features
- Join discussions on GitHub

## Need Help?

- **Issues**: [GitHub Issues](https://github.com/julep-ai/memory-store-plugin/issues)
- **Email**: developers@autotelic.inc
- **Docs**: See README.md

---

**You're ready!** The plugin is now building a knowledge base of your development journey. 🎉

# Memory Store Plugin for Claude Code

> Give Claude persistent memory. Stop re-explaining your codebase every session. Claude remembers corrections, patterns, and decisions—learning from mistakes instead of repeating them.

A comprehensive Claude Code plugin that automatically tracks your development flow, captures session context, analyzes git commits, and maintains team knowledge across projects.

## Quick Start (3 Minutes)

**IMPORTANT**: Both the plugin AND the MCP server are required for automatic tracking to work:
- **Plugin**: Provides automatic hooks that track your development activity
- **MCP Server**: Stores the tracked data persistently

### 1. Install the Plugin

```bash
# Add the marketplace
claude plugin marketplace add julep-ai/memory-store-plugin

# Install the plugin
claude plugin install memory-store@claude-plugin
```

✅ This enables automatic tracking hooks

### 2. Configure Memory Store MCP Server

```bash
# Add the Memory Store MCP server
claude mcp add memory-store -t http https://beta.memory.store/mcp
```

✅ This enables persistent memory storage

The OAuth authentication flow will open in your browser. Authenticate once and you're all set!

### 3. Verify Automatic Tracking

```bash
cd your-project
claude
```

Check that everything is working:
```
/memory-store:memory-status
```

You should see session tracking active!

## What Gets Tracked Automatically

Once installed, the plugin **automatically tracks** (no manual commands needed):

### 📊 Every Session
- ✅ **Session start**: Project state, git branch, file count
- ✅ **Session end**: Duration, files changed, commits made, quality score
- ✅ **Context loading**: Previous session learnings loaded automatically

### 📝 Every File Change
- ✅ **Write/Edit operations**: File path, language, patterns detected (API, UI, Service, etc.)
- ✅ **Change count**: Tracked per session
- ✅ **Automatic checkpoints**: Every 10 file changes

### 🔄 Every Git Commit
- ✅ **Commit analysis**: Message, files changed, patterns
- ✅ **Ownership tracking**: Who commits where
- ✅ **Pre-commit validation**: Security checks, secret detection

### 🎯 Every Error/Correction
- ✅ **Error detection**: Automatic capture when you say "wrong", "error", "failed"
- ✅ **High-priority learning**: Stored as corrections with `is_resolution: true`
- ✅ **Session quality tracking**: Reduces quality score for feedback

### 📋 Context Compaction
- ✅ **Before compression**: Saves important context automatically
- ✅ **Preserves decisions**: Key reasoning and patterns retained

## No Manual Work Required!

Just use Claude Code normally:
```bash
You: "Add authentication to the API"
Claude: [Creates auth.ts]
```

**Behind the scenes:**
1. ✅ Hook fires (PreToolUse on Write)
2. ✅ track-changes.sh extracts file info
3. ✅ Claude calls mcp__memory-store__record
4. ✅ Data stored: "Created src/api/auth.ts - API authentication pattern"
5. ✅ Session counter incremented

**You see:** Normal Claude Code workflow
**Plugin does:** All tracking automatically!

## Features

### 🎯 Automatic Session Tracking
- **Session-level context**: Every development session is tracked with complete context
- **File change monitoring**: Real-time tracking of Write/Edit operations
- **Background processing**: Hooks run asynchronously without interrupting workflow
- **Smart storage**: Only relevant context is captured and stored

### 📊 Git Intelligence
- **Commit analysis**: Automatic analysis of commit patterns, types, and impact
- **Branching strategy**: Tracks and documents team branching workflows
- **Historical context**: Preserves the "why" behind code changes
- **Breaking change detection**: Automatically flags significant changes

### 📝 CLAUDE.md Synchronization
- **Anchor comment tracking**: Monitors and syncs anchor comments across files
- **Cross-team consistency**: Ensures all team members have latest documentation
- **Pattern documentation**: Captures and shares coding patterns
- **Convention enforcement**: Helps maintain consistent standards

### 🤖 Intelligent Context Retrieval
- **Manual context queries**: Use `/memory-context` to retrieve relevant past work
- **Pattern awareness**: Query established patterns with `/memory-overview`
- **Decision history**: Access reasoning behind past technical choices
- **Team knowledge**: Shared context available across team members

### 🔧 Custom Slash Commands
- `/memory-status` - View current tracking status and statistics
- `/memory-sync` - Manually synchronize project state to memory
- `/memory-context [query]` - Retrieve relevant context for current work
- `/memory-overview` - Generate comprehensive project overview
- `/checkpoint` - Trigger progress validation checkpoint
- `/correct "explanation"` - Correct Claude's mistakes with high-priority learning
- `/session-feedback` - View current session quality rating
- `/validate-changes` - Pre-commit validation with security checks

### 🎯 Interactive Validation & Feedback
- **Progress Checkpoints**: Auto-validates after every 10 file changes
- **Pre-commit Validation**: Reviews changes before commits with security checks
- **Correction System**: Record mistakes with `/correct` for high-priority learning
- **Session Quality Tracking**: Automatic feedback based on corrections needed
- **Security Scanning**: Detects potential secrets, tokens, and debug code
- **Semantic Commit Reminders**: Encourages proper commit message conventions

## Installation

### Quick Install via Marketplace (Recommended)

**Step 1: Install Plugin**
```bash
claude plugin marketplace add julep-ai/memory-store-plugin
claude plugin install memory-store@claude-plugin
```

**Step 2: Configure MCP Server**
```bash
claude mcp add memory-store https://beta.memory.store/mcp
```

OAuth will open in your browser. Authenticate once and it works everywhere!

### Alternative Installation Methods

#### From Local Repository

```bash
# Clone and install plugin
git clone https://github.com/julep-ai/memory-store-plugin.git
claude plugin marketplace add ./memory-store-plugin
claude plugin install memory-store@claude-plugin

# Configure MCP server (required!)
claude mcp add memory-store https://beta.memory.store/mcp
```

#### From Git URL

```bash
# Install plugin from Git
claude plugin marketplace add https://github.com/julep-ai/memory-store-plugin.git
claude plugin install memory-store@claude-plugin

# Configure MCP server (required!)
claude mcp add memory-store https://beta.memory.store/mcp
```

### Team Installation

For team-wide deployment, add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "julep-plugins": {
      "source": {
        "source": "github",
        "repo": "julep-ai/memory-store-plugin"
      }
    }
  },
  "enabledPlugins": [
    "memory-store"
  ]
}
```

When team members trust the repository, the plugin is automatically installed!

### Verify Installation

```bash
# Start Claude Code
cd your-project
claude

# Check plugin loaded
/plugin
# Should show: ✔ memory-store · Installed

# Check MCP connected
/mcp
# Should show: ✓ memory-store - Connected

# Check tracking active
/memory-store:memory-status
# Should show: Session tracking information
```

✅ If all three checks pass, automatic tracking is working!

## Usage

### Automatic Tracking

The plugin works automatically in the background:

- **Session Start**: Captures project state when you start Claude Code
- **File Changes**: Tracks every file you create or modify
- **Git Commits**: Analyzes commits you make during the session
- **Session End**: Summarizes and stores session learnings

You don't need to do anything - it just works!

### Essential Commands

| Command | What It Does |
|---------|--------------|
| `/memory-status` | Show tracking status |
| `/memory-sync` | Manually sync to memory |
| `/memory-context [query]` | Get relevant context |
| `/memory-overview` | Generate project overview |
| `/checkpoint` | Trigger validation checkpoint |
| `/correct "msg"` | Record correction (high priority) |
| `/session-feedback` | View session quality |

### Example Workflow

**Morning - Start Work**
```bash
cd your-project
claude
```
Plugin initializes and loads yesterday's context

**During Development**
```
Add authentication to the API
```
Plugin tracks all your changes automatically

**Making Commits**
```bash
git commit -m "feat: add OAuth2 authentication"
```
Plugin analyzes and stores commit context

**Correct Mistakes**
```
/correct "We use OAuth2, not JWT. Decided Nov 6 for better token security."
```
Claude will remember this correction forever

**End Session**
```
<Ctrl+D to exit>
```
Plugin summarizes and stores session learnings

**Next Day**

When you or a teammate starts Claude Code, all that context is available!

### Intelligent Context Retrieval

Claude automatically uses stored context:

**Example 1: Following Patterns**

```
You: "I need to add a new API endpoint"

Claude: "I'll help you create that endpoint. Based on our established
patterns (see src/api/auth.ts:45), I'll follow the same authentication
and error handling conventions..."
```

**Example 2: Decision History**

```
You: "Should we use MongoDB or PostgreSQL?"

Claude: "Looking at our memory store, the team decided to use PostgreSQL
3 months ago for ACID compliance and complex relationships. Unless this
feature has different requirements, I'd recommend staying consistent..."
```

### Working with CLAUDE.md Files

The plugin automatically syncs your CLAUDE.md files and anchor comments:

```markdown
<!-- AUTH-FLOW -->
## Authentication Flow

Our authentication uses OAuth2 with JWT tokens...
```

When you reference anchor comments in code or documentation, the plugin maintains these relationships in memory.

## How It Works

### Architecture

```
Claude Code Session
       ↓
   Plugin Hooks
       ↓
┌──────────────────┐
│  Hook Scripts    │
│  (Background)    │
└──────────────────┘
       ↓
┌──────────────────┐
│  Memory MCP      │
│  Server          │
└──────────────────┘
       ↓
┌──────────────────┐
│  Memory Store    │
│  (Cloud/Local)   │
└──────────────────┘
```

### Hook Execution Flow

1. **SessionStart Hook**
   - Initializes session tracking
   - Loads relevant context
   - Captures project snapshot

2. **PostToolUse Hooks**
   - Track file changes (Write/Edit)
   - Analyze commits (git commands)
   - Sync CLAUDE.md files

3. **PreCompact Hook**
   - Saves important context before compression
   - Preserves decisions and reasoning

4. **SessionEnd Hook**
   - Summarizes session
   - Stores key learnings
   - Updates project overview

### Memory Storage

The plugin stores:

- **Development patterns**: How features are implemented
- **Team conventions**: Coding standards and practices
- **Decision history**: Why certain approaches were chosen
- **Business logic**: Core workflows and rules
- **Git context**: Commit patterns and branching strategies
- **Documentation**: CLAUDE.md files and anchor comments

## Team Collaboration

### Local Development

Each developer runs the plugin locally:
- Personal context is captured
- Stored to shared memory store
- Available to all team members

### Knowledge Sharing

The plugin enables powerful knowledge sharing:

- **New developers** can query past decisions
- **Code reviews** reference established patterns
- **Architecture discussions** are preserved
- **Business logic** is documented automatically

### Cross-Project Context

If your team works on multiple related projects:

1. Install the plugin in each project
2. Authenticate once with the same memory store account
3. All projects share the same memory context automatically

## Best Practices

### ✅ Do This

- **Use conventional commit messages**: `feat:`, `fix:`, `docs:`, etc.
- **Keep CLAUDE.md files updated**: Document patterns as you establish them
- **Run `/memory-sync` after major features**: Capture important milestones
- **Use `/memory-context` when starting new work**: Check for similar implementations
- **Correct Claude with `/correct`**: High-priority learning that persists forever

### ❌ Avoid This

- Don't disable the hooks - they provide automatic tracking
- Don't skip commit messages - they're analyzed for patterns
- Don't ignore pattern suggestions - they represent team knowledge

## Configuration

### Extending with Additional MCP Servers

You can add support for Linear, Jam.dev, or other MCP servers:

1. Copy `.mcp-extensions.json.example` to `.mcp-extensions.json`
2. Add your API keys
3. Restart Claude Code

Example with Linear integration:

```json
{
  "mcpServers": {
    "memory": { ... },
    "linear": {
      "command": "npx",
      "args": ["@linear/mcp-server"],
      "env": {
        "LINEAR_API_KEY": "your-key-here"
      }
    }
  }
}
```

The plugin will automatically integrate Linear issues into memory context!

### Customizing Hooks

Edit `hooks/hooks.json` to customize when hooks fire:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/track-changes.sh"
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting

### Plugin Not Loading

**Common Issue: Duplicate Hooks Reference**

If the plugin fails to initialize, check for duplicate hooks loading:

```bash
# This should return NOTHING:
grep '"hooks"' .claude-plugin/plugin.json
grep '"hooks"' .claude-plugin/plugin.json.local
```

If you see `"hooks": "./hooks/hooks.json"`, **remove that line**. Claude Code automatically discovers `hooks/hooks.json` by convention - explicit references cause hooks to load twice and break initialization.

**Other checks:**

```bash
# 1. Check plugin structure
ls -la .claude-plugin/

# 2. Verify plugin.json is valid
cat .claude-plugin/plugin.json | jq .

# 3. Check Claude Code debug output
claude --debug
```

### Hooks Not Firing

```bash
# 1. Ensure scripts are executable
chmod +x scripts/*.sh

# 2. Check hook configuration
cat hooks/hooks.json | jq .

# 3. Test scripts manually
bash scripts/session-start.sh
```

### Memory Store Connection Issues

```bash
# 1. Check MCP server status
claude mcp list

# 2. Re-authenticate if needed
claude mcp remove memory-store
claude mcp add --transport http memory-store "https://beta.memory.store/mcp"

# 3. Check network connectivity
# 4. Verify OAuth authentication completed in browser
```

### Plugin Not Found

```bash
# 1. Verify marketplace is added
/plugin marketplace list

# 2. Refresh marketplace
/plugin marketplace update claude-plugin

# 3. Try reinstalling
/plugin uninstall memory-store
/plugin install memory-store@claude-plugin
```

## Common Use Cases

### New Feature Development

```
/memory-context authentication patterns
```
→ Check existing patterns
```
Implement OAuth2 following established patterns
```
→ Build with consistency
```
git commit -m "feat: add OAuth2 support"
```
→ Pattern stored for team

### Onboarding New Developer

```
/memory-overview
```
→ Generate comprehensive project overview with architecture, patterns, and decisions

### Code Review

```
/memory-context why did we choose PostgreSQL
```
→ Get historical decision context

### Bug Investigation

```
/memory-context error handling in API layer
```
→ See how errors are handled elsewhere

## Development

### Local Testing

1. Make changes to plugin files
2. Restart Claude Code
3. Test with `/memory-status`

### Adding New Hooks

1. Create script in `scripts/`
2. Make it executable: `chmod +x scripts/your-script.sh`
3. Add to `hooks/hooks.json`
4. Test the hook

### Adding New Commands

1. Create markdown file in `commands/`
2. Add frontmatter with description
3. Document usage and examples
4. Restart Claude Code

## Support

- **Issues**: [GitHub Issues](https://github.com/julep-ai/memory-store-plugin/issues)
- **Discussions**: [GitHub Discussions](https://github.com/julep-ai/memory-store-plugin/discussions)
- **Email**: developers@autotelic.inc

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

Built by the Autotelic team with ❤️ for the Claude Code community.

Special thanks to:
- The Claude Code team at Anthropic
- The memory.store team
- All contributors and users

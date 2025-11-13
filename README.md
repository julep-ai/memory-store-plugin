# Memory Store Plugin for Claude Code

> Give Claude persistent memory. Stop re-explaining your codebase every session. Claude remembers corrections, patterns, and decisions—learning from mistakes instead of repeating them.

A comprehensive Claude Code plugin that automatically tracks your development flow, captures session context, analyzes git commits, syncs CLAUDE.md files, and maintains team knowledge across projects.

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
- **Auto-context awareness**: Claude automatically retrieves relevant past work
- **Pattern suggestions**: Suggests following established patterns
- **Decision history**: Provides reasoning behind past technical choices
- **Team knowledge**: Surfaces insights from other team members

### 🔧 Custom Slash Commands
- `/memory-sync` - Manually synchronize project state to memory
- `/memory-status` - View current tracking status and statistics
- `/memory-context` - Retrieve relevant context for current work
- `/memory-overview` - Generate comprehensive project overview
- `/checkpoint` - Trigger progress validation checkpoint
- `/correct "explanation"` - Correct Claude's mistakes with high-priority learning
- `/session-feedback` - View current session quality rating
- `/validate-changes` - Pre-commit validation with security checks

### 🎓 Specialized Agent
- **Memory Tracker Agent**: Deep project analysis and pattern documentation
- **Cross-repo context**: Analyzes relationships between multiple repositories
- **Workflow documentation**: Captures team development processes
- **Business logic mapping**: Documents core workflows and rules

### ⚡ Agent Skill
- **Memory Context Retrieval Skill**: Auto-invoked for contextual awareness
- **Pattern matching**: Detects when similar work has been done before
- **Deviation warnings**: Alerts when current approach differs from patterns
- **Proactive suggestions**: Recommends best practices automatically

### 🎯 Interactive Validation & Feedback
- **Progress Checkpoints**: Auto-validates after every 10 file changes
- **Pre-commit Validation**: Reviews changes before commits with security checks
- **Correction System**: Record mistakes with `/correct` for high-priority learning
- **Session Quality Tracking**: Automatic feedback based on corrections needed
- **Security Scanning**: Detects potential secrets, tokens, and debug code
- **Semantic Commit Reminders**: Encourages proper commit message conventions

## Installation

### Quick Install (Recommended)

The easiest way to install is via the Claude Code plugin marketplace:

```bash
# Add the marketplace
/plugin marketplace add julep-ai/memory-store-plugin

# Install the plugin
/plugin install memory-store
```

That's it! See [MARKETPLACE.md](MARKETPLACE.md) for detailed marketplace installation guide.

### Configure Memory Store Connection

After installation, connect to the memory store server:

```bash
# Add the memory store MCP server (one command!)
claude mcp add --transport http memory-store "https://beta.memory.store/mcp"
```

This will:
1. Open your browser for authentication
2. Securely store your credentials
3. Enable automatic memory tracking

**Note**: Authentication uses OAuth 2.0 - no manual token management needed! Your credentials are stored securely by Claude Code and automatically refreshed.

### Alternative: Manual Installation

For development or custom setups:

```bash
git clone https://github.com/julep-ai/memory-store-plugin.git
/plugin marketplace add ./memory-store-plugin
/plugin install memory-store
```

### Verify Installation

Test the plugin:

```bash
/memory-status
```

You should see session tracking information!

## Usage

### Automatic Tracking

The plugin works automatically in the background:

- **Session Start**: Captures project state when you start Claude Code
- **File Changes**: Tracks every file you create or modify
- **Git Commits**: Analyzes commits you make during the session
- **Session End**: Summarizes and stores session learnings

You don't need to do anything - it just works!

### Manual Commands

#### View Tracking Status

```
/memory-status
```

Shows what's being tracked in your current session:
- Files modified
- Commits analyzed
- Context stored
- Memory store statistics

#### Retrieve Context

```
/memory-context authentication flow
```

Retrieves relevant context about authentication from past work:
- Similar implementations
- Team decisions
- Established patterns
- Related documentation

#### Sync to Memory

```
/memory-sync
```

Manually synchronizes current project state:
- Captures file structure
- Analyzes git history
- Syncs CLAUDE.md files
- Updates project overview

#### Generate Overview

```
/memory-overview
```

Generates comprehensive project overview:
- Architecture documentation
- Business logic workflows
- Team conventions
- Development patterns
- Knowledge gaps

### Working with CLAUDE.md Files

The plugin automatically syncs your CLAUDE.md files and anchor comments:

```markdown
<!-- AUTH-FLOW -->
## Authentication Flow

Our authentication uses OAuth2 with JWT tokens...
```

When you reference anchor comments in code or documentation, the plugin maintains these relationships in memory, making it easy for team members to find relevant context.

### Intelligent Context Retrieval

Claude will automatically use stored context to provide better responses:

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
3. The Memory Tracker Agent can analyze cross-repo relationships
4. All projects share the same memory context automatically

## Best Practices

### 1. Use Descriptive Commit Messages

The plugin analyzes commit messages - use conventional commits:

```bash
feat: add OAuth2 authentication flow
fix: resolve token refresh race condition
docs: update CLAUDE.md with auth patterns
```

### 2. Maintain CLAUDE.md Files

Keep your CLAUDE.md files up to date:
- Document patterns as you establish them
- Use anchor comments for important sections
- Reference anchors in code and discussions

### 3. Regular Syncs

Run `/memory-sync` after:
- Major feature completions
- Architectural decisions
- Before team meetings
- When onboarding new members

### 4. Query Context Early

Use `/memory-context` when starting new work:
- Check for similar implementations
- Review past decisions
- Understand team conventions

### 5. Generate Overviews Periodically

Run `/memory-overview` to:
- Create onboarding documentation
- Prepare for stakeholder updates
- Audit knowledge gaps
- Plan technical debt work

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

1. Check plugin structure:
```bash
ls -la .claude-plugin/
```

2. Verify plugin.json is valid:
```bash
cat .claude-plugin/plugin.json | jq .
```

3. Check Claude Code debug output:
```bash
claude --debug
```

### Hooks Not Firing

1. Ensure scripts are executable:
```bash
chmod +x scripts/*.sh
```

2. Check hook configuration:
```bash
cat hooks/hooks.json | jq .
```

3. Test scripts manually:
```bash
bash scripts/session-start.sh
```

### Memory Store Connection Issues

1. Check MCP server status:
```bash
claude mcp list
```

2. Re-authenticate if needed:
```bash
claude mcp remove memory-store
claude mcp add --transport http memory-store "https://beta.memory.store/mcp"
```

3. Check network connectivity
4. Verify OAuth authentication completed successfully (check browser)

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

## Examples

See the [examples/](examples/) directory for:
- Sample CLAUDE.md files
- Example memory queries
- Hook customization examples
- Team workflow templates

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests if applicable
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details

## Support

- **Issues**: [GitHub Issues](https://github.com/julep-ai/memory-store-plugin/issues)
- **Discussions**: [GitHub Discussions](https://github.com/julep-ai/memory-store-plugin/discussions)
- **Email**: developers@autotelic.inc

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Credits

Built by the Autotelic team with ❤️ for the Claude Code community.

Special thanks to:
- The Claude Code team at Anthropic
- The memory.store team
- All contributors and users

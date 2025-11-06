# Installation Guide

Quick guide to get the Memory Store Tracker plugin up and running.

## Prerequisites

- ✅ Claude Code installed
- ✅ Memory store account and token ([get one here](https://beta.memory.store))
- ✅ Git (optional but recommended)
- ✅ Bash/sh compatible shell

## Step-by-Step Installation

### 1. Get Your Memory Token

1. Visit [https://beta.memory.store](https://beta.memory.store)
2. Sign up or log in
3. Copy your MCP token

### 2. Install the Plugin

**Option A: Clone into your project**

```bash
cd your-project
git clone https://github.com/autotelic/memory-store-plugin.git
```

**Option B: Copy plugin directory**

```bash
cp -r /path/to/memory-store-plugin your-project/
```

### 3. Configure Your Token

Edit `.claude-plugin/plugin.json` and replace `YOUR_TOKEN_HERE`:

```json
{
  "name": "memory-store-tracker",
  "version": "1.0.0",
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

### 4. Verify Installation

```bash
# Check plugin structure
ls -la .claude-plugin/

# Verify scripts are executable
ls -la scripts/

# Start Claude Code
claude
```

### 5. Test the Plugin

Once Claude Code starts, try:

```
/memory-status
```

You should see the plugin tracking status!

## Verification Checklist

- [ ] Plugin directory structure exists
- [ ] `.claude-plugin/plugin.json` has your token
- [ ] Scripts in `scripts/` are executable (`chmod +x scripts/*.sh`)
- [ ] Claude Code starts without errors
- [ ] `/memory-status` command works
- [ ] Session tracking is active

## Troubleshooting

### Plugin Not Loading

**Check debug output:**
```bash
claude --debug
```

**Verify JSON syntax:**
```bash
cat .claude-plugin/plugin.json | jq .
```

### Scripts Not Executable

```bash
chmod +x scripts/*.sh
```

### Memory Token Issues

1. Verify token is correct
2. Check network connectivity
3. Test MCP server directly:

```bash
npx mcp-remote https://beta.memory.store/mcp/?token=YOUR_TOKEN
```

### Permission Issues

```bash
# Ensure you own the files
chown -R $USER:$USER .claude-plugin/ scripts/

# Fix permissions
chmod 755 scripts/
chmod +x scripts/*.sh
```

## Next Steps

Once installed:

1. **Read the README**: Full documentation and examples
2. **Try commands**: Test `/memory-sync`, `/memory-context`, `/memory-overview`
3. **Make commits**: Watch git analysis in action
4. **Edit files**: See file tracking work
5. **Create CLAUDE.md**: Set up anchor comments

## Team Setup

To enable team-wide tracking:

### 1. Share Plugin with Team

**Option A: Commit to repository**
```bash
git add .claude-plugin/ commands/ agents/ skills/ hooks/ scripts/
git commit -m "Add Memory Store Tracker plugin"
git push
```

**Option B: Share as package**
```bash
# Create distributable package
tar -czf memory-plugin.tar.gz .claude-plugin/ commands/ agents/ skills/ hooks/ scripts/ README.md
```

### 2. Team Members Install

Each team member:
1. Pull the repository or extract package
2. Add their own token to `.claude-plugin/plugin.json`
3. Start Claude Code

### 3. Shared Memory Store

All team members should:
- Use the same memory store account (or separate accounts with shared access)
- Have their tokens configured
- Start using Claude Code

The plugin will automatically share context across the team!

## Configuration Options

### Add Additional MCP Servers

Copy `.mcp-extensions.json.example` to `.mcp-extensions.json`:

```bash
cp .mcp-extensions.json.example .mcp-extensions.json
```

Edit and add your API keys for Linear, Jam.dev, etc.

### Customize Hooks

Edit `hooks/hooks.json` to change when hooks fire:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [...]
      }
    ]
  }
}
```

## Getting Help

- **Documentation**: See [README.md](README.md)
- **Issues**: [GitHub Issues](https://github.com/autotelic/memory-store-plugin/issues)
- **Support**: developers@autotelic.ai

## Success!

You're all set! The plugin is now tracking your development and building a knowledge base for your team.

Happy coding! 🚀

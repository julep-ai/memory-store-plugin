# Plugin Marketplace Installation

The easiest way to install the Memory Store plugin is through the Claude Code plugin marketplace system.

**What this plugin does:** Gives Claude persistent memory across sessions. Claude remembers your corrections (via `/correct`), patterns, architecture decisions, and automatically loads relevant context. No more re-explaining your codebase every day.

## Quick Install via Marketplace

### Option 1: Install from GitHub Marketplace (Recommended)

```bash
# Add the julep-ai marketplace
/plugin marketplace add julep-ai/memory-store-plugin

# Install the plugin
/plugin install memory-store@claude-plugin
```

That's it! The plugin is now installed and ready to use.

### Option 2: Direct GitHub Installation

```bash
# Install directly from GitHub
/plugin install julep-ai/memory-store-plugin
```

## Connect to Memory Store

After installation, connect to the memory store server using OAuth authentication:

```bash
# Add the memory store MCP server (one command!)
claude mcp add --transport http memory-store "https://beta.memory.store/mcp"
```

This will:
1. Open your browser for authentication
2. Securely store your credentials via OAuth 2.0
3. Enable automatic memory tracking across all your projects

**No manual token configuration needed!** Authentication is handled automatically through your browser.

## Verify Installation

Test the plugin is working:

```bash
# Check plugin status
/memory-status
```

You should see the session tracking information!

## Team Installation

For team-wide deployment, add the marketplace to your project's `.claude/settings.json`:

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

## Alternative Installation Methods

### From Local Repository

```bash
# Clone the repository
git clone https://github.com/julep-ai/memory-store-plugin.git

# Add as local marketplace
/plugin marketplace add ./memory-store-plugin

# Install
/plugin install memory-store@claude-plugin
```

### From Git URL

```bash
# Add marketplace via URL
/plugin marketplace add https://github.com/julep-ai/memory-store-plugin.git

# Install plugin
/plugin install memory-store@claude-plugin
```

## Marketplace Management

### List Available Marketplaces

```bash
/plugin marketplace list
```

### Update Marketplace

```bash
/plugin marketplace update julep-plugins
```

### Browse Available Plugins

```bash
/plugin
```

This opens an interactive interface showing all plugins from configured marketplaces.

## Advantages of Marketplace Installation

✅ **Automatic Updates**: Get plugin updates automatically  
✅ **Version Management**: Track and manage plugin versions  
✅ **Easy Discovery**: Browse available plugins interactively  
✅ **Team Distribution**: Share plugins across your organization  
✅ **No Manual Setup**: No need to copy files or manage directories  
✅ **Centralized Configuration**: Manage all plugins from one place

## Troubleshooting

### Plugin Not Found

If the plugin isn't showing up:

1. Verify marketplace is added:
```bash
/plugin marketplace list
```

2. Refresh marketplace:
```bash
/plugin marketplace update julep-plugins
```

3. Try reinstalling:
```bash
/plugin uninstall memory-store
/plugin install memory-store@claude-plugin
```

### Authentication Issues

If the plugin isn't working:

1. Verify MCP server is connected: `claude mcp list`
2. Re-authenticate if needed: `claude mcp remove memory-store && claude mcp add --transport http memory-store "https://beta.memory.store/mcp"`
3. Check that OAuth authentication completed in browser
4. Restart Claude Code

### Permission Issues

Ensure scripts are executable:

```bash
cd ~/.claude/plugins/memory-store/scripts
chmod +x *.sh
```

## Next Steps

Once installed:

1. **Read the Quick Start**: See [QUICK_START.md](QUICK_START.md)
2. **Try commands**: Run `/memory-status`, `/memory-sync`, `/memory-context`
3. **Explore features**: Check out [README.md](README.md) for full documentation

## Support

- **Issues**: [GitHub Issues](https://github.com/julep-ai/memory-store-plugin/issues)
- **Email**: developers@autotelic.inc
- **Documentation**: [Full README](README.md)

---

**The marketplace system makes plugin installation effortless!** No manual configuration, no file copying - just add the marketplace and install.
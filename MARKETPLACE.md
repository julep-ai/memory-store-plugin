# Plugin Marketplace Installation

The easiest way to install the Memory Store Tracker plugin is through the Claude Code plugin marketplace system.

## Quick Install via Marketplace

### Option 1: Install from GitHub Marketplace (Recommended)

```bash
# Add the julep-ai marketplace
/plugin marketplace add julep-ai/memory-store-plugin

# Install the plugin
/plugin install memory-store-tracker
```

That's it! The plugin is now installed and ready to use.

### Option 2: Direct GitHub Installation

```bash
# Install directly from GitHub
/plugin install julep-ai/memory-store-plugin
```

## Configure Your Memory Token

After installation, you need to configure your memory store token:

1. Get your token from [memory.store](https://beta.memory.store)

2. Create a local configuration file (not tracked by git):

```bash
# Navigate to the plugin directory
cd ~/.claude/plugins/memory-store-tracker

# Create local config with your token
cat > .mcp.json.local << EOF
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://beta.memory.store/mcp/?token=YOUR_ACTUAL_TOKEN_HERE"
      ]
    }
  }
}
EOF
```

3. Or use environment variables:

```bash
export MEMORY_STORE_TOKEN="your-token-here"
```

The plugin will automatically use your configured token.

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
    "memory-store-tracker"
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
/plugin install memory-store-tracker
```

### From Git URL

```bash
# Add marketplace via URL
/plugin marketplace add https://github.com/julep-ai/memory-store-plugin.git

# Install plugin
/plugin install memory-store-tracker
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
/plugin uninstall memory-store-tracker
/plugin install memory-store-tracker
```

### Token Configuration Issues

If hooks aren't working:

1. Check token is configured (see Configure Your Memory Token above)
2. Verify `.mcp.json.local` exists in plugin directory
3. Restart Claude Code

### Permission Issues

Ensure scripts are executable:

```bash
cd ~/.claude/plugins/memory-store-tracker/scripts
chmod +x *.sh
```

## Next Steps

Once installed:

1. **Read the Quick Start**: See [QUICK_START.md](QUICK_START.md)
2. **Try commands**: Run `/memory-status`, `/memory-sync`, `/memory-context`
3. **Explore features**: Check out [README.md](README.md) for full documentation

## Support

- **Issues**: [GitHub Issues](https://github.com/julep-ai/memory-store-plugin/issues)
- **Email**: developers@autotelic.ai
- **Documentation**: [Full README](README.md)

---

**The marketplace system makes plugin installation effortless!** No manual configuration, no file copying - just add the marketplace and install.
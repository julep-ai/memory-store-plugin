# Changelog

All notable changes to the Memory Store Tracker Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-11-09

### Added

#### Interactive Validation & Feedback
- **Progress Checkpoints** - Auto-trigger every 10 file changes for interactive validation
- **Pre-commit Validation** - Automatic review before commits with security checks
- **Correction System** - `/correct` command for high-priority mistake recording
- **Session Quality Tracking** - Automatic rating (0-10) based on corrections needed
- **Security Scanning** - Detects secrets, tokens, and debug code in commits

#### New Commands
- `/checkpoint` - Manually trigger progress validation checkpoint
- `/correct "explanation"` - Record Claude's mistakes as high-priority learnings
- `/session-feedback` - View current session quality rating and metrics
- `/validate-changes` - Pre-commit validation with security checks

#### New Scripts
- `validate-commit.sh` - Pre-commit validation with interactive review
- `progress-checkpoint.sh` - Auto-triggered progress validation checkpoints

#### Enhanced Scripts
- `session-start.sh` - Now actually calls memory__record MCP tool
- `session-end.sh` - Calculates session quality rating and stores comprehensive feedback
- `track-changes.sh` - Stores memory records and triggers checkpoints every 10 changes
- `feedback-capture.sh` - Stores corrections via memory__feedback with high importance

#### New Hooks
- PostToolUse hook for `git add` - Triggers pre-commit validation

### Changed
- All hook scripts now actually integrate with MCP tools (were preparing data but not storing)
- Session tracking now includes quality ratings and correction counts
- Feedback system tracks corrections as high-priority memories with `is_resolution: true`

### Security
- Added `plugin.json.example` with placeholder token
- Token file now excluded from git tracking via `.gitignore`
- Pre-commit validation scans for exposed secrets and tokens

## [1.0.0] - 2025-01-15

### Added

#### Core Features
- **Session tracking** with SessionStart and SessionEnd hooks
- **File change monitoring** via PostToolUse hooks for Write/Edit operations
- **Git commit analysis** with automatic pattern detection
- **CLAUDE.md synchronization** with anchor comment tracking
- **PreCompact hook** for preserving context before conversation compression

#### Commands
- `/memory-sync` - Manual synchronization of project state
- `/memory-status` - View current tracking status and statistics
- `/memory-context` - Retrieve relevant context from memory store
- `/memory-overview` - Generate comprehensive project overview

#### Agents
- **Memory Tracker Agent** - Specialized agent for deep project analysis
  - Project structure analysis
  - Git history analysis
  - Cross-repository context gathering
  - Team workflow documentation
  - Branching strategy analysis

#### Skills
- **Memory Context Retrieval Skill** - Auto-invoked skill for intelligent context awareness
  - Automatic context retrieval based on task
  - Pattern matching and suggestions
  - Deviation warnings
  - Team knowledge surfacing

#### Hook Scripts
- `session-start.sh` - Initialize session and load context
- `session-end.sh` - Summarize session and store learnings
- `track-changes.sh` - Monitor file modifications
- `analyze-commits.sh` - Analyze git commits and patterns
- `sync-claude-md.sh` - Sync CLAUDE.md files and anchors
- `save-context.sh` - Preserve context before compaction
- `project-overview.sh` - Generate project overview

#### Integration
- Memory store MCP server integration
- Support for additional MCP servers (Linear, Jam.dev)
- Extensible architecture for custom integrations

#### Documentation
- Comprehensive README with usage examples
- Command documentation for all slash commands
- Agent and Skill documentation
- Troubleshooting guide
- Best practices guide

### Features Highlights

**Automatic Tracking**
- Zero-configuration session tracking
- Background hook execution
- Intelligent pattern detection
- Smart context storage

**Git Intelligence**
- Commit pattern analysis
- Conventional commit detection
- Breaking change identification
- Branching strategy tracking
- Contributor analysis

**Team Collaboration**
- Shared memory store for team knowledge
- Cross-team context sharing
- CLAUDE.md anchor comment system
- Decision history preservation
- Business logic documentation

**Developer Experience**
- Non-intrusive background operation
- Rich slash command interface
- Intelligent context suggestions
- Comprehensive project overviews

### Technical Details

**Plugin Structure**
```
.claude-plugin/
  plugin.json          # Plugin manifest
commands/              # Slash commands
agents/                # Specialized agents
skills/                # Agent Skills
hooks/                 # Hook configurations
scripts/               # Background scripts
```

**Hook Events**
- SessionStart
- SessionEnd
- PostToolUse (Write, Edit, Bash)
- PreCompact

**Memory Store Integration**
- Uses memory_record for storage
- Uses memory_recall for retrieval
- Uses memory_overview for summaries
- Supports importance levels
- Includes background context

### Known Limitations

- Requires memory store MCP server token
- Git integration works best with conventional commits
- CLAUDE.md sync requires markdown format
- Some scripts require bash/sh compatibility

### Breaking Changes

None - initial release

### Migration Guide

Not applicable - initial release

### Security

- Memory token stored in plugin configuration
- Scripts use `set -euo pipefail` for safe execution
- No sensitive data logged to console
- Background processes isolated

### Performance

- Hook scripts run asynchronously
- Minimal impact on Claude Code performance
- Efficient file system operations
- Smart caching where applicable

### Compatibility

- Claude Code: Compatible with latest version
- Operating Systems: macOS, Linux (bash required)
- Git: Optional but recommended
- Node.js: Required for MCP server

---

## [Unreleased]

### Planned Features

- **Enhanced Git Analysis**
  - Pull request tracking
  - Code review pattern analysis
  - Release cycle documentation

- **Additional MCP Integrations**
  - GitHub Issues integration
  - Jira integration
  - Slack notifications

- **Advanced Analytics**
  - Code churn analysis
  - Developer productivity insights
  - Pattern evolution tracking

- **UI Enhancements**
  - Rich formatting in status output
  - Interactive overview generation
  - Visual git history

- **Smart Suggestions**
  - Auto-detect missing patterns
  - Suggest documentation updates
  - Identify knowledge gaps

### Ideas for Future Versions

- Web dashboard for memory visualization
- Team analytics and insights
- Custom hook templates
- Plugin marketplace integration
- Multi-project workspace support
- AI-powered pattern recommendations

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this changelog and the project.

## Support

For questions, issues, or feature requests:
- GitHub Issues: https://github.com/autotelic/memory-store-plugin/issues
- Email: developers@autotelic.inc

# Contributing to Memory Store Plugin

Thank you for your interest in contributing! This document outlines the development workflow and branch strategy.

## Branch Strategy

We use a **Git Flow** inspired workflow:

### Main Branches

- **`main`** - Production-ready code, protected branch
  - All changes must go through Pull Requests
  - Requires 1 approval before merging
  - Tagged with semantic versions (v1.2.0, v1.2.1, etc.)

- **`dev`** - Development integration branch
  - Latest development work
  - Feature branches merge here first
  - Tested before merging to main

### Feature Branches

Create feature branches from `dev` using semantic prefixes:

```bash
# Bug fixes
bug/fix-commit-tracking
bug/memory-store-auth

# New features
feat/batch-commit-analysis
feat/slack-integration

# Documentation
docs/api-reference
docs/troubleshooting

# Refactoring
refactor/skill-activation
refactor/hook-architecture

# Testing
test/integration-tests
test/skill-activation
```

## Workflow

### 1. Create Feature Branch

```bash
git checkout dev
git pull origin dev
git checkout -b feat/your-feature-name
```

### 2. Make Changes

- Write code
- Add tests if applicable
- Update documentation
- Follow commit message conventions (below)

### 3. Commit with Semantic Messages

```bash
git commit -m "feat: add batch commit tracking

- Allow tracking multiple commits at once
- Add --batch flag to analyze-commits.sh
- Update skill documentation

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 4. Push and Create PR

```bash
git push -u origin feat/your-feature-name
gh pr create --base dev --title "feat: Add batch commit tracking"
```

### 5. Review and Merge

- Wait for review
- Address comments
- Merge to `dev` when approved
- Delete feature branch after merge

### 6. Release to Main

Periodically, `dev` is merged to `main` with a version bump:

```bash
git checkout main
git merge dev
git tag v1.3.0
git push origin main --tags
```

## Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test additions/changes
- `refactor:` - Code refactoring
- `chore:` - Build/tooling changes
- `hotfix:` - Critical production fixes (direct to main)

**Format:**
```
<type>: <subject>

<body>

<footer>
```

**Example:**
```
feat: add git-memory-tracker skill

- Create skill for manual commit tracking
- Add analyze-commits.sh script
- Enable proactive skill activation

Closes #3

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Pull Request Guidelines

### PR Title Format

Use same convention as commits:
- `feat: Add batch commit tracking`
- `fix: Resolve MCP auth timeout`
- `docs: Update installation guide`

### PR Description Template

````markdown
## Summary

Brief description of changes

## Changes

- List of changes
- With details

## Testing

- [ ] Manual testing completed
- [ ] Works with Memory Store MCP
- [ ] Skills activate correctly

## Related

- Closes #123
- Related to #456
````

### Review Checklist

Before requesting review:
- [ ] Code follows project style
- [ ] Commit messages are semantic
- [ ] Documentation updated
- [ ] No console.log or debug code
- [ ] Tested locally

## Branch Protection Rules

### Main Branch

**Protected settings:**
- ✅ Require pull request before merging
- ✅ Require 1 approval
- ❌ Require status checks (optional, add CI later)
- ✅ Require conversation resolution
- ✅ Require linear history (squash/rebase)

**To set up (requires admin access):**

1. Go to Settings → Branches → Branch protection rules
2. Add rule for `main`
3. Enable:
   - Require a pull request before merging
   - Require approvals (1)
   - Require conversation resolution before merging
   - Require linear history

### Dev Branch

**Recommended settings:**
- ✅ Require pull request before merging
- ❌ No approval required (optional)
- ✅ Allow force pushes (for rebasing)

## Labels

Use these labels to categorize issues and PRs:

**Type:**
- `bug` - Bug fix
- `enhancement` - New feature
- `documentation` - Documentation improvement
- `refactor` - Code refactoring
- `testing` - Test-related changes

**Priority:**
- `priority: critical` - Urgent, blocking
- `priority: high` - Important, not blocking
- `priority: medium` - Normal priority
- `priority: low` - Nice to have

**Status:**
- `status: in-progress` - Actively being worked on
- `status: blocked` - Blocked by dependency
- `status: needs-review` - Ready for review
- `status: changes-requested` - Reviewer requested changes

**Component:**
- `component: hooks` - Hook-related
- `component: skills` - Skill-related
- `component: mcp` - MCP integration
- `component: scripts` - Shell scripts

## Release Process

### Version Numbering

We use [Semantic Versioning](https://semver.org/):
- **Major** (v2.0.0): Breaking changes
- **Minor** (v1.3.0): New features, backwards compatible
- **Patch** (v1.2.1): Bug fixes, backwards compatible

### Creating a Release

1. Merge `dev` to `main`
2. Update version in `.claude-plugin/plugin.json`
3. Create tag:
   ```bash
   git tag -a v1.3.0 -m "Release v1.3.0: Batch commit tracking"
   ```
4. Push tag:
   ```bash
   git push origin v1.3.0
   ```
5. Create GitHub release:
   ```bash
   gh release create v1.3.0 --title "v1.3.0: Batch Commit Tracking" --notes "Release notes here"
   ```

### Release Notes Template

```markdown
## What's New in v1.3.0

### Features
- ✨ Add batch commit tracking
- ✨ Improve skill activation rates (20% → 84%)

### Fixes
- 🐛 Fix MCP auth timeout
- 🐛 Resolve session counter race condition

### Documentation
- 📚 Add troubleshooting guide
- 📚 Update skill best practices

### Breaking Changes
- ⚠️ None

## Installation

\`\`\`bash
claude plugin marketplace add julep-ai/memory-store-plugin
claude plugin install memory-store
claude mcp add memory-store -t http https://beta.memory.store/mcp
\`\`\`

Full changelog: https://github.com/julep-ai/memory-store-plugin/compare/v1.2.0...v1.3.0
```

## Development Setup

See [README.md](README.md) for installation and setup instructions.

## Questions?

- **Issues**: https://github.com/julep-ai/memory-store-plugin/issues
- **Discussions**: https://github.com/julep-ai/memory-store-plugin/discussions
- **Email**: developers@autotelic.inc

---

**Thank you for contributing!** 🎉

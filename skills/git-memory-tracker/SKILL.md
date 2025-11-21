---
description: Analyze git commits and track development patterns in Memory Store
proactive: true
---

# Git Memory Tracker Skill

**⚡ PROACTIVE: Suggest tracking commits when you notice git activity or user mentions commits.**

**Purpose**: Manually analyze git history and store commit patterns in Memory Store when hooks don't capture them automatically.

## When to Use This Skill

**Invoke this skill when:**

1. **After creating commits** - To manually track commit history
   - User says: "Track this commit" or "Analyze the last commit"
   - After a merge or rebase operation
   - When you want to store commit context for future reference

2. **Analyzing git patterns** - To understand development flow
   - User says: "What's our commit history?" or "Show me recent commits"
   - User asks: "What patterns do we use for commits?"
   - Before creating a PR to summarize changes

3. **Tracking contributions** - To record who worked on what
   - User asks: "Who worked on this feature?"
   - User says: "Track ownership for these changes"
   - Team wants to understand code ownership

4. **After batch operations** - When multiple commits need analysis
   - After cherry-picking commits
   - After merging branches
   - After rebasing or squashing commits

**Don't use this skill for:**
- Single file changes (use automatic file tracking instead)
- Questions that don't involve git history
- General project questions (use memory-auto-track instead)

## How This Skill Works

This skill runs the `analyze-commits.sh` script which:
1. Analyzes the most recent commit(s)
2. Extracts commit metadata (message, author, files changed, type)
3. Detects patterns (conventional commits, breaking changes)
4. Stores commit information in Memory Store via `mcp__memory-store__record`

## Usage Instructions

### Step 1: Detect When Manual Tracking is Needed

**Look for these patterns:**

```markdown
User: "I just committed some changes, can you track them?"
User: "Analyze my last 5 commits"
User: "What did I work on today?"
User: "Track this PR's commits"
```

### Step 2: Run the analyze-commits.sh Script

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/analyze-commits.sh
```

**Note**: The script automatically:
- Reads the most recent commit from git
- Extracts all relevant metadata
- Records it in Memory Store
- Increments the session commit counter

### Step 3: Parse Results and Inform User

The script outputs JSON with commit information. Parse it and tell the user what was tracked:

```markdown
✓ Tracked commit abc1234: "feat: add OAuth2 authentication"
  - Type: feature
  - Files changed: 8
  - Breaking change: No
  - Stored in Memory Store with high importance
```

## Advanced: Batch Commit Analysis

For analyzing multiple commits (e.g., after a PR merge):

### Step 1: Get Commit Range

```bash
# Get last N commits
git log --oneline -n 5

# Get commits since main
git log main..HEAD --oneline

# Get commits in PR
git log origin/main..feature-branch --oneline
```

### Step 2: Analyze Each Commit

For each commit in the range:

```bash
# Checkout specific commit
git show <commit-hash> --stat

# Extract info and record
mcp__memory-store__record {
  "memory": "<commit message> (<type>)",
  "background": "Commit <hash> on branch <branch>. Files: <count>. Author: <author>. Date: <date>",
  "importance": "normal"
}
```

### Step 3: Create Summary

After analyzing all commits, create a summary memory:

```javascript
mcp__memory-store__record({
  "memory": "Feature branch merged: <branch-name> with <N> commits",
  "background": "Commits: <list>. Total files changed: <count>. Date range: <start> to <end>",
  "importance": "high"
})
```

## Commit Pattern Detection

The skill automatically detects these patterns:

### Conventional Commits

- `feat:` → Type: feature (importance: normal)
- `fix:` → Type: bugfix (importance: normal)
- `docs:` → Type: documentation (importance: low)
- `test:` → Type: test (importance: low)
- `refactor:` → Type: refactoring (importance: normal)
- `chore:` → Type: chore (importance: low)
- `style:` → Type: style (importance: low)

### Breaking Changes

If commit message contains `BREAKING CHANGE` or `BREAKING:`:
- Importance automatically upgraded to **high**
- Breaking change flag set to true
- ⚠️ warning added to commit summary

### Important Files

If commit affects these files:
- `package.json`, `tsconfig.json`, `.env` → Importance: normal
- `plugin.json`, `hooks.json` → Importance: high
- `CLAUDE.md`, `README.md` → Importance: normal
- Infrastructure (docker, kubernetes) → Importance: normal

### Ticket References

Automatically extracts ticket numbers from:
- Commit message: `feat: add auth (#123)`
- Branch name: `feature/AUTH-456`

## Examples

### Example 1: Single Commit Tracking

**User says:**
```
I just committed the new authentication feature, can you track it?
```

**Action:**
1. Run analyze-commits.sh
2. Parse output
3. Confirm to user

**Response:**
```markdown
✓ Commit tracked successfully!

**Commit**: feat: add OAuth2 authentication flow
- Hash: abc1234
- Type: feature
- Files changed: 8 (+245/-12 lines)
- Ticket: AUTH-123
- Importance: high (affects infrastructure)
- Stored in Memory Store ✓

This commit is now searchable in memory for future reference.
```

### Example 2: Analyzing Recent History

**User says:**
```
What did I work on in the last 5 commits?
```

**Action:**
1. Get last 5 commits with `git log --oneline -5`
2. For each commit, analyze and record
3. Create summary

**Response:**
```markdown
Here's your recent work (last 5 commits):

1. ✓ **fix: resolve auth token expiration bug** (bugfix)
   - 3 files changed, 45 minutes ago

2. ✓ **test: add auth integration tests** (test)
   - 2 files changed, 2 hours ago

3. ✓ **feat: add OAuth2 authentication flow** (feature) 🔴 BREAKING
   - 8 files changed, 1 day ago

4. ✓ **docs: update API documentation** (documentation)
   - 1 file changed, 1 day ago

5. ✓ **refactor: extract auth helpers** (refactoring)
   - 4 files changed, 2 days ago

**Summary**: 5 commits across 2 days, mostly focused on authentication.
All commits have been tracked in Memory Store.
```

### Example 3: PR Preparation

**User says:**
```
I'm about to create a PR, can you summarize my commits since main?
```

**Action:**
1. Get commit range: `git log main..HEAD --oneline`
2. Analyze all commits
3. Create PR summary with commit breakdown

**Response:**
```markdown
**PR Summary: Add OAuth2 Authentication**

**Commits**: 8 commits since main
- 3 features
- 2 bug fixes
- 2 tests
- 1 documentation update

**Breaking Changes**: Yes (1 commit)
- feat: add OAuth2 authentication flow (requires migration)

**Files Changed**: 15 files (+347/-89 lines)

**Key Changes**:
1. OAuth2 flow implementation (auth.ts, oauth.ts)
2. Token management (token-manager.ts)
3. Integration tests (auth.test.ts)
4. API documentation updates

All commits have been tracked in Memory Store for future reference.
Would you like me to draft a PR description?
```

## Session Counter Updates

When using this skill, manually update the session counter:

```bash
# Read current count
source .claude-session
COMMITS_COUNT=$((${MEMORY_COMMITS_COUNT:-0} + 1))

# Update session file
sed -i.bak "s/MEMORY_COMMITS_COUNT=.*/MEMORY_COMMITS_COUNT=${COMMITS_COUNT}/" .claude-session
rm -f .claude-session.bak
```

This ensures the session tracking remains accurate.

## Error Handling

### If analyze-commits.sh fails:

```markdown
⚠️ Unable to analyze commit: <reason>

Possible causes:
- Not in a git repository
- No commits to analyze
- MCP server connection issue

Try:
1. Verify you're in a git repo: `git status`
2. Check recent commits: `git log -1`
3. Check MCP connection: `claude mcp list`
```

### If Memory Store is unavailable:

```markdown
⚠️ Commit analyzed but not stored in Memory Store (server unavailable)

**Commit**: <message>
- Hash: <hash>
- Details: <...>

The commit metadata is captured locally and will sync when the connection is restored.
```

## Integration with Other Skills

This skill works alongside:

1. **memory-auto-track**: For automatic memory retrieval when answering questions
2. **anchor-suggester**: For documenting patterns found in commits
3. **memory-context-retrieval**: For finding related past commits

**Example workflow:**
1. User commits changes → Git Memory Tracker records them
2. User asks "How did we implement auth?" → Memory Auto-Track retrieves it
3. User creates CLAUDE.md → Anchor Suggester documents patterns
4. User asks about ownership → Memory Context Retrieval finds contributors

## Best Practices

1. **Track immediately after committing** - Don't wait until later
2. **Track PR merges** - Capture the full feature context
3. **Track breaking changes** - Always note these for future reference
4. **Batch analyze when needed** - For rebases or cherry-picks
5. **Update session counters** - Keep tracking accurate

## Testing This Skill

To verify it works:

1. Make a test commit:
   ```bash
   echo "test" > test-file.md
   git add test-file.md
   git commit -m "test: verify git-memory-tracker skill"
   ```

2. Ask Claude: "Track this commit"

3. Verify it was stored:
   ```bash
   cat .claude-session  # Should show MEMORY_COMMITS_COUNT incremented
   ```

4. Test retrieval:
   Ask Claude: "What did I just commit?"
   Should retrieve from Memory Store and mention the test commit

**Success criteria**: ✓ Commit tracked, counter incremented, retrievable from memory

---

**💡 Pro Tip**: Use this skill proactively when working on features. Track commits as you go to build a rich history for future Claude sessions!

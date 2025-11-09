---
description: Pre-commit validation to review changes before committing
---

# Validate Changes Command

Performs a pre-commit validation checkpoint. Shows detailed analysis of staged changes before you commit. Think of it as "measure twice, cut once" for git commits.

## What It Does

1. **Analyzes Staged Changes**
   - Lists all files to be committed
   - Shows change types (NEW, MODIFIED, DELETED)
   - Calculates lines added/removed
   - Detects patterns (API, UI, Service, Test, etc.)

2. **Security Checks**
   - 🔒 Detects potential secrets/tokens
   - 🐛 Flags debug code (console.log, debugger, etc.)
   - ⚠️ Warns about configuration file changes

3. **Validation Questions**
   - Do files match session goals?
   - Any mistakes or wrong approaches?
   - Should anything be corrected?
   - Is commit message semantic?

## Usage

```
/validate-changes
```

This automatically runs before `git commit`, but you can trigger it manually anytime.

## Example Output

```
╔══════════════════════════════════════════════════════════╗
║           🔍 COMMIT VALIDATION CHECKPOINT                ║
╠══════════════════════════════════════════════════════════╣
║  About to commit: 5 files                                ║
║  Changes: +347 / -12 lines                               ║
║                                                          ║
║  Session Goals:                                          ║
║    Add OAuth2 authentication                             ║
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║  Files to be committed:                                  ║
║                                                          ║
║  ✓ src/auth/oauth.ts (NEW) (Service)                    ║
║    └─ +203/-0                                            ║
║  ✓ src/api/login.ts (MODIFIED) (API)                    ║
║    └─ +89/-8                                             ║
║  ✓ src/middleware/auth.ts (NEW) (Service)               ║
║    └─ +45/-0                                             ║
║  ✓ tests/auth.test.ts (NEW) (Test)                      ║
║    └─ +110/-0                                            ║
║  ✓ package.json (MODIFIED) (Config)                     ║
║    └─ +3/-4                                              ║
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║  ⚠️  LARGE COMMIT DETECTED                               ║
║     Please validate these changes match expectations     ║
║                                                          ║
║  🐛 WARNING: Debug code detected (console.log, etc)     ║
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║  Validation Questions:                                   ║
║                                                          ║
║  1. Do all files match the session goals?                ║
║  2. Are there any mistakes or wrong approaches?          ║
║  3. Should any changes be corrected before commit?       ║
║  4. Is the commit message semantic and descriptive?      ║
╚══════════════════════════════════════════════════════════╝
```

## Security Checks

### Token/Secret Detection
Scans for patterns like:
- `token=abc123...`
- `password="secretvalue"`
- `API_KEY=long_string`

If found: **🔒 WARNING: Potential secret detected**

### Debug Code Detection
Flags common debug patterns:
- `console.log()` (JavaScript)
- `debugger` (JavaScript)
- `pdb.set_trace()` (Python)
- `binding.pry` (Ruby)

If found: **🐛 WARNING: Debug code detected**

## Large Commit Warning

Triggers when:
- More than 5 files changed, OR
- More than 300 lines added

Large commits are harder to review and more error-prone.

## Semantic Commit Reminder

The validation reminds you to use semantic commit messages:

```
feat: add OAuth2 authentication
fix: correct token refresh logic
chore: update dependencies
docs: add authentication guide
```

## When It Runs

### Automatically:
- Before every `git commit` (via PreCommit hook)

### Manually:
- `/validate-changes` command
- Before major commits to double-check

## What to Do After Validation

### ✅ If everything looks good:
```bash
git commit -m "feat(auth): add OAuth2 authentication"
```

### ⚠️ If issues found:
1. Use `/correct` to record what's wrong
2. Fix the issues
3. Run `/validate-changes` again
4. Commit when clean

### 🔒 If secrets detected:
```bash
# Remove from staging
git reset HEAD file-with-secret.env

# Add to .gitignore
echo "file-with-secret.env" >> .gitignore

# Use .env.example instead
git add .env.example
```

## Best Practices

### Before Committing:
1. Run `/validate-changes` (or let it auto-run)
2. Review each file's purpose
3. Check warnings
4. Ensure semantic commit message
5. Commit with confidence

### For Large Commits:
Consider breaking into smaller, focused commits:
```bash
# Stage related files together
git add src/auth/*.ts
git commit -m "feat(auth): add OAuth2 provider"

git add tests/auth*.ts
git commit -m "test(auth): add OAuth2 tests"
```

## Related Commands

- `/checkpoint` - Progress validation during work
- `/correct` - Fix mistakes before committing
- `/session-feedback` - View overall session quality
- `/memory-sync` - Sync changes to memory after commit

## Security Note

This validation helps prevent:
- ✓ Committing secrets/tokens (like the one in plugin.json!)
- ✓ Pushing debug code to production
- ✓ Large, unwieldy commits
- ✓ Unclear commit messages

---

Review staged changes before committing to catch issues early.

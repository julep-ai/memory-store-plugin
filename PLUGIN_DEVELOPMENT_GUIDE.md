# Plugin Development Guide: Memory Store Architecture Deep Dive

> **Purpose**: Understanding how the plugin works, how async hooks execute, and how to improve the developer experience.

## Table of Contents

1. [Current Architecture](#current-architecture)
2. [Asynchronous Hook Execution](#asynchronous-hook-execution)
3. [Data Flow Patterns](#data-flow-patterns)
4. [Current Pain Points](#current-pain-points)
5. [Testing Strategy](#testing-strategy)
6. [Improvement Opportunities](#improvement-opportunities)

---

## Current Architecture

### Plugin Structure

```
mem-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest with MCP OAuth config
├── hooks/
│   └── hooks.json               # Hook definitions (auto-discovered by Claude)
├── scripts/
│   ├── session-start.sh         # SessionStart hook
│   ├── session-end.sh           # SessionEnd hook
│   ├── track-changes.sh         # PostToolUse (Write|Edit) hook
│   ├── analyze-commits.sh       # PostToolUse (git commit) hook
│   ├── validate-commit.sh       # PostToolUse (git add) hook
│   ├── save-context.sh          # PreCompact hook
│   ├── sync-claude-md.sh        # CLAUDE.md synchronization
│   ├── project-overview.sh      # Project analysis
│   ├── progress-checkpoint.sh   # Every 10 file changes
│   └── feedback-capture.sh      # Notification hook (errors)
├── commands/
│   ├── memory-status.md         # /memory-status command
│   ├── memory-sync.md           # /memory-sync command
│   ├── memory-context.md        # /memory-context command
│   ├── memory-overview.md       # /memory-overview command
│   └── correct.md               # /correct command
└── skills/
    └── memory-context-retrieval/ # Auto-invoked skill

```

### Hook Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│                   Claude Code Session                    │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│                 SessionStart Hook Fires                   │
│                                                           │
│  1. Generate session ID: mem-2025-11-13-ABC123           │
│  2. Create session file in TMPDIR                        │
│  3. Capture git info (branch, commit, history)           │
│  4. Find CLAUDE.md files                                 │
│  5. Create .claude-memory-session marker                 │
│  6. Export CLAUDE_MEMORY_SESSION_ID env var              │
└───────────────────────┬───────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│              Development Work Happens                     │
│                                                           │
│  User: "Create auth.ts"                                  │
│  Claude: Uses Write tool                                 │
│         ↓                                                 │
│  PostToolUse Hook (matcher: "Write|Edit")                │
│         ↓                                                 │
│  track-changes.sh executes (async)                       │
│         ↓                                                 │
│  - Detects file type, pattern                            │
│  - Appends to .claude-memory-changes.jsonl               │
│  - Increments .claude-session-changes-count              │
│  - Every 10 changes → progress-checkpoint.sh             │
└───────────────────────┬───────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│              Git Operations                               │
│                                                           │
│  User: "Commit the changes"                              │
│  Claude: git add . && git commit -m "..."                │
│         ↓                                                 │
│  PostToolUse Hook (matcher: "bash.*git add")             │
│         ↓                                                 │
│  validate-commit.sh (security checks)                    │
│         ↓                                                 │
│  PostToolUse Hook (matcher: "bash.*git commit")          │
│         ↓                                                 │
│  analyze-commits.sh                                      │
│  - Parse commit message (conventional commits)           │
│  - Detect breaking changes                               │
│  - Extract ticket numbers                                │
│  - Calculate diff stats                                  │
└───────────────────────┬───────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│              SessionEnd Hook Fires                        │
│                                                           │
│  1. Calculate session duration                           │
│  2. Count files tracked, commits made                    │
│  3. Generate session quality rating                      │
│  4. Create .claude-memory-session-end.json               │
│  5. Create .claude-memory-feedback.md                    │
│  6. Sync CLAUDE.md one last time                         │
│  7. Clean up temp files                                  │
└───────────────────────────────────────────────────────────┘
```

---

## Asynchronous Hook Execution

### How Async Works

**Problem**: Hooks must not block Claude Code's UI or response time.

**Solution**: All scripts execute in the background using `&`:

```bash
# In hooks.json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/track-changes.sh"
}

# Claude Code executes this as:
bash /path/to/track-changes.sh & disown
```

### Current Async Patterns

#### 1. Fire-and-Forget (track-changes.sh)

```bash
#!/bin/bash
set -euo pipefail

# Runs completely in background
# No output to user
# Logs to stderr only
log() {
    echo "[Memory Plugin] $1" >&2
}

# Quick execution (<100ms)
# Appends to JSONL file
echo "${MEMORY_RECORD}" >> ".claude-memory-changes.jsonl"

exit 0
```

**Pros:**
- ✅ Non-blocking
- ✅ Simple
- ✅ Fast

**Cons:**
- ❌ No visibility into errors
- ❌ No confirmation of success
- ❌ Difficult to debug

#### 2. Nested Background (track-changes.sh → sync-claude-md.sh)

```bash
# In track-changes.sh
if [[ "${FILE_PATH}" =~ CLAUDE\.md$ ]]; then
    log "CLAUDE.md file modified, triggering sync..."
    bash "${CLAUDE_PLUGIN_ROOT}/scripts/sync-claude-md.sh" "${FILE_PATH}" &
fi
```

**Issue**: Background process spawns another background process
- Makes debugging harder
- No easy way to track completion
- Errors can be silent

#### 3. Checkpoint Trigger (every 10 changes)

```bash
# In track-changes.sh
CHANGES_COUNT=$((CHANGES_COUNT + 1))
echo "${CHANGES_COUNT}" > ".claude-session-changes-count"

if [[ $((CHANGES_COUNT % 10)) -eq 0 ]]; then
    log "Checkpoint threshold reached (${CHANGES_COUNT} changes)"
    bash "${CLAUDE_PLUGIN_ROOT}/scripts/progress-checkpoint.sh" &
fi
```

**Smart Pattern:**
- ✅ Batches operations
- ✅ Reduces overhead
- ✅ Provides natural breakpoints

---

## Data Flow Patterns

### Pattern 1: File-Based Communication

**How it works:**

```
Hook Script                              Memory Store
     ↓                                        ↓
Creates .jsonl file                    (Future: MCP call)
     ↓                                        ↓
Appends memory records                 memory__record
     ↓                                        ↓
Claude slash command reads file        Stores in database
     ↓                                        ↓
Shows to user / processes              Available for recall
```

**Current Implementation:**

```bash
# track-changes.sh
MEMORY_RECORD=$(cat <<EOF
{
  "memory": "File created: auth.ts (TypeScript). Pattern: API endpoint",
  "background": "Session ${SESSION_ID} - File auth.ts was created...",
  "importance": "low"
}
EOF
)

echo "${MEMORY_RECORD}" >> ".claude-memory-changes.jsonl"
```

**Problem:** Files accumulate but are never actually sent to memory store!

### Pattern 2: Environment Variables for State

```bash
# session-start.sh exports:
export CLAUDE_MEMORY_SESSION_ID="${SESSION_ID}"
export CLAUDE_MEMORY_SESSION_FILE="${SESSION_FILE}"

# Other scripts read:
SESSION_ID="${CLAUDE_MEMORY_SESSION_ID:-unknown}"
```

**Issue**: Environment variables don't persist across shell sessions
- Each script gets a fresh environment
- State must be stored in files

### Pattern 3: Marker Files

```bash
# Session active indicator
echo "${SESSION_ID}" > ".claude-memory-session"

# Changes counter
echo "${CHANGES_COUNT}" > ".claude-session-changes-count"

# Accumulated records
echo "${RECORD}" >> ".claude-memory-changes.jsonl"
```

**Works but creates clutter:**
- `.claude-memory-session`
- `.claude-memory-changes.jsonl`
- `.claude-memory-record-request.json`
- `.claude-memory-session-end.json`
- `.claude-memory-feedback.md`
- `.claude-session-changes-count`

---

## Current Pain Points

### 1. **No Actual Memory Store Integration**

**Issue**: Scripts prepare JSON payloads but never send them!

```bash
# session-start.sh (line 134-141)
cat > "${PROJECT_DIR}/.claude-memory-record-request.json" <<RECORD_EOF
{
  "memory": "Development session started...",
  "background": "...",
  "importance": "normal"
}
RECORD_EOF

log "Session start recorded. Memory request prepared for Claude."
```

**Problem**: This just creates a file. It's never actually sent to the MCP server!

**What's missing:**
- No MCP tool invocation
- No `memory__record` call
- Files just accumulate

### 2. **Silent Failures**

All scripts use `set -euo pipefail` but exit immediately on error:

```bash
#!/bin/bash
set -euo pipefail  # Exit on any error

# If this fails, script dies silently
git rev-parse --git-dir > /dev/null 2>&1
```

**User never sees errors** because hooks run in background.

### 3. **Complex File-Based State Management**

Scripts create many tracking files:

```bash
# From session-start.sh
cat > "${SESSION_FILE}" <<EOF
{
  "session_id": "${SESSION_ID}",
  "project_dir": "${PROJECT_DIR}",
  "files_tracked": [],
  "commits_analyzed": []
}
EOF
```

Then other scripts update via `jq`:

```bash
# From track-changes.sh
jq --arg file "${REL_PATH}" \
   '.files_tracked += [{"file": $file, "type": $type}]' \
   "${SESSION_FILE}" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "${SESSION_FILE}"
```

**Problems:**
- Race conditions possible
- `jq` dependency required
- Complex error handling
- Temp files left on crashes

### 4. **No Visibility for Users**

Users have no idea if hooks are working:

```bash
# Hook runs silently
log "Tracking changes to: ${FILE_PATH}" >&2
# User never sees this
```

**What users want:**
- ✓ "Tracking changes..." notification
- ✓ "Checkpoint: 10 files analyzed"
- ✓ "Memory stored successfully"
- ❌ Instead: Complete silence

### 5. **OAuth Credentials Not Used**

**Current config:**

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://beta.memory.store/mcp"],
      "oauth": {
        "enabled": true,
        "discovery_url": "https://beta.memory.store/.well-known/oauth-protected-resource"
      }
    }
  }
}
```

**But hooks never invoke MCP tools!**

The OAuth flow is ready, but scripts never call:
- `memory__record`
- `memory__recall`
- `memory__overview`

---

## Testing Strategy

### Local Development Setup

**1. Run Local Memory Store Server**

```bash
# Clone memory store server
cd ~/Desktop/autotelic
git clone https://github.com/your-org/memory-store-server
cd memory-store-server

# Install and run
npm install
npm run dev  # Runs on http://localhost:8000
```

**2. Configure Claude for Local Development**

```bash
# Add local MCP server
claude mcp add --transport http memory-store-local "http://localhost:8000/mcp"
```

**3. Test Hook Execution**

```bash
# Test session-start manually
cd /path/to/mem-plugin
export CLAUDE_PLUGIN_ROOT="$(pwd)"
bash scripts/session-start.sh

# Check output
ls -la .claude-memory-*
cat .claude-memory-record-request.json
```

**4. Test with Real Claude Session**

```bash
# Start Claude in plugin directory
cd ~/Desktop/autotelic/mem-plugin
claude

# In Claude session:
# - Create a file
# - Check if .claude-memory-changes.jsonl updated
# - Commit something
# - Check if hooks fired
```

### Debugging Hooks

**Enable verbose logging:**

```bash
# Add to scripts
set -x  # Print every command
exec 2>> /tmp/memory-plugin-debug.log  # Log to file
```

**Check if hooks are registered:**

```bash
# Claude debug mode
claude --debug

# Look for: "Registered hook: SessionStart"
```

**Manual testing:**

```bash
# Test individual hooks
cd /path/to/mem-plugin
export CLAUDE_PLUGIN_ROOT="$(pwd)"
export CLAUDE_MEMORY_SESSION_ID="test-session"
export CLAUDE_MEMORY_SESSION_FILE="/tmp/test-session.json"

# Run hook
bash scripts/track-changes.sh test-file.ts

# Check output
cat .claude-memory-changes.jsonl
```

---

## Improvement Opportunities

### 1. **Actually Send Data to Memory Store**

**Current** (broken):
```bash
# Just creates a file
cat > ".claude-memory-record-request.json" <<EOF
{"memory": "...", "background": "..."}
EOF
```

**Improved** (working):
```bash
# Use Claude slash command to invoke MCP tool
claude-code-invoke-tool "memory__record" '{
  "memory": "Development session started",
  "background": "Session ID, project info...",
  "importance": "normal"
}'
```

**Or create a helper script:**

```bash
# scripts/lib/memory-store.sh
memory_record() {
    local memory="$1"
    local background="$2"
    local importance="${3:-normal}"

    # Invoke MCP tool through Claude Code
    # This requires Claude Code API or slash command integration
    echo '{"memory":"'$memory'","background":"'$background'","importance":"'$importance'"}' \
        > /tmp/memory-record-$$.json

    # Notify Claude to process this
    # (Implementation depends on Claude Code plugin API)
}
```

### 2. **Add User Notifications**

**Use Claude Code notification system:**

```bash
# In track-changes.sh
notify_user() {
    # Claude Code has a notification system
    # Send non-blocking notification
    echo "NOTIFICATION: $1" >&1  # stdout goes to Claude
}

notify_user "📝 Tracked change: ${FILE_PATH}"
```

**Batch notifications:**

```bash
# Every 10 files
if [[ $((CHANGES_COUNT % 10)) -eq 0 ]]; then
    notify_user "✓ Checkpoint: ${CHANGES_COUNT} files analyzed"
fi
```

### 3. **Simplify State Management**

**Replace complex file operations with simple append-only log:**

```bash
# Instead of updating JSON with jq
# Use JSONL (newline-delimited JSON)

# Append is atomic, no race conditions
echo '{"type":"file_change","file":"'$FILE'","time":"'$TIME'"}' \
    >> .claude-memory-events.jsonl

# Process at session end
cat .claude-memory-events.jsonl | \
    jq -s 'group_by(.type) | map({type: .[0].type, count: length})'
```

### 4. **Add Health Checks**

**Verify MCP connection before hooks run:**

```bash
# scripts/lib/health-check.sh
check_memory_store() {
    # Test if MCP server is reachable
    if claude mcp list | grep -q "memory-store.*Connected"; then
        return 0
    else
        log "⚠️  Memory store not connected"
        return 1
    fi
}

# In session-start.sh
if ! check_memory_store; then
    log "Memory store unavailable, running in offline mode"
    # Continue but don't try to send data
fi
```

### 5. **Progressive Enhancement**

**Graceful degradation when memory store is unavailable:**

```bash
# Always collect data locally
collect_memory_data() {
    echo "$MEMORY_JSON" >> .claude-memory-queue.jsonl
}

# Try to sync, but don't fail if it doesn't work
sync_memory_store() {
    if check_memory_store; then
        while read -r record; do
            memory_record "$record" || {
                log "Sync failed, keeping in queue"
                break
            }
        done < .claude-memory-queue.jsonl

        # Clear queue on success
        > .claude-memory-queue.jsonl
    fi
}
```

### 6. **Better Async Patterns**

**Use named pipes for inter-process communication:**

```bash
# Create a processing queue
QUEUE_PIPE="/tmp/memory-plugin-queue-$$"
mkfifo "$QUEUE_PIPE"

# Background processor
process_queue() {
    while read -r event; do
        # Process event
        memory_record "$event"
    done < "$QUEUE_PIPE"
} &

# Hooks write to queue
echo "$MEMORY_EVENT" > "$QUEUE_PIPE"
```

### 7. **Development Mode**

**Add verbose mode for debugging:**

```bash
# In plugin.json, add setting
{
  "settings": {
    "debug_mode": false,
    "verbose_notifications": false
  }
}

# In scripts
if [[ "${MEMORY_PLUGIN_DEBUG:-false}" == "true" ]]; then
    set -x  # Enable bash debug
    notify_user "🔍 Debug: Hook executing - ${BASH_SOURCE[0]}"
fi
```

---

## Recommended Next Steps

### Phase 1: Make It Work (MVP)

1. **Actually call MCP tools**
   - Integrate `memory__record` calls
   - Test with local server
   - Verify data reaches memory store

2. **Add basic notifications**
   - Session start/end
   - Checkpoint milestones
   - Error notifications

3. **Health checks**
   - Verify MCP connection
   - Graceful fallback

### Phase 2: Improve UX

1. **Simplify state management**
   - Reduce number of tracking files
   - Use simpler data structures
   - Better error handling

2. **User visibility**
   - Progress indicators
   - `/memory-status` shows real data
   - Sync confirmations

3. **Better async**
   - Queue system
   - Batch operations
   - Reduce overhead

### Phase 3: Advanced Features

1. **Smart batching**
   - Combine related memories
   - Reduce API calls
   - Better context grouping

2. **Offline support**
   - Queue when disconnected
   - Sync when reconnected
   - Never lose data

3. **Analytics**
   - Session quality metrics
   - Pattern detection
   - Team insights

---

## Example: Complete Flow with MCP Integration

```bash
#!/bin/bash
# track-changes-improved.sh

set -euo pipefail

# Configuration
MEMORY_STORE_AVAILABLE=false

# Check if memory store is available
if claude mcp list 2>/dev/null | grep -q "memory-store.*Connected"; then
    MEMORY_STORE_AVAILABLE=true
fi

# Get file info
FILE_PATH="${1:-unknown}"
PATTERN=$(detect_pattern "$FILE_PATH")

# Create memory record
MEMORY_JSON=$(cat <<EOF
{
  "memory": "File modified: ${FILE_PATH}",
  "background": "Pattern: ${PATTERN}, Session: ${SESSION_ID}",
  "importance": "low"
}
EOF
)

# Try to send to memory store
if [[ "$MEMORY_STORE_AVAILABLE" == "true" ]]; then
    # Send via MCP (pseudo-code - actual implementation depends on Claude Code API)
    if send_to_memory_store "$MEMORY_JSON"; then
        log "✓ Memory recorded: ${FILE_PATH}"
    else
        # Queue for later
        echo "$MEMORY_JSON" >> .claude-memory-queue.jsonl
        log "⚠️ Queued for later: ${FILE_PATH}"
    fi
else
    # Store locally
    echo "$MEMORY_JSON" >> .claude-memory-queue.jsonl
    log "📝 Stored locally: ${FILE_PATH}"
fi

# Notify user every 5 files
CHANGES_COUNT=$(($(cat .claude-session-changes-count 2>/dev/null || echo 0) + 1))
echo "$CHANGES_COUNT" > .claude-session-changes-count

if [[ $((CHANGES_COUNT % 5)) -eq 0 ]]; then
    notify_user "✓ Tracked ${CHANGES_COUNT} changes"
fi

exit 0
```

---

## Conclusion

The plugin has a solid foundation but needs work to actually integrate with the memory store. The biggest issues are:

1. ❌ **Data never reaches memory store** - Just creates files
2. ❌ **No user visibility** - Silent execution
3. ❌ **Complex state management** - Many tracking files
4. ⚠️ **No error handling** - Silent failures

With the improvements above, the plugin can become:

1. ✅ **Functional** - Actually stores memories
2. ✅ **Visible** - Users see what's happening
3. ✅ **Reliable** - Handles errors gracefully
4. ✅ **Fast** - Efficient async execution

The OAuth integration is already set up correctly - we just need to use it!

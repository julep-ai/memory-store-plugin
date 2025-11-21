#!/bin/bash
# Save Context Hook - Store important context before conversation compaction
# This script runs before Claude Code compacts the conversation history

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"

# Load session state from project-local file
SESSION_FILE="${PROJECT_DIR}/.claude-session"
if [[ -f "${SESSION_FILE}" ]]; then
    source "${SESSION_FILE}"
fi

SESSION_ID="${MEMORY_SESSION_ID:-unknown}"

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

log "Saving context before compaction..."

# This hook is critical for preserving important information before the
# conversation history is compressed. We want to capture:
# 1. Key decisions made in the conversation
# 2. Important technical choices
# 3. Business logic discussed
# 4. Patterns established
# 5. Reasoning behind implementations

# Since we can't directly access the conversation, we'll capture the
# current state of the project instead

# Get recent git activity
if git rev-parse --git-dir > /dev/null 2>&1; then
    RECENT_COMMITS=$(git log --oneline -10 2>/dev/null || echo "")
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    UNCOMMITTED_CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
    
    log "Branch: ${CURRENT_BRANCH}, Uncommitted changes: ${UNCOMMITTED_CHANGES}"
else
    RECENT_COMMITS=""
    CURRENT_BRANCH="not-a-git-repo"
    UNCOMMITTED_CHANGES="0"
fi

# Get recent file modifications (last 1 hour)
RECENT_FILES=$(find "${PROJECT_DIR}" -type f -mmin -60 2>/dev/null | head -20 || echo "")
RECENT_FILE_COUNT=$(echo "${RECENT_FILES}" | grep -c . || echo "0")

log "Recently modified files: ${RECENT_FILE_COUNT}"

# Look for TODO comments added recently (potential decisions)
TODO_COMMENTS=$(find "${PROJECT_DIR}" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -mmin -60 -exec grep -l "TODO\|FIXME\|NOTE" {} \; 2>/dev/null | wc -l | tr -d ' ')

# Check for new or modified CLAUDE.md files
CLAUDE_MD_MODIFIED=$(find "${PROJECT_DIR}" -type f -name "CLAUDE.md" -mmin -60 2>/dev/null || echo "")

if [[ -n "${CLAUDE_MD_MODIFIED}" ]]; then
    log "CLAUDE.md files modified recently, capturing updates..."
    
    # Sync CLAUDE.md one more time
    if [[ -f "${CLAUDE_PLUGIN_ROOT}/scripts/sync-claude-md.sh" ]]; then
        bash "${CLAUDE_PLUGIN_ROOT}/scripts/sync-claude-md.sh" &
    fi
fi

# Prepare context summary
CONTEXT_SUMMARY=$(cat <<EOF
Context snapshot before conversation compaction:
Branch: ${CURRENT_BRANCH}
Recent commits: $(echo "${RECENT_COMMITS}" | wc -l | tr -d ' ')
Uncommitted changes: ${UNCOMMITTED_CHANGES}
Files modified (last hour): ${RECENT_FILE_COUNT}
TODO comments: ${TODO_COMMENTS}
CLAUDE.md updates: $(echo "${CLAUDE_MD_MODIFIED}" | grep -c . || echo "0")
EOF
)

# Record context snapshot in Memory Store (async, in background)
(
  # Build memory payload with context summary
  MEMORY_JSON=$(cat <<RECORD_EOF
{
  "memory": "Conversation context saved before compaction in ${SESSION_ID}",
  "background": "${CONTEXT_SUMMARY}. Session: ${SESSION_ID}. This snapshot captures the state before conversation history was compacted to preserve important context for debugging and continuity.",
  "importance": "high"
}
RECORD_EOF
)

  # Invoke MCP tool directly (async) - HIGH importance for debugging
  echo "${MEMORY_JSON}" | claude mcp call memory-store record 2>/dev/null || true

) &  # Background execution

log "Context saved successfully"
log "State: ${CURRENT_BRANCH} with ${UNCOMMITTED_CHANGES} uncommitted changes"

# Output JSON to inform Claude
cat <<EOF
{
  "additionalContext": "💾 Context snapshot saved before compaction. Branch: ${CURRENT_BRANCH}, Recent files: ${RECENT_FILE_COUNT}, Uncommitted: ${UNCOMMITTED_CHANGES}. This preserves important context for post-compaction continuity.",
  "continue": true
}
EOF

exit 0

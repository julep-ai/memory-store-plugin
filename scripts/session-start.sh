#!/bin/bash
# Session Start Hook - Initialize session tracking and load context
# This script runs at the beginning of each Claude Code session

set -euo pipefail

# JSON escape function to prevent command injection
json_escape() {
    printf '%s' "$1" | \
        sed 's/\\/\\\\/g' | \
        sed 's/"/\\"/g' | \
        tr '\n' ' ' | \
        sed 's/\t/\\t/g' | \
        sed 's/\r/\\r/g'
}

# Get project directory (working directory when Claude Code starts)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"
SESSION_ID="mem-$(date +%Y%m%d)-$(uuidgen | cut -d'-' -f1)"
START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Load project context metadata for rich background
PROJECT_CONTEXT_FILE="${PROJECT_DIR}/.claude-project-context"
if [[ -f "${PROJECT_CONTEXT_FILE}" ]]; then
    source "${PROJECT_CONTEXT_FILE}"
fi

# Get project name from directory
PROJECT_NAME=$(basename "${PROJECT_DIR}")

# Persist session state in project-local file for other hooks
SESSION_FILE="${PROJECT_DIR}/.claude-session"
cat > "${SESSION_FILE}" <<EOF
MEMORY_SESSION_ID="${SESSION_ID}"
MEMORY_SESSION_START="${START_TIME}"
MEMORY_CHANGES_COUNT=0
MEMORY_COMMITS_COUNT=0
EOF

# Get git info if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    RECENT_COMMITS=$(git log --oneline -5 2>/dev/null | head -3 | sed 's/"/\\"/g' | tr '\n' '; ' || echo "")
else
    GIT_BRANCH="not-a-git-repo"
    GIT_COMMIT="none"
    RECENT_COMMITS=""
fi

# Find CLAUDE.md files
CLAUDE_MD_COUNT=$(find "${PROJECT_DIR}" -name "CLAUDE.md" -o -name "claude.md" 2>/dev/null | wc -l | tr -d ' ')

# Count files in project (limit search for performance)
FILE_COUNT=$(find "${PROJECT_DIR}" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')

# Check MCP connection status
MCP_STATUS="unknown"
MCP_SETUP_CMD=""
if command -v claude &> /dev/null; then
    # Check if memory-store MCP server is configured
    if claude mcp list 2>/dev/null | grep -q "memory-store"; then
        MCP_STATUS="configured"
    else
        MCP_STATUS="not-configured"
        MCP_SETUP_CMD="claude mcp add memory-store -t http https://beta.memory.store/mcp"
    fi
fi

# Escape all variables for safe JSON interpolation
SESSION_ID_ESCAPED=$(json_escape "${SESSION_ID}")
PROJECT_NAME_ESCAPED=$(json_escape "${PROJECT_NAME}")
GIT_BRANCH_ESCAPED=$(json_escape "${GIT_BRANCH}")
PROJECT_DIR_ESCAPED=$(json_escape "${PROJECT_DIR}")
START_TIME_ESCAPED=$(json_escape "${START_TIME}")
RECENT_COMMITS_ESCAPED=$(json_escape "${RECENT_COMMITS}")
GIT_COMMIT_ESCAPED=$(json_escape "${GIT_COMMIT}")
MCP_STATUS_ESCAPED=$(json_escape "${MCP_STATUS}")

# Build foundational background context (Claude will enrich with conversational context)
BACKGROUND_CONTEXT="Session: ${SESSION_ID}, Started: ${START_TIME_ESCAPED}, Project: ${PROJECT_NAME}, Dir: ${PROJECT_DIR_ESCAPED}, Branch: ${GIT_BRANCH}, Commit: ${GIT_COMMIT_ESCAPED}, Files: ${FILE_COUNT}, MCP: ${MCP_STATUS}"

# Add version if available
if [[ -n "${VERSION:-}" ]]; then
    BACKGROUND_CONTEXT="${BACKGROUND_CONTEXT}, Version: ${VERSION}"
fi

# Recent commits summary
if [[ -n "${RECENT_COMMITS}" ]]; then
    BACKGROUND_CONTEXT="${BACKGROUND_CONTEXT}, Recent: ${RECENT_COMMITS_ESCAPED}"
fi

# Build recall cues for context retrieval
RECALL_CUES_ESCAPED=$(json_escape "${PROJECT_NAME}, ${GIT_BRANCH}, recent work, session, commit")
RECALL_BG_ESCAPED=$(json_escape "Session start in ${PROJECT_NAME} on ${GIT_BRANCH}. Loading recent context to understand current work.")

# Queue memory for processing (bypasses additionalContext visibility issue)
bash "${PROJECT_DIR}/scripts/queue-memory.sh" \
  --memory "Session ${SESSION_ID} started in ${PROJECT_NAME} on branch ${GIT_BRANCH}" \
  --background "${BACKGROUND_CONTEXT}" \
  --importance "normal" 2>/dev/null || true

# Build MCP status message
if [[ "${MCP_STATUS}" == "configured" ]]; then
    MCP_MESSAGE="✅ Memory Store MCP: Connected"
elif [[ "${MCP_STATUS}" == "not-configured" ]]; then
    MCP_MESSAGE="⚠️  Memory Store MCP: Not configured

📝 To enable memory storage, run:
   ${MCP_SETUP_CMD}

   This enables automatic memory persistence across sessions."
else
    MCP_MESSAGE="ℹ️  Memory Store MCP: Status unknown (Claude CLI not available)"
fi

# Output JSON to inform Claude about the session
cat <<EOF
{
  "additionalContext": "🚀 Session ${SESSION_ID} started in ${PROJECT_NAME}/${GIT_BRANCH} at ${START_TIME}.

📊 Project snapshot: ${FILE_COUNT} files, ${CLAUDE_MD_COUNT} CLAUDE.md files.
📝 Recent commits: ${RECENT_COMMITS}

${MCP_MESSAGE}

💾 Memory queued for automatic processing.
🔍 Check for queued memories and recent context using memory-queue-processor skill.",
  "continue": true
}
EOF

exit 0

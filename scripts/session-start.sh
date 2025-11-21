#!/bin/bash
# Session Start Hook - Initialize session tracking and load context
# This script runs at the beginning of each Claude Code session

set -euo pipefail

# Get project directory (working directory when Claude Code starts)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"
SESSION_ID="mem-$(date +%Y%m%d)-$(uuidgen | cut -d'-' -f1)"
START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

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

# Record session start in Memory Store (async, in background)
# This runs independently of Claude's conversation flow
(
  # Build memory payload as JSON
  MEMORY_JSON=$(cat <<RECORD_EOF
{
  "memory": "Session ${SESSION_ID} started in ${PROJECT_NAME} on branch ${GIT_BRANCH}",
  "background": "Project directory: ${PROJECT_DIR}. Start time: ${START_TIME}. Files: ${FILE_COUNT}. CLAUDE.md files: ${CLAUDE_MD_COUNT}. Recent commits: ${RECENT_COMMITS}. Current commit: ${GIT_COMMIT}.",
  "importance": "normal"
}
RECORD_EOF
)

  # Invoke MCP tool directly via claude CLI (captures async)
  # Using || true to prevent hook failure if Memory Store is unavailable
  echo "${MEMORY_JSON}" | claude mcp call memory-store record 2>/dev/null || true

) &  # Run in background to avoid blocking session start

# Load project overview from Memory Store (async, in background)
# This retrieves relevant context to help Claude understand the project
(
  # Invoke overview with 'standard' mode for quick context load
  claude mcp call memory-store overview --mode standard 2>/dev/null > "${PROJECT_DIR}/.claude-session-overview.json" || true

  # Also recall recent work on this project/branch
  RECALL_CUES='["'${PROJECT_NAME}'", "'${GIT_BRANCH}'", "recent work", "session", "commit"]'
  RECALL_BG="Session start in ${PROJECT_NAME} on ${GIT_BRANCH}. Loading recent context to understand current work."

  echo "{\"cues\": ${RECALL_CUES}, \"background\": \"${RECALL_BG}\", \"k\": 5}" | \
    claude mcp call memory-store recall 2>/dev/null > "${PROJECT_DIR}/.claude-session-recall.json" || true

) &  # Run in background

# Output JSON to inform Claude about the session (non-blocking)
cat <<EOF
{
  "additionalContext": "🚀 Session ${SESSION_ID} started in ${PROJECT_NAME}/${GIT_BRANCH} at ${START_TIME}. Project has ${FILE_COUNT} files, ${CLAUDE_MD_COUNT} CLAUDE.md files. Recent commits: ${RECENT_COMMITS}. Memory Store is loading project overview and recent context automatically in the background.",
  "continue": true
}
EOF

exit 0

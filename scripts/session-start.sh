#!/bin/bash
# Session Start Hook - Initialize session tracking and load context
# This script runs at the beginning of each Claude Code session

set -euo pipefail

# Get project directory (working directory when Claude Code starts)
PROJECT_DIR="${PWD}"
SESSION_ID="mem-$(date +%Y-%m-%d)-$(uuidgen | cut -d'-' -f1)"
SESSION_FILE="${TMPDIR:-/tmp}/claude-memory-session-${SESSION_ID}.json"

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

log "Session starting: ${SESSION_ID}"

# Initialize session metadata
cat > "${SESSION_FILE}" <<EOF
{
  "session_id": "${SESSION_ID}",
  "project_dir": "${PROJECT_DIR}",
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "files_tracked": [],
  "commits_analyzed": [],
  "context_stored": 0
}
EOF

# Export session ID for other scripts
export CLAUDE_MEMORY_SESSION_ID="${SESSION_ID}"
export CLAUDE_MEMORY_SESSION_FILE="${SESSION_FILE}"

# Get project name from directory
PROJECT_NAME=$(basename "${PROJECT_DIR}")

# Record session start in memory store using MCP
# Note: This would typically call the memory MCP server tools
# For now, we'll prepare the data structure

log "Capturing project state..."

# Get git info if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "")
    
    log "Git branch: ${GIT_BRANCH}"
    log "Git commit: ${GIT_COMMIT}"
else
    GIT_BRANCH="not-a-git-repo"
    GIT_COMMIT="none"
    RECENT_COMMITS=""
fi

# Find CLAUDE.md files
CLAUDE_MD_FILES=$(find "${PROJECT_DIR}" -name "CLAUDE.md" -o -name "claude.md" 2>/dev/null || echo "")
CLAUDE_MD_COUNT=$(echo "${CLAUDE_MD_FILES}" | grep -c . || echo "0")

log "Found ${CLAUDE_MD_COUNT} CLAUDE.md file(s)"

# Count files in project
FILE_COUNT=$(find "${PROJECT_DIR}" -type f 2>/dev/null | wc -l | tr -d ' ')

# Prepare memory record payload
MEMORY_PAYLOAD=$(cat <<EOF
{
  "memory": "Development session started in project ${PROJECT_NAME} on branch ${GIT_BRANCH}",
  "background": "Session ${SESSION_ID} initialized. Project has ${FILE_COUNT} files, ${CLAUDE_MD_COUNT} CLAUDE.md files. Current commit: ${GIT_COMMIT}. Working directory: ${PROJECT_DIR}",
  "importance": "normal"
}
EOF
)

log "Session initialized. Ready to track development."
log "Session file: ${SESSION_FILE}"

# Optional: Load relevant context from memory store
# This would query memory_recall for recent work in this project
log "Loading relevant context from memory store..."

# Create a marker file to indicate plugin is active
echo "${SESSION_ID}" > "${PROJECT_DIR}/.claude-memory-session"

exit 0

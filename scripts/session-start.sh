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

# Output JSON to trigger Claude to load context and record session start
cat <<EOF
{
  "additionalContext": "🚀 Session ${SESSION_ID} started in ${PROJECT_NAME}/${GIT_BRANCH} at ${START_TIME}. Project has ${FILE_COUNT} files, ${CLAUDE_MD_COUNT} CLAUDE.md files. Recent commits: ${RECENT_COMMITS}. Current commit: ${GIT_COMMIT}. Session state saved to .claude-session file. IMPORTANT: (1) Call mcp__memory-store__overview with mode='full' to load complete project context. (2) Call mcp__memory-store__record to save: memory='Session ${SESSION_ID} started in ${PROJECT_NAME} on branch ${GIT_BRANCH}', background='Project directory: ${PROJECT_DIR}. Start time: ${START_TIME}. Files tracked: ${FILE_COUNT}.', importance='normal'.",
  "continue": true
}
EOF

exit 0

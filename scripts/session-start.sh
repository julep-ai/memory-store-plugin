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

# Persist session state in environment file for other hooks
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
    cat >> "${CLAUDE_ENV_FILE}" <<EOF
export MEMORY_SESSION_ID="${SESSION_ID}"
export MEMORY_SESSION_START="${START_TIME}"
export MEMORY_CHANGES_COUNT=0
export MEMORY_COMMITS_COUNT=0
EOF
fi

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

# Output JSON to trigger Claude to store this in memory
# The additionalContext will be seen by the Memory Auto-Track Skill
cat <<EOF
{
  "additionalContext": "🚀 Development session starting in project ${PROJECT_NAME} on branch ${GIT_BRANCH}. Session ID: ${SESSION_ID}. Current commit: ${GIT_COMMIT}. Project has ${FILE_COUNT} files and ${CLAUDE_MD_COUNT} CLAUDE.md files. Recent commits: ${RECENT_COMMITS}. This session context should be stored in memory using memory__record tool with importance: normal. Background context: Session initialized at ${START_TIME} in ${PROJECT_DIR}.",
  "continue": true
}
EOF

exit 0

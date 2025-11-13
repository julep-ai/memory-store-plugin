#!/bin/bash
# Session End Hook - Summarize session and store learnings
# This script runs at the end of each Claude Code session

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"
SESSION_ID="${MEMORY_SESSION_ID:-unknown}"
START_TIME="${MEMORY_SESSION_START:-unknown}"
FILES_TRACKED="${MEMORY_CHANGES_COUNT:-0}"
COMMITS_ANALYZED="${MEMORY_COMMITS_COUNT:-0}"

# Calculate session duration
if [[ "${START_TIME}" != "unknown" ]]; then
    START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "${START_TIME}" "+%s" 2>/dev/null || echo "0")
    END_EPOCH=$(date "+%s")
    DURATION=$((END_EPOCH - START_EPOCH))
    DURATION_HOURS=$((DURATION / 3600))
    DURATION_MINS=$(((DURATION % 3600) / 60))
    if [[ $DURATION_HOURS -gt 0 ]]; then
        DURATION_HUMAN="${DURATION_HOURS}h ${DURATION_MINS}m"
    else
        DURATION_HUMAN="${DURATION_MINS}m"
    fi
else
    DURATION_HUMAN="unknown"
fi

# Get git info
PROJECT_NAME=$(basename "${PROJECT_DIR}")
GIT_BRANCH="unknown"
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    MODIFIED_FILES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
else
    MODIFIED_FILES="0"
fi

# Build session summary
SESSION_SUMMARY="Session completed: ${DURATION_HUMAN} duration, ${FILES_TRACKED} files tracked, ${COMMITS_ANALYZED} commits analyzed"

# Build comprehensive background context
END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
BACKGROUND_CONTEXT="Session ${SESSION_ID} ended at ${END_TIME} in project ${PROJECT_NAME} on branch ${GIT_BRANCH}. Duration: ${DURATION_HUMAN}. Files tracked: ${FILES_TRACKED}. Commits analyzed: ${COMMITS_ANALYZED}. Modified files still pending: ${MODIFIED_FILES}. This session's learnings should inform future work on similar features."

# Output JSON with session summary
cat <<EOF
{
  "additionalContext": "👋 ${SESSION_SUMMARY}. Store this session summary in memory using memory__record with importance: normal, background: '${BACKGROUND_CONTEXT}'",
  "userMessage": "✓ Session complete! Tracked ${FILES_TRACKED} files and ${COMMITS_ANALYZED} commits in ${DURATION_HUMAN}",
  "continue": true
}
EOF

exit 0

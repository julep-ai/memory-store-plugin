#!/bin/bash
# Session End Hook - Summarize session and store learnings
# This script runs at the end of each Claude Code session

set -euo pipefail

# JSON escape function to prevent command injection
json_escape() {
    printf '%s' "$1" | \
        sed 's/\\/\\\\/g' | \
        sed 's/"/\\"/g' | \
        sed ':a;N;$!ba;s/\n/\\n/g' | \
        sed 's/\t/\\t/g' | \
        sed 's/\r/\\r/g'
}

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"

# Load session state from project-local file
SESSION_FILE="${PROJECT_DIR}/.claude-session"
if [[ -f "${SESSION_FILE}" ]]; then
    source "${SESSION_FILE}"
fi

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
SESSION_SUMMARY="Session ${SESSION_ID} completed in ${PROJECT_NAME} after ${DURATION_HUMAN}"
SESSION_DETAILS="${FILES_TRACKED} files tracked, ${COMMITS_ANALYZED} commits analyzed, ${MODIFIED_FILES} files still modified"

# Build comprehensive background context
END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
BACKGROUND_CONTEXT="Session ${SESSION_ID} ended at ${END_TIME} in project ${PROJECT_NAME} (${PROJECT_DIR}) on branch ${GIT_BRANCH}. Started: ${START_TIME}. Duration: ${DURATION_HUMAN}. Files tracked: ${FILES_TRACKED}. Commits analyzed: ${COMMITS_ANALYZED}. Modified files still pending: ${MODIFIED_FILES}. This session's learnings should inform future work on similar features."

# Queue session summary for processing
bash "${PROJECT_DIR}/scripts/queue-memory.sh" \
  --memory "${SESSION_SUMMARY}. ${SESSION_DETAILS}" \
  --background "${BACKGROUND_CONTEXT}" \
  --importance "normal" 2>/dev/null || true

# Clean up temporary tracking files
rm -f "${PROJECT_DIR}/.claude-memory-changes.jsonl" \
      "${PROJECT_DIR}/.claude-session-changes-count" \
      "${PROJECT_DIR}/.claude-memory-record-request.json" \
      "${PROJECT_DIR}/.claude-memory-session-end.json" \
      "${PROJECT_DIR}/.claude-session-overview.json" \
      "${PROJECT_DIR}/.claude-session-recall.json" \
      "${SESSION_FILE}" 2>/dev/null || true

# Output JSON with informational context
cat <<EOF
{
  "additionalContext": "👋 Session ${SESSION_ID} ending. ${SESSION_SUMMARY}. Details: ${SESSION_DETAILS}. Memory queued.",
  "userMessage": "✓ Session ending! ${FILES_TRACKED} files tracked, ${COMMITS_ANALYZED} commits analyzed over ${DURATION_HUMAN}",
  "continue": true
}
EOF

exit 0

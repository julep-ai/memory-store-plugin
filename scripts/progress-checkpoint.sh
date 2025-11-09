#!/bin/bash
# Progress Checkpoint - Interactive validation after significant work
# This script triggers after N file changes to check in with the user

set -euo pipefail

PROJECT_DIR="${PWD}"
SESSION_ID="${CLAUDE_MEMORY_SESSION_ID:-unknown}"
SESSION_FILE="${CLAUDE_MEMORY_SESSION_FILE:-}"

# Log function
log() {
    echo "[Memory Plugin - Progress Checkpoint] $1" >&2
}

log "Progress checkpoint triggered"

# Get session metrics
CHANGES_COUNT=$(cat "${PROJECT_DIR}/.claude-session-changes-count" 2>/dev/null || echo "0")
SESSION_GOALS=$(cat "${PROJECT_DIR}/.claude-session-goals" 2>/dev/null || echo "")

# Get files changed in this session
if [[ -f "${PROJECT_DIR}/.claude-memory-changes.jsonl" ]]; then
    FILES_CHANGED=$(grep -c "memory" "${PROJECT_DIR}/.claude-memory-changes.jsonl" || echo "0")
else
    FILES_CHANGED="${CHANGES_COUNT}"
fi

# Calculate lines of code changed
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Get uncommitted changes
    LOC_CHANGED=$(git diff --stat | tail -1 | awk '{print $4, $6}' || echo "0 0")
    FILES_MODIFIED=$(git status --short | wc -l | tr -d ' ')
else
    LOC_CHANGED="unknown"
    FILES_MODIFIED="${FILES_CHANGED}"
fi

# Parse goals to show completion status
GOALS_LIST=""
GOALS_COMPLETED=""
GOALS_IN_PROGRESS=""

if [[ -f "${PROJECT_DIR}/.claude-session-goals-status.json" ]]; then
    # Read goal statuses
    GOALS_COMPLETED=$(jq -r '.completed | length' "${PROJECT_DIR}/.claude-session-goals-status.json" 2>/dev/null || echo "0")
    GOALS_IN_PROGRESS=$(jq -r '.in_progress | length' "${PROJECT_DIR}/.claude-session-goals-status.json" 2>/dev/null || echo "1")

    # Get completed goals
    COMPLETED_ITEMS=$(jq -r '.completed[]' "${PROJECT_DIR}/.claude-session-goals-status.json" 2>/dev/null || echo "")
    IN_PROGRESS_ITEMS=$(jq -r '.in_progress[]' "${PROJECT_DIR}/.claude-session-goals-status.json" 2>/dev/null || echo "")
else
    GOALS_COMPLETED="0"
    GOALS_IN_PROGRESS="unknown"
    COMPLETED_ITEMS=""
    IN_PROGRESS_ITEMS="${SESSION_GOALS}"
fi

# Build checkpoint summary
CHECKPOINT_SUMMARY=$(cat <<EOF

╔══════════════════════════════════════════════════════════╗
║           📊 PROGRESS CHECKPOINT                         ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  Session: ${SESSION_ID}                ║
║  Changes: ${CHANGES_COUNT} file operations completed              ║
║  Files modified: ${FILES_MODIFIED}                                  ║
║  Lines changed: ${LOC_CHANGED}                          ║
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║  Session Goals:                                          ║
║                                                          ║
EOF
)

# Add completed goals
if [[ -n "${COMPLETED_ITEMS}" ]]; then
    CHECKPOINT_SUMMARY="${CHECKPOINT_SUMMARY}
║  ✅ Completed:                                           ║"
    while IFS= read -r goal; do
        [[ -z "$goal" ]] && continue
        CHECKPOINT_SUMMARY="${CHECKPOINT_SUMMARY}
║    ✓ ${goal:0:52}"
    done <<< "$COMPLETED_ITEMS"
    CHECKPOINT_SUMMARY="${CHECKPOINT_SUMMARY}
║                                                          ║"
fi

# Add in-progress goals
if [[ -n "${IN_PROGRESS_ITEMS}" ]]; then
    CHECKPOINT_SUMMARY="${CHECKPOINT_SUMMARY}
║  ⏳ In Progress:                                         ║"
    while IFS= read -r goal; do
        [[ -z "$goal" ]] && continue
        CHECKPOINT_SUMMARY="${CHECKPOINT_SUMMARY}
║    → ${goal:0:52}"
    done <<< "$IN_PROGRESS_ITEMS"
fi

CHECKPOINT_SUMMARY="${CHECKPOINT_SUMMARY}
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║  🤔 Checkpoint Questions:                                ║
║                                                          ║
║  1. Are the changes matching your expectations?          ║
║  2. Is the approach correct, or should I pivot?          ║
║  3. Any corrections needed before continuing?            ║
║  4. Should we commit the current progress?               ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"

# Output checkpoint summary
echo "${CHECKPOINT_SUMMARY}"

# Save checkpoint data
CHECKPOINT_DATA=$(cat <<EOF
{
  "session_id": "${SESSION_ID}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "changes_count": ${CHANGES_COUNT},
  "files_modified": ${FILES_MODIFIED},
  "goals_completed": ${GOALS_COMPLETED},
  "goals_in_progress": ${GOALS_IN_PROGRESS},
  "checkpoint_number": $(ls -1 ${PROJECT_DIR}/.claude-checkpoint-*.json 2>/dev/null | wc -l | tr -d ' ')
}
EOF
)

CHECKPOINT_FILE="${PROJECT_DIR}/.claude-checkpoint-$(date +%s).json"
echo "${CHECKPOINT_DATA}" > "${CHECKPOINT_FILE}"

log "Checkpoint saved to ${CHECKPOINT_FILE}"

# Store checkpoint in memory for future reference
CHECKPOINT_MEMORY=$(cat <<EOF
{
  "memory": "Progress checkpoint: ${CHANGES_COUNT} changes completed in session ${SESSION_ID}",
  "background": "Checkpoint at $(date -u +%Y-%m-%dT%H:%M:%SZ). Files modified: ${FILES_MODIFIED}. Goals completed: ${GOALS_COMPLETED}. User validation requested for work quality and direction. Project: $(basename ${PROJECT_DIR})",
  "importance": "normal"
}
EOF
)

echo "${CHECKPOINT_MEMORY}" > "${PROJECT_DIR}/.claude-memory-checkpoint-$(date +%s).json"

log "Awaiting user validation..."

exit 0

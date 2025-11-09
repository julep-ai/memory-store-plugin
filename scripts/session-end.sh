#!/bin/bash
# Session End Hook - Summarize session and store learnings
# This script runs at the end of each Claude Code session

set -euo pipefail

PROJECT_DIR="${PWD}"
SESSION_ID="${CLAUDE_MEMORY_SESSION_ID:-unknown}"
SESSION_FILE="${CLAUDE_MEMORY_SESSION_FILE:-}"

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

log "Session ending: ${SESSION_ID}"

# Read session data if available
if [[ -f "${SESSION_FILE}" ]]; then
    FILES_TRACKED=$(jq -r '.files_tracked | length' "${SESSION_FILE}" 2>/dev/null || echo "0")
    COMMITS_ANALYZED=$(jq -r '.commits_analyzed | length' "${SESSION_FILE}" 2>/dev/null || echo "0")
    START_TIME=$(jq -r '.start_time' "${SESSION_FILE}" 2>/dev/null || echo "unknown")
    
    log "Files tracked: ${FILES_TRACKED}"
    log "Commits analyzed: ${COMMITS_ANALYZED}"
else
    FILES_TRACKED="0"
    COMMITS_ANALYZED="0"
    START_TIME="unknown"
fi

# Calculate session duration
if [[ "${START_TIME}" != "unknown" ]]; then
    START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "${START_TIME}" "+%s" 2>/dev/null || echo "0")
    END_EPOCH=$(date "+%s")
    DURATION=$((END_EPOCH - START_EPOCH))
    DURATION_HUMAN="$((DURATION / 3600))h $(((DURATION % 3600) / 60))m"
else
    DURATION_HUMAN="unknown"
fi

log "Session duration: ${DURATION_HUMAN}"

# Get git changes during session
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Get commits made during session (approximate)
    SESSION_COMMITS=$(git log --since="${START_TIME}" --oneline 2>/dev/null | wc -l | tr -d ' ')
    
    # Get list of modified files
    MODIFIED_FILES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
    
    # Get commit messages if any
    if [[ "${SESSION_COMMITS}" -gt 0 ]]; then
        COMMIT_MESSAGES=$(git log --since="${START_TIME}" --pretty=format:"%s" 2>/dev/null || echo "")
    else
        COMMIT_MESSAGES=""
    fi
    
    log "Commits during session: ${SESSION_COMMITS}"
    log "Modified files: ${MODIFIED_FILES}"
else
    SESSION_COMMITS="0"
    MODIFIED_FILES="0"
    COMMIT_MESSAGES=""
fi

# Create session summary
SESSION_SUMMARY=$(cat <<EOF
Development session completed in project $(basename "${PROJECT_DIR}").
Duration: ${DURATION_HUMAN}
Files tracked: ${FILES_TRACKED}
Commits made: ${SESSION_COMMITS}
Modified files: ${MODIFIED_FILES}
EOF
)

# Calculate session quality/feedback score
# Based on: corrections needed, iterations, success rate
CORRECTIONS_COUNT=$(grep -c "CORRECTION" "${SESSION_FILE}" 2>/dev/null || echo "0")
if [[ "${CORRECTIONS_COUNT}" -eq 0 ]]; then
    SESSION_RATING="10"
    SESSION_QUALITY="Excellent"
elif [[ "${CORRECTIONS_COUNT}" -le 2 ]]; then
    SESSION_RATING="7"
    SESSION_QUALITY="Good"
else
    SESSION_RATING="5"
    SESSION_QUALITY="Needs Improvement"
fi

log "Session rating: ${SESSION_RATING}/10 (${SESSION_QUALITY})"

# Prepare comprehensive memory record with feedback
MEMORY_RECORD=$(cat <<EOF
{
  "memory": "Development session completed in project $(basename "${PROJECT_DIR}"). Duration: ${DURATION_HUMAN}, Files: ${FILES_TRACKED}, Commits: ${SESSION_COMMITS}, Quality: ${SESSION_QUALITY}",
  "background": "Session ${SESSION_ID} ended at $(date -u +%Y-%m-%dT%H:%M:%SZ). Commit messages: ${COMMIT_MESSAGES}. Modified files: ${MODIFIED_FILES}. Corrections needed: ${CORRECTIONS_COUNT}. This session involved ${FILES_TRACKED} tracked files with ${COMMITS_ANALYZED} commits analyzed. Overall session quality: ${SESSION_QUALITY} (${SESSION_RATING}/10).",
  "importance": "normal",
  "end": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)

# Save session memory record
cat > "${PROJECT_DIR}/.claude-memory-session-end.json" <<EOF
${MEMORY_RECORD}
EOF

# Prepare feedback for memory store
FEEDBACK_MARKDOWN=$(cat <<EOF
# Session Feedback

**Project**: $(basename "${PROJECT_DIR}")
**Duration**: ${DURATION_HUMAN}
**Rating**: ${SESSION_RATING}/10
**Quality**: ${SESSION_QUALITY}

## Session Metrics

- Files tracked: ${FILES_TRACKED}
- Commits made: ${SESSION_COMMITS}
- Modified files: ${MODIFIED_FILES}
- Corrections needed: ${CORRECTIONS_COUNT}

## Commit Messages

${COMMIT_MESSAGES}

## Session Quality Analysis

$(if [[ "${CORRECTIONS_COUNT}" -eq 0 ]]; then
    echo "✓ No corrections needed - Claude performed excellently"
    echo "✓ All suggestions were accurate and matched project patterns"
elif [[ "${CORRECTIONS_COUNT}" -le 2 ]]; then
    echo "⚠ Minor corrections needed (${CORRECTIONS_COUNT})"
    echo "⚠ Overall good performance with room for improvement"
else
    echo "❌ Multiple corrections needed (${CORRECTIONS_COUNT})"
    echo "❌ Claude needs better context or pattern understanding"
fi)

## Context for Future Sessions

This session's learnings should inform future work on similar features.
Any corrections made are high-priority memories for pattern improvement.
EOF
)

# Save feedback
cat > "${PROJECT_DIR}/.claude-memory-feedback.md" <<EOF
${FEEDBACK_MARKDOWN}
EOF

log "Session summary and feedback created"

# Sync CLAUDE.md files one last time
if [[ -f "${CLAUDE_PLUGIN_ROOT}/scripts/sync-claude-md.sh" ]]; then
    log "Syncing CLAUDE.md files..."
    bash "${CLAUDE_PLUGIN_ROOT}/scripts/sync-claude-md.sh" || true
fi

# Clean up session file
if [[ -f "${SESSION_FILE}" ]]; then
    rm -f "${SESSION_FILE}"
fi

# Remove session marker
rm -f "${PROJECT_DIR}/.claude-memory-session"

log "Session ended successfully"

exit 0

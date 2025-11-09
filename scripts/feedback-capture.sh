#!/bin/bash
# Feedback Capture Hook - Store feedback when responses are poor quality
# This script can be triggered manually or automatically when issues are detected

set -euo pipefail

PROJECT_DIR="${PWD}"
SESSION_ID="${CLAUDE_MEMORY_SESSION_ID:-unknown}"

# Log function
log() {
    echo "[Memory Plugin - Feedback] $1" >&2
}

# Get feedback context
FEEDBACK_TYPE="${1:-poor-response}"
RATING="${2:-3}"  # Default rating 3/10 for poor responses
CONTEXT="${3:-}"

log "Capturing feedback: ${FEEDBACK_TYPE} (Rating: ${RATING}/10)"

# Get current git context
if git rev-parse --git-dir > /dev/null 2>&1; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "none")
else
    CURRENT_BRANCH="not-a-git-repo"
    LAST_COMMIT="none"
fi

# Get recent tool usage (last 5 operations)
# This would typically come from Claude Code's tool history
# For now, we'll capture what we can from the session

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Build detailed feedback context
FEEDBACK_CONTEXT=$(cat <<EOF
Feedback Type: ${FEEDBACK_TYPE}
Timestamp: ${TIMESTAMP}
Session: ${SESSION_ID}
Project: $(basename "${PROJECT_DIR}")
Git Branch: ${CURRENT_BRANCH}
Last Commit: ${LAST_COMMIT}

Context:
${CONTEXT}

This feedback indicates an opportunity to improve responses or tool usage.
The rating of ${RATING}/10 suggests specific issues that should be analyzed
and learned from to prevent similar problems in the future.
EOF
)

# Prepare feedback payload for memory_feedback tool
# This uses the memory MCP server's feedback capability
FEEDBACK_MARKDOWN=$(cat <<EOF
# Poor Quality Response Feedback

**Type**: ${FEEDBACK_TYPE}  
**Rating**: ${RATING}/10  
**Session**: ${SESSION_ID}  
**Project**: $(basename "${PROJECT_DIR}")  
**Branch**: ${CURRENT_BRANCH}

## Context

${CONTEXT}

## Environment

- **Timestamp**: ${TIMESTAMP}
- **Last Commit**: ${LAST_COMMIT}
- **Working Directory**: ${PROJECT_DIR}

## What Went Wrong

The response or tool usage did not meet quality expectations. This feedback
is stored to help improve future responses in similar contexts.

## Expected Improvement

- Better context awareness
- More accurate pattern matching
- Improved error handling
- Enhanced decision making

## Related Patterns

This feedback should be considered when working on:
- Similar file types or patterns
- Same project context
- Related development tasks
EOF
)

log "Feedback context prepared"
log "Type: ${FEEDBACK_TYPE}, Rating: ${RATING}/10"

# In a real implementation, this would call the memory_feedback MCP tool
# For now, we log and prepare the data structure

# Also store as a regular memory record with low importance
# This ensures the feedback is captured even if feedback tool isn't available
MEMORY_TEXT="Feedback captured: ${FEEDBACK_TYPE} (${RATING}/10) - ${CONTEXT:0:100}"

# Save feedback record for MCP tool
FEEDBACK_RECORD=$(cat <<EOF
{
  "input": "${FEEDBACK_MARKDOWN}",
  "rating": ${RATING}
}
EOF
)

cat > "${PROJECT_DIR}/.claude-memory-feedback-${TIMESTAMP}.json" <<EOF
${FEEDBACK_RECORD}
EOF

# Also create a high-importance memory record for corrections
if [[ "${FEEDBACK_TYPE}" == "correction" ]] || [[ "${RATING}" -lt 5 ]]; then
    CORRECTION_MEMORY=$(cat <<EOF
{
  "memory": "Correction: ${CONTEXT:0:200}",
  "background": "Feedback captured at ${TIMESTAMP} in session ${SESSION_ID}. Type: ${FEEDBACK_TYPE}, Rating: ${RATING}/10. This indicates Claude made a mistake that should be learned from. Context: ${CONTEXT}",
  "importance": "high",
  "is_resolution": true
}
EOF
)

    echo "${CORRECTION_MEMORY}" > "${PROJECT_DIR}/.claude-memory-correction-${TIMESTAMP}.json"

    # Mark in session file for quality tracking
    if [[ -n "${CLAUDE_MEMORY_SESSION_FILE}" ]] && [[ -f "${CLAUDE_MEMORY_SESSION_FILE}" ]]; then
        echo "CORRECTION: ${CONTEXT}" >> "${CLAUDE_MEMORY_SESSION_FILE}"
    fi
fi

log "Feedback stored successfully"
log "This will help improve future responses in similar contexts"

exit 0

#!/bin/bash
# Auto-Feedback - Automatic feedback capture when errors are detected
# Fires on Notification events matching error patterns

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"
SESSION_ID="${MEMORY_SESSION_ID:-unknown}"

# Get notification content (if available from environment)
NOTIFICATION="${CLAUDE_NOTIFICATION:-}"
CONTEXT="${CLAUDE_CONTEXT:-}"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Pattern matching for error indicators
ERROR_DETECTED=false
ERROR_TYPE="unknown"
SEVERITY="medium"

if [[ -n "${NOTIFICATION}" ]]; then
  # Check for explicit error keywords
  if echo "${NOTIFICATION}" | grep -qiE "error|failed|failure"; then
    ERROR_DETECTED=true
    ERROR_TYPE="error"
    SEVERITY="high"
  elif echo "${NOTIFICATION}" | grep -qiE "wrong|incorrect|mistake|no that's"; then
    ERROR_DETECTED=true
    ERROR_TYPE="correction"
    SEVERITY="high"
  elif echo "${NOTIFICATION}" | grep -qiE "warning|warn|issue"; then
    ERROR_DETECTED=true
    ERROR_TYPE="warning"
    SEVERITY="medium"
  elif echo "${NOTIFICATION}" | grep -qiE "deprecated|outdated|old"; then
    ERROR_DETECTED=true
    ERROR_TYPE="deprecation"
    SEVERITY="low"
  fi
fi

# If error detected, capture feedback automatically (async)
if [[ "${ERROR_DETECTED}" == "true" ]]; then
  {
    # Truncate notification for storage (first 500 chars)
    NOTIFICATION_SHORT=$(echo "${NOTIFICATION}" | head -c 500)

    # Prepare feedback memory
    MEMORY_TEXT="Automatic feedback captured: ${ERROR_TYPE} detected in session ${SESSION_ID}. Context: ${NOTIFICATION_SHORT}"

    BACKGROUND_TEXT="Automatic feedback system detected ${ERROR_TYPE} (severity: ${SEVERITY}) at ${TIMESTAMP} in project ${PROJECT_DIR}. This helps Claude learn from mistakes and improve future responses."

    # Record with appropriate importance based on severity
    IMPORTANCE="normal"
    if [[ "${SEVERITY}" == "high" ]]; then
      IMPORTANCE="high"
    elif [[ "${SEVERITY}" == "low" ]]; then
      IMPORTANCE="low"
    fi

    # Send to memory store (async, non-blocking)
    claude mcp call memory-store record \
      --memory "${MEMORY_TEXT}" \
      --background "${BACKGROUND_TEXT}" \
      --importance "${IMPORTANCE}" \
      --is_resolution true &

    # Also send via feedback tool for analytics
    claude mcp call memory-store feedback \
      --input "**Auto-captured ${ERROR_TYPE}**: ${NOTIFICATION_SHORT}" \
      --rating 3 &
  } 2>/dev/null

  # Increment error count for session quality tracking
  ERROR_COUNT_FILE=".claude-session-errors-count"
  if [[ -f "${ERROR_COUNT_FILE}" ]]; then
    CURRENT_COUNT=$(cat "${ERROR_COUNT_FILE}")
    echo $((CURRENT_COUNT + 1)) > "${ERROR_COUNT_FILE}"
  else
    echo "1" > "${ERROR_COUNT_FILE}"
  fi
fi

# Non-blocking continuation
echo '{"continue": true}'
exit 0

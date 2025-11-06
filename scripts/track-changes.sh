#!/bin/bash
# Track Changes Hook - Monitor file modifications in real-time
# This script runs after Write or Edit tool usage

set -euo pipefail

PROJECT_DIR="${PWD}"
SESSION_ID="${CLAUDE_MEMORY_SESSION_ID:-unknown}"
SESSION_FILE="${CLAUDE_MEMORY_SESSION_FILE:-}"

# Log function
log() {
    echo "[Memory Plugin] $1" >&2
}

# Get the file path from stdin or environment (passed by Claude Code)
# This would be provided by the Claude Code hook system
FILE_PATH="${1:-}"

if [[ -z "${FILE_PATH}" ]]; then
    # Try to get from recent git changes
    FILE_PATH=$(git diff --name-only HEAD 2>/dev/null | head -1 || echo "")
fi

if [[ -z "${FILE_PATH}" ]]; then
    log "No file path provided, skipping tracking"
    exit 0
fi

log "Tracking changes to: ${FILE_PATH}"

# Get relative path from project root
REL_PATH=$(realpath --relative-to="${PROJECT_DIR}" "${FILE_PATH}" 2>/dev/null || echo "${FILE_PATH}")

# Determine if this is a new file or modification
if git ls-files --error-unmatch "${FILE_PATH}" > /dev/null 2>&1; then
    CHANGE_TYPE="modified"
else
    CHANGE_TYPE="created"
fi

# Get file extension and language
FILE_EXT="${FILE_PATH##*.}"
case "${FILE_EXT}" in
    ts|tsx) FILE_LANG="TypeScript" ;;
    js|jsx) FILE_LANG="JavaScript" ;;
    py) FILE_LANG="Python" ;;
    go) FILE_LANG="Go" ;;
    rs) FILE_LANG="Rust" ;;
    md) FILE_LANG="Markdown" ;;
    json) FILE_LANG="JSON" ;;
    *) FILE_LANG="Unknown" ;;
esac

# Check if this is a CLAUDE.md file
if [[ "${FILE_PATH}" =~ CLAUDE\.md$ ]] || [[ "${FILE_PATH}" =~ claude\.md$ ]]; then
    IS_CLAUDE_MD="true"
    log "CLAUDE.md file modified, triggering sync..."
    
    # Trigger CLAUDE.md sync
    if [[ -f "${CLAUDE_PLUGIN_ROOT}/scripts/sync-claude-md.sh" ]]; then
        bash "${CLAUDE_PLUGIN_ROOT}/scripts/sync-claude-md.sh" "${FILE_PATH}" &
    fi
else
    IS_CLAUDE_MD="false"
fi

# Detect patterns (simple heuristics)
PATTERNS_DETECTED=""
if [[ "${FILE_PATH}" =~ /api/ ]] || [[ "${FILE_PATH}" =~ /routes/ ]]; then
    PATTERNS_DETECTED="API endpoint"
elif [[ "${FILE_PATH}" =~ /components/ ]] || [[ "${FILE_PATH}" =~ /views/ ]]; then
    PATTERNS_DETECTED="UI component"
elif [[ "${FILE_PATH}" =~ /services/ ]]; then
    PATTERNS_DETECTED="Service layer"
elif [[ "${FILE_PATH}" =~ /models/ ]] || [[ "${FILE_PATH}" =~ /entities/ ]]; then
    PATTERNS_DETECTED="Data model"
elif [[ "${FILE_PATH}" =~ /test/ ]] || [[ "${FILE_PATH}" =~ \.test\. ]] || [[ "${FILE_PATH}" =~ \.spec\. ]]; then
    PATTERNS_DETECTED="Test file"
fi

# Update session file
if [[ -f "${SESSION_FILE}" ]]; then
    # Add file to tracked files list
    jq --arg file "${REL_PATH}" --arg type "${CHANGE_TYPE}" --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '.files_tracked += [{"file": $file, "type": $type, "time": $time}]' \
        "${SESSION_FILE}" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "${SESSION_FILE}"
fi

# Prepare memory record
MEMORY_TEXT="File ${CHANGE_TYPE}: ${REL_PATH} (${FILE_LANG})"
if [[ -n "${PATTERNS_DETECTED}" ]]; then
    MEMORY_TEXT="${MEMORY_TEXT}. Pattern: ${PATTERNS_DETECTED}"
fi

MEMORY_PAYLOAD=$(cat <<EOF
{
  "memory": "${MEMORY_TEXT}",
  "background": "Session ${SESSION_ID} - File ${REL_PATH} was ${CHANGE_TYPE}. Language: ${FILE_LANG}. Pattern detected: ${PATTERNS_DETECTED}. Project: ${PROJECT_DIR}",
  "importance": "low"
}
EOF
)

log "Change tracked: ${REL_PATH} (${CHANGE_TYPE})"

# Optional: Analyze file content for patterns
# This could be enhanced to detect specific coding patterns, imports, etc.

exit 0

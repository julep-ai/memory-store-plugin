#!/bin/bash
# Track Changes Hook - Monitor file modifications in real-time
# This script runs before Write or Edit tool usage (PreToolUse)

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD}}"

# Load session state from project-local file
SESSION_FILE="${PROJECT_DIR}/.claude-session"
if [[ -f "${SESSION_FILE}" ]]; then
    source "${SESSION_FILE}"
fi

SESSION_ID="${MEMORY_SESSION_ID:-unknown}"

# Read JSON input from stdin (Claude Code hook protocol)
if [ -t 0 ]; then
    # No stdin (terminal), exit silently
    cat <<EOF
{
  "continue": true
}
EOF
    exit 0
fi

INPUT_JSON=$(cat)

# Extract file_path from tool_input using jq or bash fallback
if command -v jq &> /dev/null; then
    FILE_PATH=$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")
else
    # Fallback: simple grep for file_path
    FILE_PATH=$(echo "$INPUT_JSON" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/' || echo "")
fi

if [[ -z "${FILE_PATH}" ]]; then
    # No file to track, exit silently
    cat <<EOF
{
  "continue": true
}
EOF
    exit 0
fi

# Get relative path from project root
REL_PATH=$(realpath --relative-to="${PROJECT_DIR}" "${FILE_PATH}" 2>/dev/null || basename "${FILE_PATH}")

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
elif [[ "${FILE_PATH}" =~ CLAUDE\.md$ ]] || [[ "${FILE_PATH}" =~ claude\.md$ ]]; then
    PATTERNS_DETECTED="documentation (CLAUDE.md)"
fi

# Increment change counter (from session file)
CHANGES_COUNT=$((${MEMORY_CHANGES_COUNT:-0} + 1))

# Update session file with new count
if [[ -f "${SESSION_FILE}" ]]; then
    # Use sed to update the counter in the session file
    if grep -q "MEMORY_CHANGES_COUNT=" "${SESSION_FILE}" 2>/dev/null; then
        sed -i.bak "s/MEMORY_CHANGES_COUNT=.*/MEMORY_CHANGES_COUNT=${CHANGES_COUNT}/" "${SESSION_FILE}"
        rm -f "${SESSION_FILE}.bak"
    else
        echo "MEMORY_CHANGES_COUNT=${CHANGES_COUNT}" >> "${SESSION_FILE}"
    fi
fi

# Build memory context
MEMORY_TEXT="File ${CHANGE_TYPE}: ${REL_PATH} (${FILE_LANG})"
if [[ -n "${PATTERNS_DETECTED}" ]]; then
    MEMORY_TEXT="${MEMORY_TEXT}. Pattern: ${PATTERNS_DETECTED}"
fi

# Check for checkpoint milestone
CHECKPOINT_MSG=""
if [[ $((CHANGES_COUNT % 10)) -eq 0 ]]; then
    CHECKPOINT_MSG="✓ Checkpoint: ${CHANGES_COUNT} files tracked this session"
fi

# Output JSON to trigger memory storage and show checkpoint
cat <<EOF
{
  "additionalContext": "📝 ${MEMORY_TEXT}. Session: ${SESSION_ID}, Project: $(basename ${PROJECT_DIR}). Store this in memory using memory__record with importance: low, background: 'File ${REL_PATH} was ${CHANGE_TYPE} in session ${SESSION_ID}. Language: ${FILE_LANG}. Pattern: ${PATTERNS_DETECTED}. Change #${CHANGES_COUNT}.'",
  ${CHECKPOINT_MSG:+"userMessage": "$CHECKPOINT_MSG",}
  "continue": true
}
EOF

exit 0

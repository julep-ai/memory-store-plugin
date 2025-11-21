#!/bin/bash
# Track Changes Hook - Monitor file modifications in real-time
# This script runs before Write or Edit tool usage (PreToolUse)

set -euo pipefail

# JSON escape function to prevent command injection
json_escape() {
    # Escape backslashes, quotes, newlines, tabs, and control characters
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

# Intelligent filtering: Skip files that don't need tracking
SHOULD_SKIP="false"

# Skip auto-generated, temporary, or trivial files
if [[ "${FILE_PATH}" =~ \.log$ ]] || \
   [[ "${FILE_PATH}" =~ \.tmp$ ]] || \
   [[ "${FILE_PATH}" =~ node_modules/ ]] || \
   [[ "${FILE_PATH}" =~ \.next/ ]] || \
   [[ "${FILE_PATH}" =~ dist/ ]] || \
   [[ "${FILE_PATH}" =~ build/ ]] || \
   [[ "${FILE_PATH}" =~ __pycache__/ ]] || \
   [[ "${FILE_PATH}" =~ \.pyc$ ]] || \
   [[ "${FILE_PATH}" =~ package-lock\.json$ ]] || \
   [[ "${FILE_PATH}" =~ yarn\.lock$ ]] || \
   [[ "${FILE_PATH}" =~ pnpm-lock\.yaml$ ]] || \
   [[ "${FILE_PATH}" =~ \.min\. ]]; then
    SHOULD_SKIP="true"
fi

# Exit silently if we should skip
if [[ "${SHOULD_SKIP}" == "true" ]]; then
    cat <<EOF
{
  "continue": true
}
EOF
    exit 0
fi

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
    yml|yaml) FILE_LANG="YAML" ;;
    toml) FILE_LANG="TOML" ;;
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

# Intelligent importance detection
IMPORTANCE="low"  # Default for most files

# High importance: Core architecture, config, important docs
if [[ "${FILE_PATH}" =~ CLAUDE\.md$ ]] || \
   [[ "${FILE_PATH}" =~ README\.md$ ]] || \
   [[ "${FILE_PATH}" =~ package\.json$ ]] || \
   [[ "${FILE_PATH}" =~ tsconfig\.json$ ]] || \
   [[ "${FILE_PATH}" =~ docker ]] || \
   [[ "${FILE_PATH}" =~ \.env ]] || \
   [[ "${PATTERNS_DETECTED}" =~ "API endpoint" ]] || \
   [[ "${PATTERNS_DETECTED}" =~ "Data model" ]]; then
    IMPORTANCE="normal"
fi

# Very high importance: Critical configuration
if [[ "${FILE_PATH}" =~ plugin\.json$ ]] || \
   [[ "${FILE_PATH}" =~ hooks\.json$ ]]; then
    IMPORTANCE="high"
fi

# Escape all variables for safe JSON interpolation
MEMORY_ESCAPED=$(json_escape "${MEMORY_TEXT}")
REL_PATH_ESCAPED=$(json_escape "${REL_PATH}")
CHANGE_TYPE_ESCAPED=$(json_escape "${CHANGE_TYPE}")
SESSION_ID_ESCAPED=$(json_escape "${SESSION_ID}")
FILE_LANG_ESCAPED=$(json_escape "${FILE_LANG}")
PATTERNS_ESCAPED=$(json_escape "${PATTERNS_DETECTED}")
PROJECT_NAME=$(basename "${PROJECT_DIR}")
PROJECT_ESCAPED=$(json_escape "${PROJECT_NAME}")

# Build background context
BACKGROUND_CONTEXT="File ${REL_PATH} was ${CHANGE_TYPE} in session ${SESSION_ID}. Language: ${FILE_LANG}. Pattern: ${PATTERNS_DETECTED}. Change #${CHANGES_COUNT}. Project: ${PROJECT_NAME}."

# Queue memory for processing (bypasses additionalContext visibility issue)
bash "${PROJECT_DIR}/scripts/queue-memory.sh" \
  --memory "${MEMORY_TEXT}" \
  --background "${BACKGROUND_CONTEXT}" \
  --importance "${IMPORTANCE}" 2>/dev/null || true

# Output JSON for Claude
cat <<EOF
{
  "additionalContext": "📝 ${MEMORY_TEXT}. Session: ${SESSION_ID}, Change #${CHANGES_COUNT}. Memory queued.",
  ${CHECKPOINT_MSG:+"userMessage": "$CHECKPOINT_MSG",}
  "continue": true
}
EOF

exit 0
